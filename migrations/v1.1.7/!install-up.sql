set search_path = '#schema_name#';
insert into db_version_meta(version_number) values ('v1.1.6');
alter table p_threadinfo rename column pid to process_id;
alter table p_threadinfo rename column tid to thread_id;
alter table s_cpu_usage rename column pid to process_id;
alter table s_cpu_usage rename column tid to thread_id;
alter table p_cpu_usage rename column pid to process_id;
alter table p_cpu_usage rename column tid to thread_id;
alter table s_cpu_usage_report rename column cpu_usage_pid to cpu_usage_process_id;
alter table s_cpu_usage_report rename column cpu_usage_tid to cpu_usage_thread_id;
alter table p_cpu_usage_report rename column cpu_usage_pid to cpu_usage_process_id;
alter table p_cpu_usage_report rename column cpu_usage_tid to cpu_usage_thread_id;
select create_load_s_cpu_usage_report('#schema_name#');
drop view p_serverlogs;
\i 001-up-p_serverlogs.sql
drop table s_cpu_usage_serverlogs;
\i 002-up-s_cpu_usage_serverlogs.sql
\i 003-up-load_p_thread_info.sql
\i 004-up-load_s_cpu_usage.sql
\i 005-up-load_s_cpu_usage_serverlogs.sql
\i 006-up-p_cpu_usage_report_last_24_hours.sql