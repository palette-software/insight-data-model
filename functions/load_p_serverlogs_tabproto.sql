CREATE or replace function load_p_serverlogs_tabproto(p_schema_name text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;
	v_max_ts_date text;
	v_sql_cur text;	
begin	

			v_sql_cur := 'select to_char(coalesce((select max(ts_date) from #schema_name#.p_cpu_usage), date''1001-01-01''), ''yyyy-mm-dd'')';								
			v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);
		
			execute v_sql_cur into v_max_ts_date;
			v_max_ts_date := 'date''' || v_max_ts_date || '''';

			v_sql := 
			'insert into #schema_name#.p_serverlogs_kgz (
					serverlogs_id,
					p_filepath,
					filename,
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
					parent_process_type
			)			
			
			with t_s_spawner as
				(select 
					sl.spawner_process_type,
					sl.spawner_host_name,
					sl.spawner_session,
					sl.spawned_tabproto_process_id,
					sl.spawned_tabproto_process_id_ts,
					tinfo.start_ts,
					sl.spawner_ts_destroy_sess
				from
					(select distinct 								
								case when substr(filename, 1, 11) = ''vizqlserver'' then ''vizqlserver''
									 when substr(filename, 1, 10) = ''dataserver'' then ''dataserver'' 
									 else ''?''
								end as spawner_process_type,
								slog.host_name as spawner_host_name,
								slog.sess as spawner_session,
								case when v like ''%CreateServerProcess%'' then (replace(substr(slog.v, position(''pid'' in slog.v) + 4), ''"'', ''''))::bigint end as spawned_tabproto_process_id,
								slog.ts as spawned_tabproto_process_id_ts,
								max(case when k = ''destroy-session'' then ts end) over (partition by host_name, sess) spawner_ts_destroy_sess,
								case when v like ''%CreateServerProcess%'' then true else false end as keep_this_line
					from #schema_name#.p_serverlogs slog
					where
						(substr(filename, 1, 11) = ''vizqlserver'' or substr(filename, 1, 10) = ''dataserver'') and 
						(v like ''%CreateServerProcess%'' or k = ''destroy-session'') and 
						ts >= #v_max_ts_date# - interval''24 hours''
					) sl	
					left outer join	(select distinct 
										host_name, 
										process_id, 
										start_ts
								from
									#schema_name#.p_threadinfo
								where
									thread_id = -1 and
									ts >= #v_max_ts_date# - interval''24 hours'' and
									process_name = ''tabprotosrv''
								) tinfo on (tinfo.host_name = sl.spawner_host_name and 
											tinfo.process_id = sl.spawned_tabproto_process_id)
					where
						sl.keep_this_line
				)

				select 
						  p_id		
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
						, "user"
						, substr("user", position(''\\\\'' in "user") + 1) as username_without_domain
						, k
						, v						
						, decode(spawner_process_type, ''vizqlserver'', case when start_ts = min(start_ts) over (partition by spawner_process_type, spawner_session, spawned_tabproto_process_id_ts, host_name, process_id) then
								spawner_session
							else ''-'' 
						  end, null) as parent_vizql_session
						 , decode(spawner_process_type, ''dataserver'', case when start_ts = min(start_ts) over (partition by spawner_process_type, spawner_session, spawned_tabproto_process_id_ts, host_name, process_id) then
								spawner_session
							else ''-''
						  end, null) as parent_dataserver_session
						, spawned_tabproto_process_id_ts						
						, spawner_ts_destroy_sess						
						, spawner_process_type
				from
					(
					select 	
							  s_spawner.spawner_process_type
							, s_spawner.spawner_session		
							, s_spawner.spawned_tabproto_process_id_ts
							, s_spawner.spawner_ts_destroy_sess
							, s_spawner.start_ts
							, s_tabproto.p_id	
							, s_tabproto.p_filepath
							, s_tabproto.filename
							, s_tabproto.host_name
							, s_tabproto.ts
							, s_tabproto.pid as process_id
							, s_tabproto.tid as thread_id
							, s_tabproto.sev
							, s_tabproto.req
							, s_tabproto.sess
							, s_tabproto.site
							, s_tabproto.user							
							, s_tabproto.k
							, s_tabproto.v
							, row_number() over (partition by s_tabproto.p_id order by s_spawner.spawned_tabproto_process_id_ts desc, 
																					   s_spawner.start_ts desc) rn 
					from
						#schema_name#.serverlogs s_tabproto
						left outer join t_s_spawner s_spawner on (s_tabproto.host_name = s_spawner.spawner_host_name and 
																 s_tabproto.pid = s_spawner.spawned_tabproto_process_id and 
																 s_tabproto.ts >= s_spawner.spawned_tabproto_process_id_ts and 
																 s_tabproto.ts >= s_spawner.start_ts)
					where
						substr(s_tabproto.filename, 1, 11) = ''tabprotosrv'' and
						s_tabproto.p_id > coalesce((select max(serverlogs_id)
														from 
															#schema_name#.p_serverlogs_kgz
														where 
															  substr(filename, 1, 11) = ''tabprotosrv'')
													,0)
					) a
				where 
					rn = 1
				'
				;

		
		v_sql := replace(v_sql, '#schema_name#', p_schema_name);
		v_sql := replace(v_sql, '#v_max_ts_date#', v_max_ts_date);
		
		raise notice 'I: %', v_sql;

		execute v_sql;		
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;			

		return v_num_inserted;

END;
$$ LANGUAGE plpgsql;