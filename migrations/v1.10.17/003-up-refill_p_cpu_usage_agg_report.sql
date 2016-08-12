alter table p_cpu_usage_agg_report rename to p_cpu_usage_agg_report_old;
select create_s_cpu_usage_agg_report('palette');
insert into s_cpu_usage_agg_report select * from p_cpu_usage_agg_report_old;
select create_p_cpu_usage_agg_report('palette');
select manage_partitions('palette', 'p_cpu_usage_agg_report');
