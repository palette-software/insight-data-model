CREATE or replace function load_s_cpu_usage_agg_report(p_schema_name text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;	
	v_max_ts_date_p_cpu_usage_agg_report text;
	v_sql_cur text;
BEGIN	

		execute 'truncate table palette.s_cpu_usage_agg_report';

		execute 'set local search_path = ' || p_schema_name;

		v_sql_cur := 'select to_char(coalesce(max(timestamp_utc)::date, date''1001-01-01''), ''yyyy-mm-dd'') from p_cpu_usage_agg_report';		
		execute v_sql_cur into v_max_ts_date_p_cpu_usage_agg_report;
		v_max_ts_date_p_cpu_usage_agg_report := 'date''' || v_max_ts_date_p_cpu_usage_agg_report || '''';
				
		v_sql := 'insert into s_cpu_usage_agg_report 
				(cpu_usage_host_name
		       , cpu_usage_process_name
		       , timestamp_utc
		       , workbook_name
		       , interactor_s_user_id
		       , interactor_s_user_name
		       , interactor_s_user_name_id
		       , interactor_s_user_friendly_name
		       , interactor_s_user_friendly_name_id
		       , interactor_s_user_email
		       , publisher_s_user_email
		       , publisher_s_user_id
		       , publisher_s_user_name
		       , publisher_s_user_friendly_name
		       , publisher_s_user_name_id
		       , publisher_s_user_friendly_name_id
		       , publisher_user_site_id
		       , workbook_id
		       , workbook_name_id
		       , workbook_revision
		       , workbook_name_id_revision
		       , site_name
		       , site_id
		       , project_name
		       , project_id
		       , project_name_id
		       , site_name_id
		       , site_project
		       , cpu_usage_cpu_time_consumption_seconds
		       , cpu_usage_cpu_time_consumption_minutes
		       , cpu_usage_cpu_time_consumption_hours
			   , vizql_session_count
			   )
		select	
			cpu_usage_host_name,
			cpu_usage_process_name,
			date_trunc(''hour'', cpu_usage_ts_rounded_15_secs) as timestamp_utc,
			workbook_name,
			interactor_s_user_id,
			interactor_s_user_name,
			interactor_s_user_name || '' ('' || interactor_s_user_id || '')'' as interactor_s_user_name_id,		
			interactor_s_user_friendly_name,
			interactor_s_user_friendly_name || '' ('' || interactor_s_user_id || '')'' as interactor_s_user_friendly_name_id,
			interactor_s_user_email,
			publisher_s_user_email,
			publisher_s_user_id,
			publisher_s_user_name,
			publisher_s_user_friendly_name,
			publisher_s_user_name || '' ('' || publisher_s_user_id || '')'' as publisher_s_user_name_id,
			publisher_s_user_friendly_name || '' ('' || publisher_s_user_id || '')'' as publisher_s_user_friendly_name_id,	
			publisher_user_site_id,	
			workbook_id,
			workbook_name || '' ('' || workbook_id || '')'' as workbook_name_id,
			workbook_revision,
			workbook_name || '' ('' || workbook_id || '')'' || '' v'' || workbook_revision as workbook_name_id_revision,
			site_name,
			site_id,
			project_name,
			project_id,
			project_name || '' ('' || project_id || '')'' as 	project_name_id,
			site_name || ''('' || site_id || '')'' as 	site_name_id,
			site_name || '':'' || project_name  as 	site_project,
			sum(cpu_usage_cpu_time_consumption_seconds) as cpu_usage_cpu_time_consumption_seconds,
			sum(cpu_usage_cpu_time_consumption_seconds) / 60 as cpu_usage_cpu_time_consumption_minutes,
			sum(cpu_usage_cpu_time_consumption_seconds) / 60 / 60 as cpu_usage_cpu_time_consumption_hours,
			count(distinct 
					case when cpu_usage_process_name = ''vizqlserver'' and 
							   cpu_usage_vizql_session not in (''Non-Interactor Vizql'')
					then 
						cpu_usage_vizql_session 
					end
				   ) as vizql_session_count
		from 
			p_cpu_usage_report
		where
			cpu_usage_ts_rounded_15_secs >= #max_ts_date_p_cpu_usage_agg_report# and
			cpu_usage_max_reporting_granularity
		group by
				date_trunc(''hour'', cpu_usage_ts_rounded_15_secs),
				cpu_usage_host_name,
				cpu_usage_process_name,
				workbook_id,
				workbook_name,
				interactor_s_user_id,
				interactor_s_user_name,
				interactor_s_user_friendly_name,
				publisher_s_user_id,
				publisher_s_user_name,
				publisher_s_user_friendly_name,
				site_name,
				project_name,
				site_id,
				project_id,
				interactor_s_user_email,
				publisher_s_user_email,
				publisher_user_site_id,
				workbook_revision
		';
			
		v_sql := replace(v_sql, '#max_ts_date_p_cpu_usage_agg_report#', v_max_ts_date_p_cpu_usage_agg_report);			

		raise notice 'I: %', v_sql;
		execute v_sql;
		
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
		perform manage_partitions('palette', 'p_cpu_usage_agg_report');
        v_num_inserted := ins_stage_to_dwh(p_schema_name, 'p_cpu_usage_agg_report');
		return v_num_inserted;
END;
$$ LANGUAGE plpgsql;