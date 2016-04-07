set search_path = '#schema_name#';
insert into db_version_meta(version_number) values ('v1.1.5');
alter table p_threadinfo rename column process_id to pid;
alter table p_threadinfo rename column thread_id to tid;
alter table s_cpu_usage rename column process_id to pid;
alter table s_cpu_usage rename column thread_id to tid;
alter table p_cpu_usage rename column process_id to pid;
alter table p_cpu_usage rename column thread_id to tid;
alter table s_cpu_usage_report rename column cpu_usage_process_id to cpu_usage_pid;
alter table s_cpu_usage_report rename column cpu_usage_thread_id to cpu_usage_tid;
alter table p_cpu_usage_report rename column cpu_usage_process_id to cpu_usage_pid;
alter table p_cpu_usage_report rename column cpu_usage_thread_id to cpu_usage_tid;
select create_load_s_cpu_usage_report('#schema_name#');
drop view p_serverlogs;
\i 001-down-p_serverlogs.sql
drop table s_cpu_usage_serverlogs;
\i 002-down-s_cpu_usage_serverlogs.sql
\i 003-down-load_p_thread_info.sql
\i 004-down-load_s_cpu_usage.sql
\i 005-down-load_s_cpu_usage_serverlogs.sql
\i 006-down-p_cpu_usage_report_last_24_hours.sql