CREATE or replace function manage_partitions(p_schema_name text, p_table_name text) returns int
AS $$
BEGIN
		
		if p_table_name in ('threadinfo', 'serverlogs', 'p_serverlogs', 'p_threadinfo', 'p_cpu_usage', 'p_cpu_usage_report') then
			select manage_multi_range_partitions(p_schema_name, p_table_name);
		elseif p_table_name in ('p_cpu_usage_agg_report', 'p_interactor_session', 'p_process_class_agg_report', 'p_cpu_usage_bootstrap_rpt', 'p_serverlogs_bootstrap_rpt') then
			select manage_single_range_partitions(p_schema_name, p_table_name);
		else raise notice '--WARNING: No partition management happened for % - wrong table specified?--', p_table_name;
		end if;
		
	return 0;

END;
$$ LANGUAGE plpgsql;