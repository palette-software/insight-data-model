CREATE or replace function load_s_serverlogs_tdeserver(p_schema_name text) returns bigint
AS $$
declare	
	v_sql text;
	v_num_inserted bigint;	
	v_sql_cur text;
	v_max_ts_date_p_serverlogs text;	
	v_max_ts_date_p_threadinfo text;
	v_max_ts_p_threadinfo text;	
begin	

			execute 'set local search_path = ' || p_schema_name;
			
			v_sql_cur := 'select to_char((select get_max_ts_date(''#schema_name#'', ''p_serverlogs'')), ''yyyy-mm-dd'')';
			v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);
			execute v_sql_cur into v_max_ts_date_p_serverlogs;
			v_max_ts_date_p_serverlogs := 'date''' || v_max_ts_date_p_serverlogs || '''';
									
			v_sql_cur := 'select to_char((select get_max_ts(''#schema_name#'', ''p_threadinfo'')), ''yyyy-mm-dd hh24:mi:ss.ms'')';
			v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);			
			execute v_sql_cur into v_max_ts_p_threadinfo;
			v_max_ts_p_threadinfo := 'timestamp''' || v_max_ts_p_threadinfo || '''';									
									
			v_sql_cur := 'select to_char((select get_max_ts_date(''#schema_name#'', ''p_threadinfo'')), ''yyyy-mm-dd'')';
			v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);			
			execute v_sql_cur into v_max_ts_date_p_threadinfo;
			v_max_ts_date_p_threadinfo := 'date''' || v_max_ts_date_p_threadinfo || '''';			
			
			v_sql := 'truncate table #schema_name#.s_tde_filename_pids';
			v_sql := replace(v_sql, '#schema_name#', p_schema_name);
			execute v_sql;
			
			v_sql := '
			insert into s_tde_filename_pids 
				(host_name,
				file_prefix,
				pid,
				ts_from,
				ts_to)
			select
				host_name,
				file_prefix,
				pid::bigint,
				ts as ts_from,
				coalesce(lead(ts) over (partition by host_name, file_prefix order by ts), date''9999-12-31'') as ts_to
			from
			(
			  SELECT
			  	host_name,
			    substring(filename FROM ''^[a-z_]+[0-9]+'') AS file_prefix,
			    substr(line, 5) AS pid,
			    ts
			  FROM
			    palette.plainlogs
			  WHERE
			    line LIKE ''pid=%''
			    AND ts > now() :: DATE - 18 
				AND ts <= #max_ts_p_threadinfo# + interval''15 sec''
			  GROUP BY 
			  		host_name,
					substring(filename FROM ''^[a-z_]+[0-9]+''),  		   
					substr(line, 5),
					ts
			) b
			';
			
			v_sql := replace(v_sql, '#max_ts_p_threadinfo#', v_max_ts_p_threadinfo);
			execute v_sql;
			
			analyze s_tde_filename_pids;		
			
			
			v_sql := 'truncate table #schema_name#.s_serverlogs_spawner';
			v_sql := replace(v_sql, '#schema_name#', p_schema_name);
			execute v_sql;
			
			v_sql := '
			insert into s_serverlogs_spawner
                			(spawner_host_name,
							parent_vizql_site,														
							process_name,
							spawner_session,							
							parent_vizql_username,														
							parent_vizql_destroy_sess_ts,																					
							spawner_ts_destroy_sess,
							parent_ds_vizql_session)
					select
							b.spawner_host_name,
							case when b.process_name = ''vizqlserver'' then b.parent_vizql_site
								 when b.process_name = ''dataserver'' then ds.parent_vizql_site
							end as parent_vizql_site,														
							b.process_name,
							b.spawner_session,							
							case when b.process_name = ''vizqlserver'' then b.parent_vizql_username
								 when b.process_name = ''dataserver'' then ds.parent_vizql_username
							end as parent_vizql_username,														
							b.parent_vizql_destroy_sess_ts,																					
							case when b.process_name = ''vizqlserver'' then b.parent_vizql_destroy_sess_ts
						 		 when b.process_name = ''dataserver'' then ds.parent_vizql_destroy_sess_ts
							end as spawner_ts_destroy_sess,
							ds.parent_vizql_session as parent_ds_vizql_session							
					from
					
						(select
	                                slog.host_name as spawner_host_name,
	                                max(slog.site) as parent_vizql_site,
	                                process_name,
									slog.sess as spawner_session,        
									max(slog.username_without_domain) as parent_vizql_username,
	                                max(parent_vizql_destroy_sess_ts) as parent_vizql_destroy_sess_ts
	                    from 
	                        (select host_name,
								 	process_name,
	                                max(site) as site,									
	                                filename,
	                                sess,
									max(username_without_domain) as username_without_domain,
	                                max(case when k = ''destroy-session'' then ts end) as parent_vizql_destroy_sess_ts
	                        from
	                            p_serverlogs
	                        where                            
	                            ts >= (#max_ts_date_p_serverlogs# - interval ''1 day'')
								and ts <= #max_ts_p_threadinfo# + interval''15 sec''
								and process_name not like ''tdeserver%''
							group by
								host_name,
								process_name,
	                            filename,								
	                            sess
								
	                        union all                        
							
	                        select  host_name,
									process_name,
	                                max(site) as site,
	                                filename,
	                                sess,
									max(username_without_domain) as username_without_domain,
	                                max(case when k = ''destroy-session'' then ts end) as parent_vizql_destroy_sess_ts
	                        from
	                            s_serverlogs
	                        where
	                            1 = 1
							group by
								host_name,
	                            filename,
								process_name,
	                            sess
	                        ) slog
							group by
								host_name,
	                            process_name,
	                            sess
						) b
						left outer join 
									(select
												host_name,
												sess,
												max(parent_vizql_destroy_sess_ts) as parent_vizql_destroy_sess_ts,
												max(parent_vizql_session) as parent_vizql_session,
												max(parent_vizql_site) as parent_vizql_site,
												max(parent_vizql_username) as parent_vizql_username
									from (									
													select  host_name,
															sess,
															parent_vizql_destroy_sess_ts,
															parent_vizql_session,
															parent_vizql_site,
															parent_vizql_username
													from
															p_serverlogs
													where
														process_name = ''dataserver'' and
														ts >= #max_ts_date_p_serverlogs# - interval''24 hours'' and
														ts <= #max_ts_p_threadinfo# + interval''15 sec''
													union all
													select  host_name,
															sess,
															parent_vizql_destroy_sess_ts,
															parent_vizql_session,
															parent_vizql_site,
															parent_vizql_username 
													from
															s_serverlogs
													where
														process_name = ''dataserver''
												) u									
									group by
											host_name,
											sess
									) ds on (ds.host_name = b.spawner_host_name and 
                                            ds.sess = b.spawner_session)
				
				';
			
			v_sql := replace(v_sql, '#max_ts_date_p_serverlogs#', v_max_ts_date_p_serverlogs);
			v_sql := replace(v_sql, '#max_ts_p_threadinfo#', v_max_ts_p_threadinfo);
			raise notice 'I: %', v_sql;	
			execute v_sql;		
			analyze s_serverlogs_spawner;
			
			
			v_sql := 'truncate table #schema_name#.s_plainlogs_session_map';
			v_sql := replace(v_sql, '#schema_name#', p_schema_name);
			execute v_sql; 
			
			v_sql := 
			'insert into s_plainlogs_session_map
					(tid,
					sessid,
					first_p_id,
					last_p_id,
					ts_start,
					ts_end,
					session_uid,
					filename,
					file_prefix_to_join)
					select
						tid,
						sessid,
						first_p_id,
						coalesce(lead(first_p_id) over (partition by file_prefix_to_join, session_uid order by ts, p_id) - 1, max_file_p_id) as last_p_id,
						ts_start,
						coalesce(lead(ts) over (partition by file_prefix_to_join, session_uid order by ts, p_id), now()) as ts_end,
						session_uid,
						filename,
						file_prefix_to_join
					from
					(
						select
							p_id,
							pid as tid,
							ts,
							line,
							substr(line, position(''sessionid='' in line) + 10, 36) as sessid,
							lag(p_id) over (partition by filename, pid order by ts, p_id) as first_p_id,
							lag(substr(line, 1, greatest(position('':'' in line) - 1, 1))) over (partition by filename, pid order by ts, p_id) as session_uid,
							lag(ts) over (partition by filename, pid order by ts, p_id) as ts_start,
							filename,
							max(p_id) over (partition by filename) as max_file_p_id,
							--max(ts) over (partition by filename) as max_file_ts,
							/*substring(filename from ''^[a-z_]+[0-9]+'')*/ filename as file_prefix_to_join
						from 
							plainlogs p
						where 
							ts >= (#max_ts_date_p_serverlogs# - interval ''1 day'')
							and ts <= #max_ts_p_threadinfo# + interval''15 sec''
							and filename like ''tdeserver%''
					) t
					where line like ''(queryband%''
				
			';
			
			v_sql := replace(v_sql, '#max_ts_date_p_serverlogs#', v_max_ts_date_p_serverlogs);			
			v_sql := replace(v_sql, '#max_ts_p_threadinfo#', v_max_ts_p_threadinfo);
			raise notice 'I: %', v_sql;	
			execute v_sql;			
			analyze s_plainlogs_session_map;
						
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
			
											
				select * 
				from 
					(select 
							p_id,
							pl.p_filepath,
							pl.filename,
							substr(pl.filename, 1, 9) as process_name,
							pl.host_name,
							pl.ts,
							pl.process_id as pid,
							pl.pid as tid,
							null as sev,
							null as req,
							sm.sessid as sess,
							null as site,
							null as user,
							null as username_without_domain,
							null as k,
							pl.line as v,														
							case 
								when sp.process_name = ''vizqlserver'' then sm.sessid 
								when sp.process_name = ''dataserver'' then sp.parent_ds_vizql_session
							end as parent_vizql_session,							
							sp.spawner_ts_destroy_sess as parent_vizql_destroy_sess_ts,							
							case when sp.process_name = ''dataserver'' then sm.sessid end as parent_dataserver_session,
							sm.ts_start as spawned_by_parent_ts,							
							sp.process_name as parent_process_type,														
							sp.parent_vizql_site as parent_vizql_site,							
							sp.parent_vizql_username as parent_vizql_username,														
							case when sp.process_name = ''dataserver'' then sp.parent_vizql_site end as parent_dataserver_site,
							case when sp.process_name = ''dataserver'' then sp.parent_vizql_username end as parent_dataserver_username,
							pl.elapsed_ms,
							pl.start_ts					
					from
						(select pl0.*, 
								p.pid as process_id,								
								/*substring(pl0.filename from ''^[a-z_]+[0-9]+'')*/ filename as file_prefix_to_join,
								substr(line, 1, greatest(position('':'' in line) - 1, 1)) as session_uid
                          from 
						  		plainlogs pl0
                     	  		left outer join s_tde_filename_pids p on (pl0.host_name = p.host_name and
																		substring(pl0.filename from ''^[a-z_]+[0-9]+'') = p.file_prefix and
						  										  		pl0.ts >= p.ts_from and 
																		pl0.ts < p.ts_to
						  										  		)
						  
                    	  where   
						  		pl0.filename like ''tdeserver%'' and
								-- todo: is interval - 1 day really needed?
								pl0.ts >= #max_ts_date_p_serverlogs# - interval ''1 day'' and
								pl0.ts <= #max_ts_p_threadinfo# + interval''15 sec''
                 		) pl
						left join s_plainlogs_session_map sm on pl.file_prefix_to_join = sm.file_prefix_to_join
						  							and pl.session_uid = sm.session_uid
													and pl.ts >= sm.ts_start 
													and pl.ts < sm.ts_end
													
						left join s_serverlogs_spawner sp on sp.spawner_session = sm.sessid
						
					where 1 = 1 -- pl.ts >= #max_ts_date_p_serverlogs# - interval ''1 day''
						  -- and pl.ts < now()::date + 2
							--and 
							--pl.filename like ''tdeserver%''
                            --and pl.rn = 1
			) t 
			where 
				t.ts >= #max_ts_date_p_serverlogs#				
			';
			
		v_sql := replace(v_sql, '#max_ts_date_p_serverlogs#', v_max_ts_date_p_serverlogs);
		v_sql := replace(v_sql, '#max_ts_date_p_threadinfo#', v_max_ts_date_p_threadinfo);
		v_sql := replace(v_sql, '#max_ts_p_threadinfo#', v_max_ts_p_threadinfo);
		
		raise notice 'I: %', v_sql;	

		execute v_sql;		
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;			

		return v_num_inserted;

END;
$$ LANGUAGE plpgsql;