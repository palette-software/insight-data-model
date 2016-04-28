CREATE or replace function load_p_serverlogs(p_schema_name text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;
	v_num_inserted_all bigint;	
	v_max_ts_date text;
begin		

		v_num_inserted_all := 0;				
				
		execute 'select ' || p_schema_name || '.load_p_serverlogs_rest(''' || p_schema_name || ''')' into v_num_inserted;
		v_num_inserted_all := v_num_inserted_all + v_num_inserted;

		execute 'select ' || p_schema_name || '.load_p_serverlogs_vizql(''' || p_schema_name || ''')' into v_num_inserted;
		v_num_inserted_all := v_num_inserted_all + v_num_inserted;


		v_sql := 'delete from #schema_name#.p_serverlogs
				 where 
					(substr(filename, 1, 11) = ''tabprotosrv'' or substr(filename, 1, 10) = ''dataserver'')
					and ts >= (select #schema_name#.get_max_ts_date(''#schema_name#'', ''p_serverlogs''))';

		v_sql := replace(v_sql, '#schema_name#', p_schema_name);
		execute v_sql;
												
		execute 'truncate table ' || p_schema_name || '.s_serverlogs';		
				
		execute 'select ' || p_schema_name || '.load_s_serverlogs_dataserver(''' || p_schema_name || ''')' into v_num_inserted;
		v_num_inserted_all := v_num_inserted_all + v_num_inserted;
		
		execute 'insert into '
			|| p_schema_name || '.p_serverlogs ( 
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
									   , parent_vizql_site
									   , parent_vizql_username
									   , parent_dataserver_site
									   , parent_dataserver_username
									 )
		SELECT 
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
			   , parent_vizql_site
			   , parent_vizql_username
			   , parent_dataserver_site
			   , parent_dataserver_username			   
 		FROM ' || p_schema_name || '.s_serverlogs';
		
		execute 'truncate table ' || p_schema_name || '.s_serverlogs';
		
		execute 'select ' || p_schema_name || '.load_s_serverlogs_tabproto(''' || p_schema_name || ''')' into v_num_inserted;
		v_num_inserted_all := v_num_inserted_all + v_num_inserted;																															
		
		execute 'insert into '
			|| p_schema_name || '.p_serverlogs ( 
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
									   , parent_vizql_site
									   , parent_vizql_username
									   , parent_dataserver_site
									   , parent_dataserver_username									   
									 )
		SELECT 
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
			   , parent_vizql_site
			   , parent_vizql_username
			   , parent_dataserver_site
			   , parent_dataserver_username			   
 		FROM ' || p_schema_name || '.s_serverlogs';
								
		return v_num_inserted_all;
END;
$$ LANGUAGE plpgsql;