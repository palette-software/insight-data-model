\set ON_ERROR_STOP on
create role readonly with login password 'onlyread';
create role palette_etl_user with login password 'palette123';
CREATE ROLE palette_#schema_name#_looker;
CREATE ROLE palette_#schema_name#_updater; 
grant usage on schema #schema_name# to palette_#schema_name#_looker;
grant all on schema #schema_name# to palette_#schema_name#_updater;
alter role palette_etl_user with CREATEEXTTABLE;
grant palette_#schema_name#_looker to readonly;
grant palette_#schema_name#_updater to palette_etl_user;
CREATE RESOURCE QUEUE reporting WITH (ACTIVE_STATEMENTS=10, PRIORITY=MAX);
ALTER ROLE readonly RESOURCE QUEUE reporting;
alter user readonly set random_page_cost=20;
alter user readonly set optimizer=on;


set search_path = '#schema_name#';
\i db_version_meta.sql
insert into db_version_meta(version_number) values ('#version_number#');
\i genFromDBModel.SQL
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

alter table p_cpu_usage_report rename column cpu_usage_start_ts to session_start_ts;
alter table p_cpu_usage_report rename column cpu_usage_end_ts to session_end_ts;
alter table p_cpu_usage_report add column session_duration interval default null;
alter table p_cpu_usage_report add column thread_name text default null;
alter table p_cpu_usage_report add column site_name_id text default null;
alter table p_cpu_usage_report add column project_name_id text default null;
alter table p_cpu_usage_report add column site_project text default null;
alter table p_cpu_usage_report add column workbook_name_id text default null;

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
\i handle_privileges.sql

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

CREATE INDEX serverlogs_p_id_idx ON palette.serverlogs USING btree (p_id);  

\i get_max_ts_date.sql

\i s_serverlogs.sql
select create_s_serverlogs('#schema_name#');
\i s_serverlogs_compressed.sql

\i load_s_serverlogs_rest.sql
\i load_s_serverlogs_vizql.sql
\i load_s_serverlogs_tabproto.sql
\i load_s_serverlogs_dataserver.sql
\i load_s_serverlogs_tdeserver.sql
\i load_p_serverlogs.sql

\i load_s_serverlogs_dataserver_compressed.sql
\i load_s_serverlogs_vizql_compressed.sql
\i load_s_serverlogs_tabproto_compressed.sql
\i load_s_serverlogs_compressed.sql

\i load_s_cpu_usage_rest.sql
\i load_s_cpu_usage_vizql.sql
\i load_s_cpu_usage_dataserver.sql
\i load_s_cpu_usage_tabproto.sql

alter table plainlogs rename to plainlogs_old;
CREATE TABLE plainlogs
(LIKE plainlogs_old INCLUDING DEFAULTS)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (p_id)
PARTITION BY RANGE (ts)
(START (date '2016-01-01') INCLUSIVE
	END (date '2020-01-01') EXCLUSIVE 
	every(interval'1 day')
WITH (appendonly=true, orientation=column, compresstype=quicklz)	
);

alter sequence plainlogs_p_id_seq owned by plainlogs.p_id;
insert into plainlogs select * from plainlogs_old;
drop table plainlogs_old;


\i delete_recent_records_from_p_serverlogs.sql
\i insert_p_serverlogs_from_s_serverlogs.sql
\i load_p_cpu_usage_agg_report.sql
\i p_cpu_usage_agg_report.sql
\i load_p_serverlogs_datasrv_tabproto.sql
\i p_serverlogs_report.sql


select handle_privileges('#schema_name#');