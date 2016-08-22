alter table p_process_class_agg_report rename to p_process_class_agg_report_old;
\i 005-up-p_process_class_agg_report.sql
\i 005-up-s_process_class_agg_report.sql
select create_s_process_class_agg_report('palette');
insert into s_process_class_agg_report select * from p_process_class_agg_report_old;
select manage_partitions('palette', 'p_process_class_agg_report');

insert into p_process_class_agg_report (
		p_id
       , ts_rounded_15_secs
       , process_name
       , host_name
       , cpu_usage_core_consumption
       , cpu_usage_cpu_time_consumption_seconds
       , cpu_usage_memory_usage_bytes
       , tableau_process
)
SELECT  
		p_id
       , ts_rounded_15_secs
       , process_name
       , host_name
       , cpu_usage_core_consumption
       , cpu_usage_cpu_time_consumption_seconds
       , cpu_usage_memory_usage_bytes
       , tableau_process
 FROM s_process_class_agg_report;
 
 drop table p_process_class_agg_report_old;