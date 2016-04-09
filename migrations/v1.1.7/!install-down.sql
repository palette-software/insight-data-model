\set ON_ERROR_STOP on
set search_path = '#schema_name#';
insert into db_version_meta(version_number) values ('v1.1.6');
\i 001-down-p_cpu_usage_report_last_24_hours.sql
\i 002-down-load_s_cpu_usage.sql