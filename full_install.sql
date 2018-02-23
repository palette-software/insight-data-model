\set ON_ERROR_STOP on

set search_path = '#schema_name#';

BEGIN;

\i handle_privileges.sql
select handle_privileges('#schema_name#');

set role = palette_#schema_name#_updater;

-- Create tables

\i db_version_meta.sql
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


-- Recreate agent tables
alter table threadinfo rename to threadinfo_old;

CREATE TABLE threadinfo
(LIKE threadinfo_old INCLUDING DEFAULTS)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (p_id)
PARTITION BY RANGE (ts)
SUBPARTITION BY LIST (host_name)
SUBPARTITION TEMPLATE (SUBPARTITION init VALUES ('init')
WITH (appendonly=true, orientation=column, compresstype=quicklz))
(PARTITION "10010101" START (date '1001-01-01') INCLUSIVE
        END (date '1001-01-02') EXCLUSIVE
WITH (appendonly=true, orientation=column, compresstype=quicklz)
);

alter sequence threadinfo_p_id_seq owned by threadinfo.p_id;
drop table threadinfo_old;


alter table serverlogs rename to serverlogs_old;

CREATE TABLE serverlogs
(LIKE serverlogs_old INCLUDING DEFAULTS)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (p_id)
PARTITION BY RANGE (ts)
SUBPARTITION BY LIST (host_name)
SUBPARTITION TEMPLATE (SUBPARTITION init VALUES ('init')
WITH (appendonly=true, orientation=column, compresstype=quicklz))
(PARTITION "10010101" START (date '1001-01-01') INCLUSIVE
        END (date '1001-01-02') EXCLUSIVE
WITH (appendonly=true, orientation=column, compresstype=quicklz)
);

alter sequence serverlogs_p_id_seq owned by serverlogs.p_id;
drop table serverlogs_old;


alter table plainlogs rename to plainlogs_old;

CREATE TABLE plainlogs (LIKE plainlogs_old INCLUDING DEFAULTS)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (p_id)
PARTITION BY RANGE (ts)
(PARTITION "10010101"
    START (date '1001-01-01') INCLUSIVE
        END (date '1001-01-02') EXCLUSIVE
WITH (appendonly=true, orientation=column, compresstype=quicklz)
);

alter sequence plainlogs_p_id_seq owned by plainlogs.p_id;
drop table plainlogs_old;


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

select handle_privileges('#schema_name#');

insert into db_version_meta(version_number) values ('v#version_number#');

COMMIT;
