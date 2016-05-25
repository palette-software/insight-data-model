CREATE or replace function load_p_interactor_session_agg_cpu_usage(p_schema_name text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;	
	v_max_ts_date_p_interactor_session_agg_cpu_usage text;
	v_sql_cur text;
BEGIN	

		v_sql_cur := 'select to_char(coalesce(max(session_start_ts)::date, date''1001-01-01''), ''yyyy-mm-dd'') from #schema_name#.p_interactor_session_agg_cpu_usage';
		v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);		
		execute v_sql_cur into v_max_ts_date_p_interactor_session_agg_cpu_usage;
		v_max_ts_date_p_interactor_session_agg_cpu_usage := 'date''' || v_max_ts_date_p_interactor_session_agg_cpu_usage || '''';
				
		v_sql_cur := 'delete from #schema_name#.p_interactor_session_agg_cpu_usage where timestamp_utc::date >= #max_ts_date_p_interactor_session_agg_cpu_usage#';
		v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);		
		v_sql_cur := replace(v_sql_cur, '#max_ts_date_p_interactor_session_agg_cpu_usage#', v_max_ts_date_p_interactor_session_agg_cpu_usage);				

		raise notice 'I: %', v_sql_cur;
		execute v_sql_cur;

		v_sql := 'INSERT INTO #schema_name#.p_interactor_session_agg_cpu_usage
		(
			vizql_session, 
			process_name,
			host_name,
			cpu_time_consumption_seconds,
			session_start_ts,
			session_end_ts,
			session_duration,
			publisher_name,
			interactor_name,
			site_name,
			project_name,
			workbook_name,
			workbook_revision,
			http_user_agent
		)
		SELECT  
		        cpu_usage_parent_vizql_session AS vizql_session,
		        cpu_usage_process_name AS process_name,
		        MIN(cpu_usage_host_name) AS host_name,
		        SUM(cpu_usage_cpu_time_consumption_seconds) AS cpu_time_consumption_seconds,
		        MIN(session_start_ts) AS session_start_ts,
		        MIN(session_end_ts) AS session_end_ts,
		        MIN(session_end_ts) - MIN(session_start_ts) AS session_duration,
		        MIN(publisher_s_user_friendly_name) || '' ('' || MIN(publisher_s_user_id) || '')'' AS publisher_friendly_name_id,
		        MIN(publisher_s_user_name) || '' ('' || MIN(publisher_s_user_id) || '')'' AS publisher_user_name_id,
		        MIN(interactor_s_user_friendly_name) || '' ('' || MIN(interactor_s_user_id) || '')'' AS interactor_friendly_name_id,
		        MIN(interactor_s_user_name) || '' ('' || MIN(interactor_s_user_id) || '')'' AS interactor_user_name_id,
		        MIN(site_name_id) AS site_name_id,
		        MIN(project_name_id) AS project_name_id,
		        MIN(workbook_name_id) AS workbook_name_id,
		        MIN(workbook_revision) AS workbook_revision,
		        MIN(num_fatal) AS num_fatal,
		        MIN(num_error) AS num_error,
		        MIN(num_warn) AS num_warn
		FROM    
		        #schema_name#.p_cpu_usage_report pcur
		        LEFT OUTER JOIN (SELECT vizql_session, MIN(http_user_agent) AS http_user_agent FROM #schema_name#.p_http_requests GROUP BY vizql_session) user_agents
		                ON (pcur.cpu_usage_parent_vizql_session = user_agents.vizql_session)
		        LEFT OUTER JOIN (
		                SELECT  
		                        parent_vizql_session AS vizql_session,
		                        process_name, 
		                        SUM(CASE WHEN sev = ''fatal'' THEN 1 ELSE 0 END) num_fatal,
		                        SUM(CASE WHEN sev = ''error'' THEN 1 ELSE 0 END) num_error,
		                        SUM(CASE WHEN sev = ''warn'' THEN 1 ELSE 0 END) num_warn
		                FROM 
		                        #schema_name#.p_serverlogs
		                WHERE ts >= #max_ts_date_p_interactor_session_agg_cpu_usage# - 1
		                GROUP BY parent_vizql_session, process_name
		        ) num_loglevels
		                ON (pcur.cpu_usage_parent_vizql_session = num_loglevels.vizql_session AND pcur.cpu_usage_process_name = num_loglevels.process_name)
		WHERE cpu_usage_ts_rounded_15_secs >= #max_ts_date_p_interactor_session_agg_cpu_usage#
		        AND cpu_usage_parent_vizql_session IS NOT NULL
		GROUP BY cpu_usage_parent_vizql_session, cpu_usage_process_name;
		';


			v_sql := replace(v_sql, '#schema_name#', p_schema_name);			
			v_sql := replace(v_sql, '#max_ts_date_p_interactor_session_agg_cpu_usage#', v_max_ts_date_p_interactor_session_agg_cpu_usage);			

			raise notice 'I: %', v_sql;
			execute v_sql;
			
			GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
			
			return v_num_inserted;
END;
$$ LANGUAGE plpgsql;
