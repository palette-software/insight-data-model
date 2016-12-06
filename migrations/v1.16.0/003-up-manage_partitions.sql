CREATE or replace function manage_partitions(p_schema_name text, p_table_name text) returns int
AS $$
BEGIN
		
		execute 'set search_path = ' || p_schema_name;
		
		if lower(p_table_name) in ('threadinfo', 'serverlogs', 'p_serverlogs', 'p_threadinfo', 'p_threadinfo_delta', 'p_cpu_usage', 'p_cpu_usage_report') then
			perform manage_multi_range_partitions(p_schema_name, p_table_name);
		elsif lower(p_table_name) in ('plainlogs', 'p_interactor_session', 'p_process_class_agg_report', 'p_cpu_usage_bootstrap_rpt', 'p_serverlogs_bootstrap_rpt', 'p_http_requests', 'p_background_jobs', 'p_async_jobs', 'p_desktop_session') then
			perform manage_single_range_partitions(p_schema_name, p_table_name);
		else raise notice '--WARNING: No partition management happened for % - wrong table specified?--', p_table_name;
		end if;
		
	return 0;

END;
$$ LANGUAGE plpgsql;