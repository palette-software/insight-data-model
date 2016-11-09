CREATE OR REPLACE FUNCTION load_s_serverlogs_plus_2_hours(p_schema_name text, p_load_date date)
RETURNS bigint AS
$BODY$
declare
	v_sql text;
    v_num_inserted bigint := 0;
    v_load_date_txt text := to_char(p_load_date, 'yyyy-mm-dd');
begin							
		
	execute 'set local search_path = ' || p_schema_name;
    
    -- Determine "cross utc midnight" sessions
    truncate table cross_utc_midnight_sessions;
    
    insert into cross_utc_midnight_sessions(
                                            parent_process_name,
                                            session
                                            )
        
    select 
        'vizqlserver' as parent_process_name,
        parent_vizql_session as session
    from 
        s_serverlogs
    where
        1 = 1
        and parent_vizql_session is not null
        and parent_vizql_session not in ('-', 'default')
    group by         
        parent_vizql_session
    having 
        min(ts::date) <> max(ts::date)
        
    union all    
    
    select 
        'dataserver' as parent_process_name,
        parent_dataserver_session
    from 
        s_serverlogs
    where
        1 = 1
        and parent_vizql_session is null        
        and parent_dataserver_session is not null
        and parent_dataserver_session not in ('-', 'default')
    group by         
        parent_dataserver_session
    having 
        min(ts::date) <> max(ts::date);
        
    analyze cross_utc_midnight_sessions;
                        
    truncate table s_serverlogs_plus_2_hours;
       
	v_sql := 'insert into s_serverlogs_plus_2_hours
            (
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
               , site_id
   			   , site_name_id
               , project_id
   			   , project_name_id
               , workbook_id
   			   , workbook_name_id
   			   , workbook_rev
               , publisher_id
   		   	   , publisher_username_id
			   , user_type
			   , session_duration
			   , session_elapsed_seconds
               , v_truncated
			)
			
			with t_req_wb as
			(select
				h.vizql_session,
                h.site_id,
				h.site_name_id,
                h.project_id,
				h.project_name_id,
                h.workbook_id,
				h.workbook_name_id,
                h.publisher_id,
				h.publisher_username_id,
				h.h_workbooks_p_id,
				h.user_type,
				wb.revision
			from
				(SELECT       				  
					  r.vizql_session,
                      max(r.site_id) as site_id,
					  max(r.site_name || '' ('' || r.site_id || '')'') as site_name_id,
                      max(r.project_id) as project_id,
					  max(r.project_name || '' ('' || r.project_id || '')'') as project_name_id,
                      max(r.workbook_id) as workbook_id,
					  max(r.workbook_name || '' ('' || r.workbook_id || '')'') as workbook_name_id,
                      max(r.publisher_user_id) as publisher_id,
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
                      created_at >= date''#v_load_date_txt#'' - interval''1 day'' AND
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
                , a.site_id
				, a.site_name_id
                , a.project_id
				, a.project_name_id
                , a.workbook_id
				, a.workbook_name_id
				, a.workbook_rev
                , a.publisher_id
				, a.publisher_username_id
				, a.user_type
				, extract(''epoch'' from (a.session_end_ts_utc - a.session_start_ts_utc)) as session_duration
				, sum(extract(''epoch'' from ts_diff)) over (partition by a.host_name, a.parent_vizql_session order by a.ts, a.p_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as session_elapsed_seconds
                , substr(a.v, 1, 300) as v_truncated
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
                       , h.site_id
					   , h.site_name_id
                       , h.project_id
					   , h.project_name_id
                       , h.workbook_id
					   , h.workbook_name_id                           
					   , h.revision as workbook_rev
                       , h.publisher_id
					   , h.publisher_username_id
					   , h.user_type
					   , s.p_id
					   , coalesce(s.ts - lag(s.ts) over (partition by s.host_name, s.parent_vizql_session order by s.ts, s.p_id), interval ''0'') as ts_diff
				from s_serverlogs s
				left outer join t_req_wb h on (h.vizql_session = s.parent_vizql_session)
                where 1 = 1
                    and s.ts >= date''#v_load_date_txt#''
	                and s.ts < date''#v_load_date_txt#'' + interval ''26 hours''
				) a
			';
            	
    v_sql := replace(v_sql, '#v_load_date_txt#', v_load_date_txt);
	raise notice 'I: %', v_sql;
    execute v_sql;				               
    GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
    
    analyze s_serverlogs_plus_2_hours;
    
	return v_num_inserted;
	
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY INVOKER;