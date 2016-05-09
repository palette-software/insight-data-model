CREATE OR REPLACE FUNCTION insert_p_serverlogs_from_s_serverlogs(p_schema_name text)
RETURNS bigint AS
$BODY$
declare
	v_sql text;
	v_num_inserted bigint;
begin							
		
		v_sql := 'insert into #schema_name#.p_serverlogs(
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
				)
				select 
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
				       , process_name || '':'' || process_id || '':'' || thread_id as thread_name
				from #schema_name#.s_serverlogs';
				
		v_sql := replace(v_sql, '#schema_name#', p_schema_name);		
		
		raise notice 'I: %', v_sql;
		execute v_sql;
				
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;			
		return v_num_inserted;
		
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY INVOKER;