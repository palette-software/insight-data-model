alter table s_cpu_usage rename column start_ts to session_start_ts;
alter table s_cpu_usage rename column end_ts to session_end_ts;

alter table p_cpu_usage rename column start_ts to session_start_ts;
alter table p_cpu_usage rename column end_ts to session_end_ts;

alter table s_cpu_usage_report rename column cpu_usage_start_ts to cpu_usage_session_start_ts;
alter table s_cpu_usage_report rename column cpu_usage_end_ts to cpu_usage_session_end_ts;

alter table p_cpu_usage_report rename column cpu_usage_start_ts to cpu_usage_session_start_ts;
alter table p_cpu_usage_report rename column cpu_usage_end_ts to cpu_usage_session_end_ts;

--select create_load_s_cpu_usage_report('#schema_name#');
