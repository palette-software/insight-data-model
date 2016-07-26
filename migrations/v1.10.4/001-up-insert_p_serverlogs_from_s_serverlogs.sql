select delete_recent_records_from_p_serverlogs('palette');

select insert_p_serverlogs_from_s_serverlogs('palette');

select * from palette.p_serverlogs
where ts >= now()::date
and parent_vizql_session is not null
limit 100;

select s.ts, s.session_elapsed_seconds, s.*
from palette.p_serverlogs s
where parent_vizql_session ='0256335C0DCD4A558CAFDA838D5C9DCB-0:0'
and ts >= now()::date
order by ts
;

CREATE OR REPLACE FUNCTION insert_p_serverlogs_from_s_serverlogs(p_schema_name text)
RETURNS bigint AS
$BODY$
declare
	v_sql text;
	v_num_inserted bigint;
begin							
		
		execute 'set local search_path = ' || p_schema_name;
		
		v_sql := 'insert into p_serverlogs(
							        serverlogs_id
							       , p_filepath
							       , filename
							       , host_name
							       , ts
							       , process_id
							       , thread_id
							       , sev
							       , req
							       , sess
							       , site
							       , username
							       , username_without_domain
							       , k
							       , v
							       , parent_vizql_session
							       , parent_vizql_destroy_sess_ts
							       , parent_dataserver_session
							       , spawned_by_parent_ts
							       , parent_process_type
							       , p_cre_date
							       , parent_vizql_site
							       , parent_vizql_username
							       , parent_dataserver_site
							       , parent_dataserver_username
							       , process_name
							       , thread_name
								   , elapsed_ms
								   , start_ts
								   , session_start_ts_utc
								   , session_end_ts_utc
					   			   , site_name_id
					   			   , project_name_id
					   			   , workbook_name_id
					   			   , workbook_rev
					   		   	   , publisher_username_id
								   , user_type
								   , session_elapsed_seconds
				)
				
				with t_req_wb as
				(select
					h.vizql_session,
					h.site_name_id,
					h.project_name_id,
					h.workbook_name_id,
					h.publisher_username_id,
					h.h_workbooks_p_id,
					h.user_type,
					wb.revision
				from
					(SELECT       				  
						  r.vizql_session,
						  max(r.site_name || '' ('' || r.site_id || '')'') as site_name_id,
						  max(r.project_name || '' ('' || r.project_id || '')'') as project_name_id,
						  max(r.workbook_name || '' ('' || r.workbook_id || '')'') as workbook_name_id,				  
						  max(r.publisher_username || '' ('' || r.publisher_user_id || '')'') as publisher_username_id,
						  max(h_workbooks_p_id) as h_workbooks_p_id,
						  						  CASE WHEN r.vizql_session is not NULL AND
                                max(split_part(r.http_request_uri, ''/'', 2)) = ''authoring'' AND
                                max(r.action) = ''show'' THEN ''web author''
                            WHEN vizql_session is not NULL AND
                                max(split_part(r.http_request_uri, ''/'', 2)) != ''authoring'' AND
                                max(r.action) = ''show'' THEN ''interactor'' END
                            AS user_type
						FROM 
							p_http_requests r					
						WHERE
						  coalesce(r.currentsheet, '''') <> '''' AND 
						  r.vizql_session IS NOT NULL AND 
						  r.vizql_session <> ''-'' AND 
						  r.site_id IS NOT NULL   
						group by
						  	r.vizql_session
					) h
					left outer join h_workbooks wb on (wb.p_id = h.h_workbooks_p_id)
				)
				
				select 
					  a.serverlogs_id
					, a.p_filepath
					, a.filename
					, a.host_name
					, a.ts
					, a.process_id
					, a.thread_id
					, a.sev
					, a.req
					, a.sess
					, a.site
					, a.username
					, a.username_without_domain
					, a.k
					, a.v
					, a.parent_vizql_session
					, a.parent_vizql_destroy_sess_ts
					, a.parent_dataserver_session
					, a.spawned_by_parent_ts
					, a.parent_process_type
					, a.p_cre_date
					, a.parent_vizql_site
					, a.parent_vizql_username
					, a.parent_dataserver_site
					, a.parent_dataserver_username
					, a.process_name
					, a.thread_name
					, a.elapsed_ms
					, a.start_ts
					, a.session_start_ts_utc				
					, a.session_end_ts_utc
					, a.site_name_id
					, a.project_name_id
					, a.workbook_name_id
					, a.workbook_rev
					, a.publisher_username_id
					, a.user_type
					, sum(extract(''epoch'' from ts_diff)) over (partition by a.host_name, a.parent_vizql_session order by a.ts, a.p_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as session_elapsed_seconds					
				from
					(
					select 
					         s.serverlogs_id
					       , s.p_filepath
					       , s.filename
					       , s.host_name
					       , s.ts
					       , s.process_id
					       , s.thread_id
					       , s.sev
					       , s.req
					       , s.sess
					       , s.site
					       , s.username
					       , s.username_without_domain
					       , s.k
					       , s.v
					       , s.parent_vizql_session
					       , s.parent_vizql_destroy_sess_ts
					       , s.parent_dataserver_session
					       , s.spawned_by_parent_ts
					       , s.parent_process_type
					       , s.p_cre_date
					       , s.parent_vizql_site
					       , s.parent_vizql_username
					       , s.parent_dataserver_site
					       , s.parent_dataserver_username
					       , s.process_name
					       , s.process_name || '':'' || s.process_id || '':'' || s.thread_id as thread_name
						   , s.elapsed_ms
						   , s.start_ts
						   , min(s.ts) over (partition by s.parent_vizql_session) as session_start_ts_utc				
						   , s.parent_vizql_destroy_sess_ts as session_end_ts_utc
						   , h.site_name_id
						   , h.project_name_id
						   , h.workbook_name_id
						   , h.revision as workbook_rev
						   , h.publisher_username_id
						   , h.user_type
						   , s.p_id
						   , coalesce(s.ts - lag(s.ts) over (partition by s.host_name, s.parent_vizql_session order by s.ts, s.p_id), interval ''0'') as ts_diff
					from s_serverlogs s
					  	left outer join t_req_wb h on (h.vizql_session = s.parent_vizql_session)
					) a
				';
								
		raise notice 'I: %', v_sql;
		execute v_sql;
				
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;			
		return v_num_inserted;
		
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY INVOKER;
