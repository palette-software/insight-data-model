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
								   
				)
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
					   , max(s.ts) over (partition by s.parent_vizql_session) as session_end_ts_utc
					   , h.site_name_id
					   , h.project_name_id
					   , h.workbook_name_id
					   , wb.revision as workbook_rev
					   , h.publisher_username_id
				from s_serverlogs s
				  	left outer join (SELECT       				  
										  r.vizql_session,
										  max(r.site_name || '' ('' || r.site_id || '')'') as site_name_id,
										  max(r.project_name || '' ('' || r.project_id || '')'') as project_name_id,
										  max(r.workbook_name || '' ('' || r.workbook_id || '')'') as workbook_name_id,				  
										  max(r.publisher_username || '' ('' || r.publisher_user_id || '')'') as publisher_username_id,
										  max(h_workbooks_p_id) as h_workbooks_p_id
										FROM 
											p_http_requests r					
										WHERE
										  coalesce(r.currentsheet, '''') <> '''' AND 
										  r.vizql_session IS NOT NULL AND 
										  r.vizql_session <> ''-'' AND 
										  r.site_id IS NOT NULL   
										group by
										  	r.vizql_session
							) h on (s.parent_vizql_session = h.vizql_session)
							left outer join h_workbooks wb on (wb.p_id = h.h_workbooks_p_id)				
				'
				;
								
		raise notice 'I: %', v_sql;
		execute v_sql;
				
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;			
		return v_num_inserted;
		
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY INVOKER;