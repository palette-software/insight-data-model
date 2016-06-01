CREATE or replace function load_s_cpu_usage_tabproto(p_schema_name text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;
	v_num_inserted_all bigint;
	v_sql_cur text;
	c refcursor;
	rec record;
	v_max_ts_date text;
begin	

			v_sql_cur := 'select to_char((select #schema_name#.get_max_ts_date(''#schema_name#'', ''p_cpu_usage'')), ''yyyy-mm-dd'')';
			v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);
		
			execute v_sql_cur into v_max_ts_date;
			v_max_ts_date := 'date''' || v_max_ts_date || '''';

			v_sql_cur := 'select distinct ''date'''''' || to_char(ts::date, ''yyyy-mm-dd'') || '''''''' as ts_date, host_name from #schema_name#.p_threadinfo
						  where
						  	ts_rounded_15_secs >= #v_max_ts_date#
						 order by 1, 2
						';	
						
			v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);
			v_sql_cur := replace(v_sql_cur, '#v_max_ts_date#', v_max_ts_date);			
			
			v_num_inserted_all := 0;
			
			open c for execute (v_sql_cur);
			loop
				  fetch c into rec;
				  exit when not found;
				  
				v_sql := 
						'insert into #schema_name#.s_cpu_usage
						(	
							p_threadinfo_id,
							ts,
							ts_rounded_15_secs,
							ts_date,
							ts_day_hour,
							vizql_session,
							repository_url,
							user_ip,
							site_id,
							workbook_id,		
							cpu_time_consumption_ticks,
							cpu_time_consumption_seconds,
							cpu_time_consumption_minutes,
							cpu_time_consumption_hours,		
							ts_interval_ticks,
							cpu_core_consumption,
							memory_usage_bytes,				
							process_name,
							process_owner,
							is_allocatable,
							process_level,
							is_thread_level,				
							host_name,
							process_id,
							thread_id,	
							start_ts,
							end_ts,
							username,	
							h_workbooks_p_id,
							h_projects_p_id,
							publisher_h_users_p_id,
							publisher_h_system_users_p_id,
							h_sites_p_id,
							interactor_h_users_p_id,
							interactor_h_system_users_p_id,
							max_reporting_granularity,
							dataserver_session,
							parent_vizql_session,
							parent_dataserver_session,
							spawned_by_parent_ts,
							parent_vizql_destroy_sess_ts,
							parent_process_type							
						)
								
						with t_slogs as
						(
						select
							slogs.*	
						from 
							#schema_name#.s_serverlogs_compressed slogs
						inner join (select distinct host_name, process_id, -1 as thread_id
									from
										#schema_name#.p_threadinfo
									where 
										ts_rounded_15_secs between #v_act_ts_date# and (#v_act_ts_date# + 1) - interval''1 milliseconds''
										and host_name = ''#host_name#''
										and process_name = ''tabprotosrv''
									)  ti
							on  
									ti.host_name = slogs.host_name and
									ti.process_id = slogs.process_id and
									ti.thread_id = slogs.thread_id
						where
							slogs.process_name = ''tabprotosrv'' and
							slogs.host_name = ''#host_name#''
						)
						
						SELECT
						  thread_with_sess.p_id,
						  thread_with_sess.ts,  
						  thread_with_sess.ts_rounded_15_secs,
						  thread_with_sess.ts_rounded_15_secs::date as ts_date,
						  DATE_TRUNC(''hour'', thread_with_sess.ts) as ts_day_hour,
						  case when parent_process_type = ''vizqlserver'' then
								  	case when thread_with_sess.session in (''-'', ''default'') 
										then 
											''Non-Interactor Vizql'' 
										else 
											thread_with_sess.session
									end
								when  parent_process_type = ''dataserver'' then
									case when thread_with_sess.parent_vizql_session in (''-'', ''default'') 
										then 
											''Non-Interactor Vizql'' 
										else 
											thread_with_sess.parent_vizql_session
									end
						  end as vizql_session,
						  http_req_wb.repository_url,
						  http_req_wb.user_ip,
						  http_req_wb.site_id,
						  http_req_wb.workbook_id,   
						  thread_with_sess.cpu_time_delta_ticks as cpu_time_consumption_ticks,
						  thread_with_sess.cpu_time_delta_ticks::numeric / 10000000 as cpu_time_consumption_seconds,
						  thread_with_sess.cpu_time_delta_ticks::numeric / 10000000 / 60 as cpu_time_consumption_minutes,
						  thread_with_sess.cpu_time_delta_ticks::numeric / 10000000 / 60 / 60 as cpu_time_consumption_hours,        
						  thread_with_sess.ts_interval_ticks,
						  thread_with_sess.cpu_core_consumption,
						  thread_with_sess.memory_usage_delta_bytes as memory_usage_bytes,    
						  thread_with_sess.process_name,
						  case when thread_with_sess.process_name in (''backgrounder'',
													''clustercontroller'',
													''dataserver'',
													''filestore'',
													''httpd'',
													''postgres'',
													''searchserver'',
													''tabadminservice'',
													''tableau'',
													''tabprotosrv'',
													''tabrepo'',
													''tabsvc'',
													''tabsystray'',
													''tdeserver'',
													''vizportal'',
													''vizqlserver'',
													''wgserver'',
													''zookeeper'',
													''tabspawn'',
													''tabadmwrk'',
													''tabadmsvc'',
													''tdeserver64'',
													''tabadmin'',
													''redis-server''
													) then 
									''Tableau''
						  else 
						  			''Non-Tableau''
						  end as process_owner,  
						  case when process_name in (''dataserver'',							
													  ''tabprotosrv'',
													  ''tdeserver'')
									then ''Y''
									
								when process_name = ''vizqlserver'' and thread_with_sess.session is not null
									then ''Y''
						  else 
						  	''N''
						  end as is_allocatable,  
						  thread_with_sess.process_level,
						  thread_with_sess.is_thread_level,			  
						  thread_with_sess.host_name,
						  thread_with_sess.process_id,
						  thread_with_sess.thread_id,  
						  thread_with_sess.whole_session_start_ts as start_ts,
						  thread_with_sess.whole_session_end_ts as end_ts,
						  thread_with_sess.username, 
						  http_req_wb.h_workbooks_p_id,  
						  http_req_wb.h_projects_p_id,
						  http_req_wb.publisher_h_users_p_id,
						  http_req_wb.publisher_h_system_users_p_id,
						  http_req_wb.h_sites_p_id,    
						  u.p_id as interactor_h_users_p_id,
						  su.p_id as interactor_h_system_users_p_id,
						  thread_with_sess.max_reporting_granularity,
						  case when parent_process_type = ''dataserver'' then thread_with_sess.session end as dataserver_session,
						  parent_vizql_session,
						  parent_dataserver_session,
						  spawned_by_parent_ts,
						  parent_vizql_destroy_sess_ts,
						  parent_process_type
						  --thread_with_sess.whole_session_duration as whole_session_duration
						FROM 
							(select
									tri.p_id
							       ,tri.threadinfo_id
							       ,tri.host_name
							       ,tri.process_name
							       ,tri.ts
								   ,tri.ts_rounded_15_secs
							       ,tri.process_id
							       ,tri.thread_id
							       ,tri.cpu_time_ticks
							       ,tri.cpu_time_delta_ticks
							       ,tri.ts_interval_ticks
							       ,tri.cpu_core_consumption
								   ,tri.memory_usage_delta_bytes
								   ,tri.process_level
								   ,tri.is_thread_level
								   ,max_reporting_granularity
								   ,slogs.session
								   ,slogs.username
								   ,slogs.session_start_ts as slog_session_start_ts
								   ,sites.id as slog_site_id
								   ,row_number() over (partition by tri.p_id order by case when slogs.session_start_ts between tri.start_ts and tri.ts 
								   													      then 1 
																						  else 2 
																					  end asc, 																		  
																					  slogs.session_start_ts desc) as rn
									,slogs.parent_vizql_session
									,slogs.parent_dataserver_session
									,slogs.spawned_by_parent_ts
									,slogs.parent_vizql_destroy_sess_ts
									,slogs.parent_process_type
									,slogs.parent_vizql_username
									,slogs.whole_session_start_ts
								    ,slogs.whole_session_end_ts
							from	
								(select 
									p_id
							       ,threadinfo_id
							       ,host_name
							       ,process_name
							       ,ts
								   ,ts_rounded_15_secs
							       ,process_id
							       ,thread_id
							       ,cpu_time_ticks
							       ,cpu_time_delta_ticks
							       ,ts_interval_ticks
							       ,cpu_core_consumption
								   ,memory_usage_delta_bytes
								   ,case when thread_id = -1 then ''Process Level'' else ''Thread Level'' end as process_level
								   ,is_thread_level
								   ,case when is_thread_level = ''Y'' and thread_id = -1 then false else true end as max_reporting_granularity
								   ,start_ts								   
								from
									#schema_name#.p_threadinfo
								where
									ts_rounded_15_secs between #v_act_ts_date# and (#v_act_ts_date# + 1) - interval''1 milliseconds''
									and host_name = ''#host_name#''
									and ts_interval_ticks is not null
									and process_name = ''tabprotosrv''
								) tri
								left outer join t_slogs slogs ON (
												tri.host_name = slogs.host_name AND
							    				tri.process_id = slogs.process_id AND
							    				tri.thread_id = slogs.thread_id AND
												slogs.session_start_ts between tri.start_ts and tri.ts + interval ''15 sec'' AND
												tri.ts <= coalesce(slogs.parent_vizql_destroy_sess_ts, tri.ts)
							  				)
								left outer join #schema_name#.h_sites sites on (sites.name = slogs.parent_vizql_site and slogs.session_start_ts between sites.p_valid_from and sites.p_valid_to)
						   ) thread_with_sess
						   LEFT OUTER JOIN #schema_name#.s_http_requests_with_workbooks http_req_wb ON (http_req_wb.vizql_session = thread_with_sess.parent_vizql_session)
						   
						   left outer join #schema_name#.h_system_users su on (su.name = thread_with_sess.parent_vizql_username and   												 
						   												 thread_with_sess.slog_session_start_ts between su.p_valid_from and su.p_valid_to
						  												   )												   
						   left outer join #schema_name#.h_users u on (u.system_user_id = su.id and
						   										 u.site_id = thread_with_sess.slog_site_id and
						   										 thread_with_sess.slog_session_start_ts between u.p_valid_from and u.p_valid_to										 
						  										 )
						where
							thread_with_sess.rn = 1';

					v_sql := replace(v_sql, '#schema_name#', p_schema_name);
					v_sql := replace(v_sql, '#host_name#', rec.host_name);
					v_sql := replace(v_sql, '#v_act_ts_date#', rec.ts_date);
					
					raise notice 'I: %', v_sql;

					execute v_sql;
				  
					GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
					v_num_inserted_all := v_num_inserted_all + v_num_inserted;
				  
			end loop;
			close c;

		return v_num_inserted_all;
END;
$$ LANGUAGE plpgsql;