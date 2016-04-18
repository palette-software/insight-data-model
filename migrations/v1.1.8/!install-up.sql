\set ON_ERROR_STOP on
set search_path = '#schema_name#';
insert into db_version_meta(version_number) values ('v1.1.8');

alter table s_cpu_usage add column dataserver_session text default null;
alter table p_cpu_usage add column dataserver_session text default null;
alter table s_cpu_usage_report add column cpu_usage_dataserver_session text default null;
alter table p_cpu_usage_report add column cpu_usage_dataserver_session text default null;


\i 001-up-s_serverlogs_tabproto.sql
\i 002-up-s_serverlogs_tabproto_compressed.sql
\i 003-up-load_s_serverlogs_tabproto_compressed.sql
\i 004-up-load_s_serverlogs_tabproto.sql
\i 005-up-load_s_cpu_usage_tabproto.sql
\i 006-up-load_s_cpu_usage_serverlogs.sql
\i 007-up-load_s_cpu_usage.sql
\i 008-up-create_load_s_cpu_usage_report.sql


select create_load_s_cpu_usage_report('prod');
