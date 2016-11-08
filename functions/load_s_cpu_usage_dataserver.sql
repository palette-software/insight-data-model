CREATE or replace function load_s_cpu_usage_dataserver(p_schema_name text, p_load_date date) returns bigint
AS $$
declare
	v_sql text;
    v_sql_filter text;
	v_num_inserted bigint := 0;
	v_num_inserted_all bigint := 0;
	v_sql_cur text;
	c refcursor;
	rec record;
	v_load_date_txt text := to_char(p_load_date, 'yyyy-mm-dd');
begin		

    execute 'set local search_path = ' || p_schema_name;

    perform check_if_load_date_already_in_table(p_schema_name, 'p_cpu_usage', p_load_date, true);

	v_sql_cur := 'select distinct host_name 
                from 
                    p_threadinfo_delta
				where
                    1 = 1
				    and ts_rounded_15_secs >= date''#v_load_date_txt#''
                    and ts_rounded_15_secs < date''#v_load_date_txt#'' + interval''1 day''
				order by 1
				';		
							
	v_sql_cur := replace(v_sql_cur, '#v_load_date_txt#', v_load_date_txt);			
		
	open c for execute (v_sql_cur);
	loop
		  fetch c into rec;
		  exit when not found;
		  
		v_sql := 
				'insert into s_cpu_usage
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
					session_start_ts,
					session_end_ts,
					session_duration,
					username,	
					h_workbooks_p_id,
					h_projects_p_id,
					publisher_h_users_p_id,
					publisher_h_system_users_p_id,
					h_sites_p_id,
					user_type,
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
					s_serverlogs_compressed slogs
				inner join (select distinct host_name, process_id, thread_id
							from
								p_threadinfo_delta
							where 
                                1 = 1
								and ts_rounded_15_secs >= date''#v_load_date_txt#''
                                and ts_rounded_15_secs <= date''#v_load_date_txt#'' + interval''26 hours''
								and host_name = ''#host_name#''
								and process_name = ''dataserver''
							)  ti
					on  
							ti.host_name = slogs.host_name and
							ti.process_id = slogs.process_id and
							ti.thread_id = slogs.thread_id 
				where
					slogs.process_name = ''dataserver'' and
					slogs.host_name = ''#host_name#''
				),
				t_tri as
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
						   ,memory_usage_bytes
						   ,case when thread_id = -1 then ''Process Level'' else ''Thread Level'' end as process_level
						   ,is_thread_level
						   ,case when is_thread_level = ''Y'' and thread_id = -1 then false else true end as max_reporting_granularity
						   ,start_ts								   
						from
							p_threadinfo_delta
                        left outer join (select p_threadinfo_id
                                    from
                                        p_cpu_usage
                                    where
                                        1 = 1
                                        and host_name = ''#host_name#''
                                        and process_name = ''dataserver''
                                        and ts_rounded_15_secs >= date''#v_load_date_txt#''
                                        and ts_rounded_15_secs <= date''#v_load_date_txt#'' + interval''2 hours''
                                    ) already_in on (already_in.p_threadinfo_id = threadinfo_id)
						where
                            1 = 1
							#load_date_filter#
							and host_name = ''#host_name#''
							and ts_interval_ticks is not null
							and process_name = ''dataserver''
                            and already_in.p_threadinfo_id is null
						)

				SELECT
				  thread_with_sess.p_id,
				  thread_with_sess.ts,  
				  thread_with_sess.ts_rounded_15_secs,
				  thread_with_sess.ts_rounded_15_secs::date as ts_date,
				  DATE_TRUNC(''hour'', thread_with_sess.ts) as ts_day_hour,
				  case when thread_with_sess.parent_vizql_session in (''-'', ''default'') then ''Non-Interactor Vizql'' else thread_with_sess.parent_vizql_session end as vizql_session,
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
				  thread_with_sess.memory_usage_bytes as memory_usage_bytes,    
				  thread_with_sess.process_name,
				  ''Tableau'' as process_owner, 
				  case when process_name in (''dataserver'',							
											  ''tabprotosrv'',
											  ''tdeserver'')
							then ''Y''
							
						when  process_name = ''vizqlserver'' and thread_with_sess.session is not null
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
				  extract(''epoch'' from (whole_session_end_ts - whole_session_start_ts)) as session_duration,
				  thread_with_sess.username, 
				  http_req_wb.h_workbooks_p_id,  
				  http_req_wb.h_projects_p_id,
				  http_req_wb.publisher_h_users_p_id,
				  http_req_wb.publisher_h_system_users_p_id,
				  http_req_wb.h_sites_p_id,
				  http_req_wb.user_type,
				  u.p_id as interactor_h_users_p_id,
				  su.p_id as interactor_h_system_users_p_id,
				  thread_with_sess.max_reporting_granularity,						  
				  case when thread_with_sess.session in (''-'', ''default'') then ''Non-Interactor Dataserver'' else thread_with_sess.session end as dataserver_session,
				  parent_vizql_session as parent_vizql_session,
				  parent_dataserver_session as parent_dataserver_session,
				  spawned_by_parent_ts as spawned_by_parent_ts,
				  parent_vizql_destroy_sess_ts as parent_vizql_destroy_sess_ts,
				  parent_process_type as parent_process_type
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
						   ,tri.memory_usage_bytes
						   ,tri.process_level
						   ,tri.is_thread_level
						   ,max_reporting_granularity
						   ,slogs.session
						   ,slogs.username
						   ,slogs.session_start_ts as slog_session_start_ts
						   ,sites.id as slog_site_id
						    --,row_number() over (partition by tri.p_id order by case when slogs.session_start_ts between tri.start_ts and tri.ts 
						    --													      then 1 
						    --													  else 2 
							--												  end asc, 																		  
							--												  slogs.session_start_ts desc) as rn
							,slogs.parent_vizql_session
							,slogs.parent_dataserver_session
							,slogs.spawned_by_parent_ts
							,slogs.parent_vizql_destroy_sess_ts
							,slogs.parent_process_type
							,slogs.parent_vizql_username
							,slogs.whole_session_start_ts
						    ,slogs.whole_session_end_ts
					from	
						t_tri tri
						left outer join t_slogs slogs ON (
										tri.host_name = slogs.host_name AND
					    				tri.process_id = slogs.process_id AND 
					    				tri.thread_id = slogs.thread_id AND
										slogs.session_start_ts between tri.start_ts and tri.ts + interval ''15 sec'' AND
										tri.ts <= coalesce(slogs.parent_vizql_destroy_sess_ts, tri.ts)
					  				)
						left outer join h_sites sites on (sites.name = slogs.parent_vizql_site and slogs.session_start_ts between sites.p_valid_from and sites.p_valid_to)
				   ) thread_with_sess
                   -- This inner join is for replacing commented row_number() logic above.
                   -- Sadly this is much faster
                   inner join (select
                        			tri2.p_id,
                                    coalesce(max(case when slogs.session_start_ts between tri2.start_ts and tri2.ts 
                                                      then slogs.session_start_ts
            					                end)
                                                ,max(slogs.session_start_ts)
                                            ) as max_session_start_ts                                            
                                    
                            	from	
                            		t_tri tri2
                            		left outer join t_slogs slogs ON (
                            						tri2.host_name = slogs.host_name AND
                            	    				tri2.process_id = slogs.process_id AND 
                            	    				tri2.thread_id = slogs.thread_id AND
                            						slogs.session_start_ts between tri2.start_ts and tri2.ts + interval ''15 sec'' AND
                            						tri2.ts <= coalesce(slogs.parent_vizql_destroy_sess_ts, tri2.ts)
                            	  				)
                                group by
                                    tri2.p_id) rn on (1 = 1
                                                    and thread_with_sess.p_id = rn.p_id
                                                    and coalesce(thread_with_sess.slog_session_start_ts, date''1001-01-01'') = coalesce(rn.max_session_start_ts, date''1001-01-01'')
                                                    )
				   LEFT OUTER JOIN s_http_requests_with_workbooks http_req_wb ON (http_req_wb.vizql_session = thread_with_sess.parent_vizql_session)
				   
				   left outer join h_system_users su on (su.name = thread_with_sess.parent_vizql_username and   												 
				   												 thread_with_sess.slog_session_start_ts between su.p_valid_from and su.p_valid_to
				  												   )												   
				   left outer join h_users u on (u.system_user_id = su.id and
				   										 u.site_id = thread_with_sess.slog_site_id and
				   										 thread_with_sess.slog_session_start_ts between u.p_valid_from and u.p_valid_to										 
				  										 )
				where
					1 = 1 --thread_with_sess.rn = 1
                    #filter#
            ';
			
		    v_sql := replace(v_sql, '#host_name#', rec.host_name);			
            v_sql_filter := replace(v_sql, '#load_date_filter#',
                    ' and ts_rounded_15_secs >= date''#v_load_date_txt#''
                    and ts_rounded_15_secs < date''#v_load_date_txt#'' + interval''1 day''                    
                    ');
            v_sql_filter := replace(v_sql_filter, '#v_load_date_txt#', v_load_date_txt);
            v_sql_filter := replace(v_sql_filter, '#filter#',
                    ' and 1 = 1
                    ');
                    
			raise notice 'I: %', v_sql_filter;
			execute v_sql_filter;
			GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
			v_num_inserted_all := v_num_inserted_all + v_num_inserted;
		  
            v_sql_filter := replace(v_sql, '#load_date_filter#',
                    ' and ts_rounded_15_secs >= date''#v_load_date_txt#'' + interval''24 hours''
                    and ts_rounded_15_secs <= date''#v_load_date_txt#'' + interval''26 hours''
                    ');                    
            v_sql_filter := replace(v_sql_filter, '#filter#',            
                    ' and thread_with_sess.whole_session_end_ts is not null
                    and thread_with_sess.whole_session_start_ts::date = date''#v_load_date_txt#''
                    ');
            v_sql_filter := replace(v_sql_filter, '#v_load_date_txt#', v_load_date_txt);        
                    
            raise notice 'I: %', v_sql_filter;                    
            execute v_sql_filter;
			GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
			v_num_inserted_all := v_num_inserted_all + v_num_inserted;
            
	end loop;
	close c;

	return v_num_inserted_all;
END;
$$ LANGUAGE plpgsql;