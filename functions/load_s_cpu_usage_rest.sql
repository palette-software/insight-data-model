CREATE or replace function load_s_cpu_usage_rest(p_schema_name text) returns bigint
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

			v_sql_cur := 'select distinct host_name from #schema_name#.p_threadinfo
						  where
						  	ts_rounded_15_secs >= #v_max_ts_date#
						 order by 1
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
						
						SELECT
						  tri.p_id,
						  tri.ts,  
						  tri.ts_rounded_15_secs,
						  tri.ts_rounded_15_secs::date as ts_date,
						  DATE_TRUNC(''hour'', tri.ts) as ts_day_hour,
						  null as vizql_session,
						  null as repository_url,
						  null as user_ip,
						  null as site_id,
						  null as workbook_id,   
						  tri.cpu_time_delta_ticks as cpu_time_consumption_ticks,
						  tri.cpu_time_delta_ticks::numeric / 10000000 as cpu_time_consumption_seconds,
						  tri.cpu_time_delta_ticks::numeric / 10000000 / 60 as cpu_time_consumption_minutes,        
						  tri.cpu_time_delta_ticks::numeric / 10000000 / 60 / 60 as cpu_time_consumption_hours,        
						  tri.ts_interval_ticks,
						  tri.cpu_core_consumption,
						  tri.memory_usage_delta_bytes as memory_usage_bytes,    
						  tri.process_name,
						  case when tri.process_name in (''backgrounder'',
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
						  /*case when process_name in (''dataserver'',
													  ''tabprotosrv'',
													  ''tdeserver'')
									then ''Y''
									
								when process_name = ''vizqlserver'' and tri.session is not null
									then ''Y''
							    else 
							  	    ''N''
						  end*/ ''N'' as is_allocatable,  
						  tri.process_level,
						  tri.is_thread_level,			  
						  tri.host_name,
						  tri.process_id,
						  tri.thread_id,  
						  null as /*tst.*/start_ts,
						  null as /*tst.*/end_ts,
						  null as username, 
						  null as h_workbooks_p_id,  
						  null as h_projects_p_id,
						  null as publisher_h_users_p_id,
						  null as publisher_h_system_users_p_id,
						  null as h_sites_p_id,    
						  null as interactor_h_users_p_id,
						  null as interactor_h_system_users_p_id,
						  tri.max_reporting_granularity,						  
						  null as dataserver_session,
						  null as parent_vizql_session,
						  null as parent_dataserver_session,
						  null as spawned_by_parent_ts,
						  null as parent_vizql_destroy_sess_ts,
						  null as parent_process_type
						FROM 
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
								ts_rounded_15_secs >= #v_max_ts_date#
								and host_name = ''#host_name#''
								and ts_interval_ticks is not null
								and process_name not in (''vizqlserver'', ''dataserver'', ''tabprotosrv'')
						) tri'
					;

					v_sql := replace(v_sql, '#schema_name#', p_schema_name);
					v_sql := replace(v_sql, '#host_name#', rec.host_name);
					v_sql := replace(v_sql, '#v_max_ts_date#', v_max_ts_date);
					
					raise notice 'I: %', v_sql;

					execute v_sql;
				  
					GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
					v_num_inserted_all := v_num_inserted_all + v_num_inserted;
				  
			end loop;
			close c;

		return v_num_inserted_all;
END;
$$ LANGUAGE plpgsql;