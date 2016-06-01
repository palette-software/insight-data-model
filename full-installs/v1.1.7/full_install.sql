\set ON_ERROR_STOP on
create schema #schema_name#;
create role readonly_#schema_name# with login password 'onlyread';
create role palette_looker;
create role palette_updater;
CREATE ROLE palette_#schema_name#_looker;
GRANT  palette_#schema_name#_looker TO palette_looker WITH ADMIN OPTION ;
CREATE ROLE palette_#schema_name#_updater; 
GRANT  palette_#schema_name#_updater TO palette_updater WITH ADMIN OPTION;
grant palette_#schema_name#_looker to readonly_#schema_name#;
grant usage on schema #schema_name# to readonly_#schema_name#;

set search_path = '#schema_name#';
\i create_roles.sql
\i db_version_meta.sql
insert into db_version_meta(version_number) values ('v1.1.7');
\i genFromDBModel.sql
\i p_serverlogs.sql
\i s_http_requests_with_workbooks.sql
\i create_p_background_jobs.sql
select create_p_background_jobs('#schema_name#');
\i create_p_http_requests.sql
select create_p_http_requests('#schema_name#');
\i create_s_cpu_usage.sql
select create_s_cpu_usage('#schema_name#');
\i create_p_cpu_usage_report.sql
select create_p_cpu_usage_report('#schema_name#');
\i create_s_cpu_usage_report.sql
select create_s_cpu_usage_report('#schema_name#');
\i p_workbook_datasource_size.sql
\i create_tableau_repo_views.sql
select create_tableau_repo_views('#schema_name#');
\i manage_partitions.sql
\i load_p_thread_info.sql
\i create_load_p_http_requests.sql
select create_load_p_http_requests('#schema_name#');
\i load_s_http_requests_with_workbooks.sql
\i create_load_p_background_jobs.sql
select create_load_p_background_jobs('#schema_name#');
\i s_cpu_usage_serverlogs.sql
\i load_s_cpu_usage_serverlogs.sql
\i load_s_cpu_usage.sql
\i create_load_s_cpu_usage_report.sql
select create_load_s_cpu_usage_report('#schema_name#');
\i load_from_stage_to_dwh.sql
select grant_objects_to_looker_role('#schema_name#');