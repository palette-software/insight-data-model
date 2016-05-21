CREATE or replace function load_s_serverlogs_rest(p_schema_name text) returns bigint
AS $$
declare
	v_sql text;	
	v_num_inserted bigint;
	v_sql_cur text;	
	v_max_p_serverlogs_id text;	
begin	

			v_sql_cur := 'select coalesce(max(serverlogs_id), 0)
							from 
								#schema_name#.p_serverlogs 
							where process_name <> ''tabprotosrv'' and
								  process_name <> ''dataserver'' and
								  process_name <> ''vizqlserver''								  
							';
			
			v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);		
			execute v_sql_cur into v_max_p_serverlogs_id;			

			v_sql := 
			'insert into #schema_name#.s_serverlogs (
					serverlogs_id,
					p_filepath,
					filename,
					process_name,
					host_name,
					ts,
					process_id,
					thread_id,
					sev,
					req,
					sess,
					site,
					username,
					username_without_domain,
					k,
					v,					
					parent_vizql_session,
					parent_vizql_destroy_sess_ts,
					parent_dataserver_session,
					spawned_by_parent_ts,
					parent_process_type,
					parent_vizql_site,
					parent_vizql_username,
					parent_dataserver_site,
					parent_dataserver_username,
					elapsed_ms,
					start_ts
			)			
			
			select 
					p_id,
					sl.p_filepath,
					sl.filename,
					replace(case when position(''_'' in sl.filename) > 0 then substr(sl.filename, 1, position(''_'' in sl.filename) -1) else sl.filename end, ''.txt'', '''') as process_name,
					sl.host_name,
					sl.ts,
					sl.pid,
					sl.tid,
					sl.sev,
					sl.req,
					sl.sess,
					sl.site,
					sl.user,
					substr(sl.user, position(''\\\\'' in sl.user) + 1) as username_without_domain,
					sl.k,
					sl.v,
					null as parent_vizql_session,
					null as parent_vizql_destroy_sess_ts,
					null as parent_dataserver_session,
					null as spawned_by_parent_ts,
					null as parent_process_type,
					null as parent_vizql_site,
					null as parent_vizql_username,
					null as parent_dataserver_site,
					null as parent_dataserver_username,
					sl.elapsed_ms,
					sl.start_ts			
			from
				#schema_name#.serverlogs sl
			where
				substr(sl.filename, 1, 11) <> ''tabprotosrv'' and
				substr(sl.filename, 1, 10) <> ''dataserver'' and
				substr(sl.filename, 1, 11) <> ''vizqlserver'' and				
				sl.p_id > #max_p_serverlogs_id#
			'	
			;
		
		v_sql := replace(v_sql, '#schema_name#', p_schema_name);
		v_sql := replace(v_sql, '#max_p_serverlogs_id#', v_max_p_serverlogs_id);
				
		raise notice 'I: %', v_sql;

		execute v_sql;		
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;			

		return v_num_inserted;
END;
$$ LANGUAGE plpgsql;