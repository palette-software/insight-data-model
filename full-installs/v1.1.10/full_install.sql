\set ON_ERROR_STOP on
-- create role readonly_#schema_name# with login password 'onlyread';
-- create role palette_looker;
-- create role palette_updater;
-- CREATE ROLE palette_#schema_name#_looker;
-- GRANT  palette_#schema_name#_looker TO palette_looker WITH ADMIN OPTION ;
-- CREATE ROLE palette_#schema_name#_updater; 
-- GRANT  palette_#schema_name#_updater TO palette_updater WITH ADMIN OPTION;
-- grant palette_#schema_name#_looker to readonly_#schema_name#;
-- grant usage on schema #schema_name# to readonly_#schema_name#;
-- 
set search_path = '#schema_name#';
\i db_version_meta.sql
insert into db_version_meta(version_number) values ('v1.1.10');
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
\i load_p_threadinfo.sql
\i create_load_p_http_requests.sql
select create_load_p_http_requests('#schema_name#');
\i load_s_http_requests_with_workbooks.sql
\i create_load_p_background_jobs.sql
select create_load_p_background_jobs('#schema_name#');
\i load_s_cpu_usage.sql
\i create_load_s_cpu_usage_report.sql
select create_load_s_cpu_usage_report('#schema_name#');
\i load_from_stage_to_dwh.sql
\i grant_objects_to_looker_role.sql
select grant_objects_to_looker_role('#schema_name#');

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

\i get_max_ts_date.sql

\i create_s_serverlogs.sql
select create_s_serverlogs('#schema_name#');
\i s_serverlogs_compressed.sql

\i load_p_serverlogs_rest.sql
\i load_p_serverlogs_vizql.sql
\i load_s_serverlogs_tabproto.sql
\i load_s_serverlogs_dataserver.sql
\i load_p_serverlogs.sql

\i load_s_serverlogs_dataserver_compressed.sql
\i load_s_serverlogs_vizql_compressed.sql
\i load_s_serverlogs_tabproto_compressed.sql
\i load_s_serverlogs_compressed.sql

\i load_s_cpu_usage_rest.sql
\i load_s_cpu_usage_vizql.sql
\i load_s_cpu_usage_dataserver.sql
\i load_s_cpu_usage_tabproto.sql
