CREATE OR REPLACE FUNCTION palette.load_p_interactor_session(p_schema_name text)
RETURNS bigint AS
$BODY$
declare
	v_sql text;
	v_num_inserted bigint;	
	v_max_ts_date_p_interactor_session text;
	v_sql_cur text;
BEGIN	

		v_sql_cur := 'select to_char(coalesce(max(session_start_ts)::date, date''1001-01-01''), ''yyyy-mm-dd'') from #schema_name#.p_interactor_session';
		v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);		
		execute v_sql_cur into v_max_ts_date_p_interactor_session;
		v_max_ts_date_p_interactor_session := 'date''' || v_max_ts_date_p_interactor_session || '''';
				
		v_sql_cur := 'delete from #schema_name#.p_interactor_session where session_start_ts::date >= #max_ts_date_p_interactor_session#';
		v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);		
		v_sql_cur := replace(v_sql_cur, '#max_ts_date_p_interactor_session#', v_max_ts_date_p_interactor_session);				

		raise notice 'I: %', v_sql_cur;
		execute v_sql_cur;

		v_sql := 'INSERT INTO #schema_name#.p_interactor_session
		(
			vizql_session, 
			process_name,
			host_name,
			cpu_time_consumption_seconds,
			session_start_ts,
			session_end_ts,
			session_duration,
			publisher_friendly_name_id,
			publisher_user_name_id,
			interactor_friendly_name_id,
			interactor_user_name_id,
			site_name_id,
			project_name_id,
			workbook_name_id,
			workbook_revision,
			http_user_agent,
			num_fatals,
			num_errors,
			num_warnings,
			init_show_bootstrap_normal,
			show_count,
			bootstrap_count,
			show_elapsed_secs,
			bootstrap_elapsed_secs,
			show_bootstrap_delay_secs,
			user_type
		)
		WITH rownofilt AS (
			SELECT 
				rowno.*
			FROM
				(
					SELECT 
						vizql_session, 
						action, 
						created_at, 
						completed_at, 
						row_number() over (partition by vizql_session order by created_at asc) AS rn
					FROM palette.p_http_requests
				) rowno	
			WHERE action = ''show'' OR action = ''bootstrapSession''
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
				MIN(http_user_agent) AS http_user_agent,
		        MIN(num_fatal) AS num_fatal,
		        MIN(num_error) AS num_error,
		        MIN(num_warn) AS num_warn,
				CASE WHEN MIN(process_name) != 'vizqlserver' THEN NULL
					WHEN MIN(http_user_agent) IS NULL THEN NULL /* if we don''t have a value on http_user_agent, then there isn''t the given vizql session in the p_http_requests table so it should be null. */
					WHEN MIN(normal) IS NULL OR MIN(normal) != 2 THEN FALSE /* if there is a vizql session there, but has no show or bootstrap actions, its value will be null, but it is not a normal vizql session, so it should be false */
					ELSE TRUE END
					AS init_show_bootstrap_normal,
				CASE WHEN MIN(process_name) != 'vizqlserver' THEN NULL
					WHEN MIN(http_user_agent) IS NULL THEN NULL 
					WHEN MIN(show_count) is NULL THEN 0
					ELSE MIN(show_count) END
					AS show_count,
				CASE WHEN MIN(process_name) != 'vizqlserver' THEN NULL
					WHEN MIN(http_user_agent) IS NULL THEN NULL 
					WHEN MIN(bootstrap_count) is NULL THEN 0
					ELSE MIN(bootstrap_count) END 
					AS bootstrap_count,
				CASE WHEN MIN(process_name) != 'vizqlserver' THEN NULL
					WHEN MIN(show_count) = 0 THEN NULL 
					ELSE MIN(show_elapsed_secs) END AS show_elapsed_secs,
				CASE WHEN MIN(process_name) != 'vizqlserver' THEN NULL
					WHEN MIN(bootstrap_count) = 0 THEN NULL 
					ELSE MIN(bootstrap_elapsed_secs) END AS bootstrap_elapsed_secs,
				CASE WHEN MIN(process_name) != 'vizqlserver' THEN NULL
					WHEN MIN(bootstrap_count) = 0 or MIN(show_count) = 0 THEN NULL
					ELSE MIN(show_bootstrap_delay_secs) END AS show_bootstrap_delay_secs,
				user_type
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
		                WHERE ts >= #max_ts_date_p_interactor_session# - 1
		                GROUP BY parent_vizql_session, process_name
		        ) num_loglevels
		                ON (pcur.cpu_usage_parent_vizql_session = num_loglevels.vizql_session AND pcur.cpu_usage_process_name = num_loglevels.process_name)
				LEFT OUTER JOIN (
						SELECT ro.vizql_session, 
								sum(case when (ro.action = ''show'' and ro.rn = 1) or (ro.action = ''bootstrapSession'' and ro.rn = 2) then 1 else 0 end) as normal,
								sum(case when ro.action = ''bootstrapSession'' then 1 else 0 end) as bootstrap_count,
								sum(case when ro.action = ''show'' then 1 else 0 end) as show_count
						FROM rownofilt ro
						GROUP BY vizql_session
					) actions1
					ON (actions1.vizql_session = pcur.cpu_usage_parent_vizql_session)
				LEFT OUTER JOIN (
						SELECT vizql_session,
								extract(second from (min(rored.completed_at) - min(rored.created_at))) as show_elapsed_secs,
								extract(second from (max(rored.completed_at) - max(rored.created_at))) as bootstrap_elapsed_secs,
								case when extract(second from (max(rored.created_at) - min(rored.completed_at))) > 0 then extract(second from (max(rored.created_at) - min(rored.completed_at))) else null end as show_bootstrap_delay_secs
						FROM (
							select distinct on (ro.action, ro.vizql_session) action, 
									vizql_session, 
									ro.created_at, 
									ro.completed_at
							from rownofilt ro
							order by ro.action, ro.vizql_session, ro.created_at 
							) rored
						GROUP BY vizql_session
					) actions2
					ON (actions2.vizql_session = pcur.cpu_usage_parent_vizql_session)
		WHERE cpu_usage_ts_rounded_15_secs >= #max_ts_date_p_interactor_session#
		        AND cpu_usage_parent_vizql_session IS NOT NULL
		GROUP BY cpu_usage_parent_vizql_session, cpu_usage_process_name;
		';


			v_sql := replace(v_sql, '#schema_name#', p_schema_name);			
			v_sql := replace(v_sql, '#max_ts_date_p_interactor_session#', v_max_ts_date_p_interactor_session);			

			raise notice 'I: %', v_sql;
			execute v_sql;
			
			GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
			
			return v_num_inserted;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY INVOKER;


