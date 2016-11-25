\set ON_ERROR_STOP on

set search_path = '#schema_name#';

BEGIN;

\i handle_privileges.sql
select handle_privileges('#schema_name#');

set role = palette_#schema_name#_updater;

-- Create tables

\i db_version_meta.sql
\i serverlogs.sql
\i threadinfo.sql
\i plainlogs.sql
\i historical_events.sql
\i http_requests.sql
\i historical_event_types.sql
\i historical_disk_usage.sql
\i hist_views.sql
\i hist_workbooks.sql
\i hist_users.sql
\i hist_tags.sql
\i hist_tasks.sql
\i hist_sites.sql
\i hist_schedules.sql
\i hist_licensing_roles.sql
\i hist_projects.sql
\i hist_groups.sql
\i hist_datasources.sql
\i hist_configs.sql
\i hist_data_connections.sql
\i hist_comments.sql
\i h_workbooks.sql
\i hist_capabilities.sql
\i h_views.sql
\i h_user_default_customized_views.sql
\i h_users.sql
\i h_tasks.sql
\i h_subscriptions_workbooks.sql
\i h_system_users.sql
\i h_subscriptions_customized_views.sql
\i h_subscriptions_views.sql
\i h_subscriptions.sql
\i h_sites.sql
\i h_projects.sql
\i h_schedules.sql
\i h_permission_reasons.sql
\i h_next_gen_permissions.sql
\i h_monitoring_dataengine.sql
\i h_monitoring_postgresql.sql
\i h_groups.sql
\i h_group_users.sql
\i h_extracts.sql
\i h_datasources.sql
\i h_core_licenses.sql
\i h_data_connections.sql
\i h_capabilities.sql
\i h_capability_roles.sql
\i async_jobs.sql
\i background_jobs.sql
\i countersamples.sql
\i genFromDBModel.sql
\i p_serverlogs.sql
\i s_serverlogs.sql
\i create_s_cpu_usage.sql
select create_s_cpu_usage('#schema_name#');
\i create_p_http_requests.sql
select create_p_http_requests('#schema_name#');
\i create_p_background_jobs.sql
select create_p_background_jobs('#schema_name#');
\i create_p_cpu_usage_report.sql
select create_p_cpu_usage_report('#schema_name#');
\i create_s_cpu_usage_report.sql
select create_s_cpu_usage_report('#schema_name#');
\i create_p_cpu_usage_bootstrap_rpt.sql
select create_p_cpu_usage_bootstrap_rpt('#schema_name#');
\i s_cpu_usage_bootstrap_rpt.sql
\i create_p_serverlogs_bootstrap_rpt.sql
select create_p_serverlogs_bootstrap_rpt('#schema_name#');
\i s_serverlogs_bootstrap_rpt.sql
\i p_cpu_usage_agg_report.sql
\i s_cpu_usage_agg_report.sql
\i p_interactor_session.sql
\i s_interactor_session.sql
\i p_process_class_agg_report.sql
\i s_process_class_agg_report.sql
\i s_http_requests_with_workbooks.sql
\i s_serverlogs_compressed.sql
\i s_cpu_usage_dist_dims.sql
\i s_plainlogs_session_map.sql
\i s_serverlogs_spawner.sql
\i s_tde_filename_pids.sql
\i p_process_classification.sql

\i create_s_tables.sql
select create_s_tables('#schema_name#');

-- Create view scripts
\i p_interactor_session_normal.sql
\i p_processinfo.sql
\i p_serverlogs_report.sql
\i p_tdeserver_cpu_coverage.sql
\i p_workbook_datasource_size.sql


-- Create view pgplsq scripts
\i create_tableau_repo_views.sql
\i create_create_view_p_datasources.sql
\i create_create_view_p_workbooks.sql

-- Execute create view pgplsq scripts
select create_tableau_repo_views('#schema_name#');
select create_view_p_datasources('#schema_name#');
select create_view_p_workbooks('#schema_name#');

-- Create pgplsql load proc
\i ins_stage_to_dwh.sql
\i load_from_stage_to_dwh_multi_range_part.sql
\i load_from_stage_to_dwh_single_range_part.sql
\i load_from_stage_to_dwh.sql
\i load_p_threadinfo.sql
\i load_s_cpu_usage_agg_report.sql
\i load_s_cpu_usage_dataserver.sql
\i load_s_cpu_usage_rest.sql
\i load_s_cpu_usage_tabproto.sql
\i load_s_cpu_usage_tdeserver.sql
\i load_s_cpu_usage_vizql.sql
\i load_s_http_requests_with_workbooks.sql
\i load_s_interactor_session.sql
\i load_s_process_class_agg_report.sql
\i load_s_serverlogs_bootstrap_rpt.sql
\i load_s_serverlogs_dataserver.sql
\i load_s_serverlogs_dataserver_compressed.sql
\i load_s_serverlogs_rest.sql
\i load_s_serverlogs_tabproto.sql
\i load_s_serverlogs_tabproto_compressed.sql
\i load_s_serverlogs_tdeserver.sql
\i load_s_serverlogs_vizql.sql
\i load_s_serverlogs_vizql_compressed.sql
\i delete_recent_records_from_p_serverlogs.sql
\i insert_p_serverlogs_from_s_serverlogs.sql
\i handle_utc_midnight_interactor_sess.sql

-- Create creator pgplsql load proc
\i create_load_p_background_jobs.sql
\i create_load_p_http_requests.sql
\i create_load_s_cpu_usage_bootstrap_rpt.sql
\i create_load_s_cpu_usage_report.sql

-- Execute create creator pgplsql load proc
select create_load_p_background_jobs('#schema_name#');
select create_load_p_http_requests('#schema_name#');
select create_load_s_cpu_usage_bootstrap_rpt('#schema_name#');
select create_load_s_cpu_usage_report('#schema_name#');

-- Rest of the plsql proc
\i get_max_ts.sql
\i get_max_ts_date.sql
\i does_part_exist.sql
\i is_subpart_template_same.sql
\i manage_multi_range_partitions.sql
\i manage_single_range_partitions.sql
\i manage_partitions.sql
\i drop_child_indexes.sql

CREATE INDEX p_cpu_usage_bootstrap_rpt_parent_vizql_session_idx ON p_cpu_usage_bootstrap_rpt (cpu_usage_parent_vizql_session);
CREATE INDEX p_cpu_usage_report_cpu_usage_parent_vizql_session_idx ON p_cpu_usage_report (cpu_usage_parent_vizql_session);
CREATE INDEX p_serverlogs_bootstrap_rpt_parent_vizql_session_idx ON p_serverlogs_bootstrap_rpt (parent_vizql_session);

select handle_privileges('#schema_name#');

insert into db_version_meta(version_number) values ('v1.10.22');

COMMIT;