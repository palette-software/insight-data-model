CREATE or replace function load_s_serverlogs_dataserver(p_schema_name text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;	
	v_sql_cur text;	
	v_max_ts_date_p_serverlogs text;
	v_max_ts_date_p_threadinfo text;
begin	
			execute 'set local search_path = ' || p_schema_name;
						
			v_sql_cur := 'select to_char((select get_max_ts_date(''#schema_name#'', ''p_serverlogs'')), ''yyyy-mm-dd'')';
			v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);			
			execute v_sql_cur into v_max_ts_date_p_serverlogs;
			v_max_ts_date_p_serverlogs := 'date''' || v_max_ts_date_p_serverlogs || '''';							
									
			v_sql_cur := 'select to_char((select get_max_ts_date(''#schema_name#'', ''p_threadinfo'')), ''yyyy-mm-dd'')';
			v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);			
			execute v_sql_cur into v_max_ts_date_p_threadinfo;
			v_max_ts_date_p_threadinfo := 'date''' || v_max_ts_date_p_threadinfo || '''';
						
			v_sql := 
			'insert into s_serverlogs (
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
					parent_dataserver_session,
					spawned_by_parent_ts,
					parent_vizql_destroy_sess_ts,
					parent_process_type,
					parent_vizql_site,
					parent_vizql_username,
					parent_dataserver_site,
					parent_dataserver_username,
					elapsed_ms,
					start_ts	
			)			
			
			with t_s_spawner as
				(select
					sl.spawner_host_name,
					sl.spawner_session,
					sl.spawned_session,
					sl.spawned_by_parent_ts,					
					sl.parent_vizql_destroy_sess_ts,
					sl.parent_vizql_site,
					sl.parent_vizql_username
				from
					(					
					select distinct
								slog.host_name as spawner_host_name,
								slog.sess as spawner_session,
								case when v like ''%Created new dataserver%'' then (replace(substr(slog.v, position(''Created new dataserver session:'' in slog.v) + 32), ''"'', ''''))::text end as spawned_session,
								slog.ts as spawned_by_parent_ts,
								max(case when k = ''destroy-session'' then ts end) over (partition by host_name, sess) as parent_vizql_destroy_sess_ts,
								case when v like ''%Created new dataserver%'' then true else false end as keep_this_line,
								slog.site as parent_vizql_site,
								slog.username_without_domain as parent_vizql_username
					from 
						(select host_name,
								site,
								sess,
								ts,
								k,								
								v,								
								username_without_domain
						from
							p_serverlogs
						where
							substr(filename, 1, 11) = ''vizqlserver'' and 
							(v like ''%Created new dataserver%'' or k = ''destroy-session'') and 
							ts >= #max_ts_date_p_serverlogs# - interval''24 hours''
						
						union all
						
						select  host_name,
								site,
								sess,
								ts,
								k,								
								v,								
								username_without_domain
						from
							s_serverlogs
						where
							substr(filename, 1, 11) = ''vizqlserver'' and 
							(v like ''%Created new dataserver%'' or k = ''destroy-session'')	
						) slog
					) sl	
				where
					sl.keep_this_line
				)
	
				select 								  
						  s_dataserver.p_id		
						, s_dataserver.p_filepath
						, s_dataserver.filename	
						, replace(case when position(''_'' in s_dataserver.filename) > 0 then substr(s_dataserver.filename, 1, position(''_'' in s_dataserver.filename) -1) else s_dataserver.filename end, ''.txt'', '''') as process_name
						, s_dataserver.host_name
						, s_dataserver.ts
						, s_dataserver.pid as process_id
						, s_dataserver.tid as thread_id
						, s_dataserver.sev
						, s_dataserver.req
						, s_dataserver.sess
						, s_dataserver.site
						, s_dataserver.user
						, substr(s_dataserver.user, position(''\\\\'' in s_dataserver.user) + 1) as username_without_domain
						, s_dataserver.k
						, s_dataserver.v
						, s_spawner.spawner_session as parent_vizql_session
						, null as parent_dataserver_session
						, s_spawner.spawned_by_parent_ts
						, s_spawner.parent_vizql_destroy_sess_ts
						, case when s_spawner.spawner_session is not null then ''vizqlserver'' end as parent_process_type
						, s_spawner.parent_vizql_site as parent_vizql_site
						, s_spawner.parent_vizql_username as parent_vizql_username
						, s_dataserver.site as parent_dataserver_site
						, s_dataserver.user as parent_dataserver_username
						, s_dataserver.elapsed_ms
						, s_dataserver.start_ts
				from
						serverlogs s_dataserver
					left outer join t_s_spawner s_spawner on (s_spawner.spawner_host_name = s_dataserver.host_name and
															  s_spawner.spawned_session = substr(s_dataserver.sess, 1, 32) and
															  s_spawner.spawned_by_parent_ts <= s_dataserver.ts)
				where
					substr(s_dataserver.filename, 1, 10) = ''dataserver'' and					
					s_dataserver.ts between #max_ts_date_p_serverlogs# and #max_ts_date_p_threadinfo# + interval''27 hours'' + interval''15 sec''
				';
						
		v_sql := replace(v_sql, '#max_ts_date_p_serverlogs#', v_max_ts_date_p_serverlogs);
		v_sql := replace(v_sql, '#max_ts_date_p_threadinfo#', v_max_ts_date_p_threadinfo);
		
		raise notice 'I: %', v_sql;

		execute v_sql;		
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;			

		return v_num_inserted;
END;
$$ LANGUAGE plpgsql;