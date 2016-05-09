CREATE or replace function load_s_serverlogs_vizql(p_schema_name text) returns bigint
AS $$
declare	
	v_sql text;
	v_num_inserted bigint;	
begin	
				
		
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
					parent_dataserver_username					
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
					case when sl.sess not in (''-'', ''default'') then sl.sess end as parent_vizql_session,
					null as parent_vizql_destroy_sess_ts,
					null as parent_dataserver_session,
					null as spawned_by_parent_ts,
					null as parent_process_type,
					null as parent_vizql_site,
					null as parent_vizql_username,
					null as parent_dataserver_site,
					null as parent_dataserver_username	
			from
				#schema_name#.serverlogs sl
			where
				substr(sl.filename, 1, 11) = ''vizqlserver'' and				
				sl.p_id > coalesce((select max(serverlogs_id)
							from 
								#schema_name#.p_serverlogs 
							where substr(filename, 1, 11) = ''vizqlserver''), 0)
			'	
			;

		
		v_sql := replace(v_sql, '#schema_name#', p_schema_name);				
		
		raise notice 'I: %', v_sql;	

		execute v_sql;		
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;			

		return v_num_inserted;
END;
$$ LANGUAGE plpgsql;