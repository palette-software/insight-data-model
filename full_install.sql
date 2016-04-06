\set ON_ERROR_STOP on
set search_path = '%SCHEMA_NAME%';
\i create_roles.sql
\i db_version_meta.sql
insert into db_version_meta(version_number) values ('#version_number#');
\i genFromDBModel.SQL
\i p_serverlogs.sql
\i s_http_requests_with_workbooks.sql
\i create_p_background_jobs.sql
select create_p_background_jobs('%SCHEMA_NAME%');
\i create_p_http_requests.sql
select create_p_http_requests('%SCHEMA_NAME%');
\i create_s_cpu_usage.sql
select create_s_cpu_usage('%SCHEMA_NAME%');
\i create_p_cpu_usage_report.sql
select create_p_cpu_usage_report('%SCHEMA_NAME%');
\i create_s_cpu_usage_report.sql
select create_s_cpu_usage_report('%SCHEMA_NAME%');
\i p_workbook_datasource_size.sql
\i create_tableau_repo_views.sql
select create_tableau_repo_views('%SCHEMA_NAME%');
\i manage_partitions.sql
\i load_p_thread_info.sql
\i create_load_p_http_requests.sql
select create_load_p_http_requests('%SCHEMA_NAME%');
\i load_s_http_requests_with_workbooks.sql
\i create_load_p_background_jobs.sql
select create_load_p_background_jobs('%SCHEMA_NAME%');
\i s_cpu_usage_serverlogs.sql
\i load_s_cpu_usage_serverlogs.sql
\i load_s_cpu_usage.sql
\i create_load_s_cpu_usage_report.sql
select create_load_s_cpu_usage_report('%SCHEMA_NAME%');
\i load_from_stage_to_dwh.sql