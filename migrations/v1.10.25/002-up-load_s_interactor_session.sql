CREATE OR REPLACE FUNCTION load_s_interactor_session(p_schema_name text)
RETURNS bigint AS
$BODY$
declare
	v_sql text;
	v_num_inserted bigint;	
	v_from text;
	v_to text;
	v_sql_cur text;
BEGIN	

		execute 'set local search_path = ' || p_schema_name;
	
		v_sql_cur := 'select to_char(coalesce(max(session_start_ts)::date, date''1001-01-01''), ''yyyy-mm-dd'') from p_interactor_session';	
		execute v_sql_cur into v_from;
		v_from := 'date''' || v_from || '''';		
				
		v_sql_cur := 'select 
							to_char(coalesce(min(session_start_ts), #v_from# + 2), ''yyyy-mm-dd hh24:mi:ss.ms'')
					  from
					  		p_cpu_usage_report
					  where
					  		session_start_ts >= #v_from# + 2 and
					  		cpu_usage_ts_rounded_15_secs >= #v_from# and
		        			cpu_usage_parent_vizql_session IS NOT NULL		
					';
					
		v_sql_cur := replace(v_sql_cur, '#v_from#', v_from);
		execute v_sql_cur into v_to;
		v_to := 'timestamp''' || v_to || '''';								
			
		v_sql := 'INSERT INTO s_interactor_session
		(
			vizql_session, 
			process_name,
			host_name,
			cpu_time_consumption_seconds,
			session_start_ts,
			session_end_ts,
			session_duration,
            publisher_id,
			publisher_friendly_name_id,
			publisher_user_name_id,
            interactor_id,
			interactor_friendly_name_id,
			interactor_user_name_id,
            site_id,
			site_name_id,
            project_id,
			project_name_id,
            workbook_id,
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
			user_type,
			currentsheet,						
			http_referer,
			http_request_uri,
			remote_ip,
			user_ip,
			user_cookie,
			status,
			first_show_created_at,
            view_id
		)
		WITH rownofilt AS (
			SELECT 
				rowno.*,
				case when action = ''show'' then row_number() over (partition by vizql_session order by action desc, created_at asc) end AS rn_show_action
			FROM
				(
					SELECT 
						vizql_session, 
						action, 
						created_at, 
						completed_at, 
						row_number() over (partition by vizql_session order by created_at asc) AS rn,
						currentsheet,						
						http_referer,
						http_request_uri,
						remote_ip,
						user_ip,
						user_cookie,
						status,
						http_user_agent,
                        view_id
					FROM p_http_requests
				) rowno	
			WHERE 
				created_at >= #v_from# -1 and
				created_at <= #v_to# + interval ''1 day'' and 
				action in (''show'', ''bootstrapSession'')
			)
		SELECT  
		        cpu_usage_parent_vizql_session AS vizql_session,
		        cpu_usage_process_name AS process_name,
		        MIN(cpu_usage_host_name) AS host_name,
		        SUM(cpu_usage_cpu_time_consumption_seconds) AS cpu_time_consumption_seconds,
		        MIN(session_start_ts) AS session_start_ts,
		        MIN(session_end_ts) AS session_end_ts,
		        MIN(session_duration) as session_duration,
                MIN(publisher_s_user_id) as publisher_id,
		        MIN(publisher_s_user_friendly_name) || '' ('' || MIN(publisher_s_user_id) || '')'' AS publisher_friendly_name_id,
		        MIN(publisher_s_user_name) || '' ('' || MIN(publisher_s_user_id) || '')'' AS publisher_user_name_id,
                MIN(interactor_s_user_id) as interactor_id,
		        MIN(interactor_s_user_friendly_name) || '' ('' || MIN(interactor_s_user_id) || '')'' AS interactor_friendly_name_id,
		        MIN(interactor_s_user_name) || '' ('' || MIN(interactor_s_user_id) || '')'' AS interactor_user_name_id,
		        MIN(site_id) as site_id,
                MIN(site_name_id) AS site_name_id,
                MIN(project_id) as project_id,
		        MIN(project_name_id) AS project_name_id,
                MIN(workbook_id) as workbook_id,
		        MIN(workbook_name_id) AS workbook_name_id,
		        MIN(workbook_revision) AS workbook_revision,
				MIN(http_user_agent) AS http_user_agent,
		        MIN(num_fatal) AS num_fatal,
		        MIN(num_error) AS num_error,
		        MIN(num_warn) AS num_warn,
				CASE WHEN MIN(process_name) != ''vizqlserver'' THEN NULL
					WHEN MIN(http_user_agent) IS NULL THEN NULL /* if we don''t have a value on http_user_agent, then there isn''t the given vizql session in the p_http_requests table so it should be null. */
					WHEN MIN(normal) IS NULL OR MIN(normal) != 2 THEN FALSE /* if there is a vizql session there, but has no show or bootstrap actions, its value will be null, but it is not a normal vizql session, so it should be false */
					ELSE TRUE 
				END AS init_show_bootstrap_normal,
				CASE WHEN MIN(process_name) != ''vizqlserver'' THEN NULL
					WHEN MIN(http_user_agent) IS NULL THEN NULL 
					WHEN MIN(show_count) is NULL THEN 0
					ELSE MIN(show_count) 
				END	AS show_count,
				CASE WHEN MIN(process_name) != ''vizqlserver'' THEN NULL
					WHEN MIN(http_user_agent) IS NULL THEN NULL 
					WHEN MIN(bootstrap_count) is NULL THEN 0
					ELSE MIN(bootstrap_count) 
				END  AS bootstrap_count,
				CASE WHEN MIN(process_name) != ''vizqlserver'' THEN NULL
					WHEN MIN(show_count) = 0 THEN NULL 
					ELSE MIN(show_elapsed_secs) 
				END AS show_elapsed_secs,
				CASE WHEN MIN(process_name) != ''vizqlserver'' THEN NULL
					WHEN MIN(bootstrap_count) = 0 THEN NULL 
					ELSE MIN(bootstrap_elapsed_secs) 
				END AS bootstrap_elapsed_secs,
				CASE WHEN MIN(process_name) != ''vizqlserver'' THEN NULL
					WHEN MIN(bootstrap_count) = 0 or MIN(show_count) = 0 THEN NULL
					ELSE MIN(show_bootstrap_delay_secs) 
				END AS show_bootstrap_delay_secs,
				MIN(cpu_usage_user_type) as user_type,
				MIN(currentsheet) as currentsheet,
				MIN(http_referer) as http_referer,
				MIN(http_request_uri) as http_request_uri,
				MIN(remote_ip) as remote_ip,
				MIN(user_ip) as user_ip,
				MIN(user_cookie) as user_cookie,
				MIN(status) as status,
				MIN(first_show_created_at) as first_show_created_at,
                MIN(view_id) as view_id
		FROM    
		        p_cpu_usage_report pcur        
		        LEFT OUTER JOIN (
		                SELECT  
		                        parent_vizql_session AS vizql_session,
		                        process_name, 
		                        SUM(CASE WHEN sev = ''fatal'' THEN 1 ELSE 0 END) num_fatal,
		                        SUM(CASE WHEN sev = ''error'' THEN 1 ELSE 0 END) num_error,
		                        SUM(CASE WHEN sev = ''warn'' THEN 1 ELSE 0 END) num_warn
		                FROM 
		                        p_serverlogs
		                WHERE 
								ts >= #v_from# - 1 and
								ts <= #v_to# + interval''1 day''
		                GROUP BY parent_vizql_session, process_name
		        ) num_loglevels
		                ON (pcur.cpu_usage_parent_vizql_session = num_loglevels.vizql_session AND pcur.cpu_usage_process_name = num_loglevels.process_name)
				LEFT OUTER JOIN (
						SELECT ro.vizql_session, 
								sum(case when (ro.action = ''show'' and ro.rn = 1) or (ro.action = ''bootstrapSession'' and ro.rn = 2) then 1 else 0 end) as normal,
								sum(case when ro.action = ''bootstrapSession'' then 1 else 0 end) as bootstrap_count,
								sum(case when ro.action = ''show'' then 1 else 0 end) as show_count,
								min(case when rn_show_action = 1 then currentsheet end) as currentsheet,
								min(case when rn_show_action = 1 then created_at end) as created_at,
								min(case when rn_show_action = 1 then http_referer end) as http_referer,
								min(case when rn_show_action = 1 then http_request_uri end) as http_request_uri,
								min(case when rn_show_action = 1 then remote_ip end) as remote_ip,
								min(case when rn_show_action = 1 then user_ip end) as user_ip,
								min(case when rn_show_action = 1 then user_cookie end) as user_cookie,
								min(case when rn_show_action = 1 then status end) as status,
								min(case when rn_show_action = 1 then http_user_agent end) as http_user_agent,
								min(case when rn_show_action = 1 then created_at end) as first_show_created_at,
                                min(case when rn_show_action = 1 then view_id end) as view_id
						FROM rownofilt ro
						GROUP BY vizql_session
					) actions1
					ON (actions1.vizql_session = pcur.cpu_usage_parent_vizql_session)
				LEFT OUTER JOIN (
						SELECT vizql_session,
								extract(''epoch'' from (min(rored.completed_at) - min(rored.created_at))) as show_elapsed_secs,
								extract(''epoch'' from (max(rored.completed_at) - max(rored.created_at))) as bootstrap_elapsed_secs,
								case when extract(''epoch'' from (max(rored.created_at) - min(rored.completed_at))) > 0 then extract(''epoch'' from (max(rored.created_at) - min(rored.completed_at))) else null end as show_bootstrap_delay_secs
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
		WHERE 
			  session_start_ts >= #v_from# and
			  session_start_ts <= #v_to# and
			  cpu_usage_ts_rounded_15_secs >= #v_from# - 1 and
			  cpu_usage_ts_rounded_15_secs <= #v_to# + interval''1 day'' and
		      cpu_usage_parent_vizql_session IS NOT NULL
		GROUP BY cpu_usage_parent_vizql_session, cpu_usage_process_name;
		';
			
		v_sql := replace(v_sql, '#v_from#', v_from);
		v_sql := replace(v_sql, '#v_to#', v_to);
		
		raise notice 'I: %', v_sql;
		execute v_sql;
		
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
		return v_num_inserted;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY INVOKER;