\set ON_ERROR_STOP on
set search_path = '#schema_name#';
insert into db_version_meta(version_number) values ('v1.1.7');
\i 001-up-p_cpu_usage_report_last_24_hours.sql
\i 002-up-load_s_cpu_usage.sql