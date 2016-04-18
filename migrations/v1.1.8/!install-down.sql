\set ON_ERROR_STOP on
set search_path = '#schema_name#';
insert into db_version_meta(version_number) values ('v1.1.7');

alter table s_cpu_usage drop column dataserver_session;
alter table p_cpu_usage drop column dataserver_session;
alter table s_cpu_usage_report drop column cpu_usage_dataserver_session;
alter table p_cpu_usage_report drop column cpu_usage_dataserver_session;


\i 001-down-s_serverlogs_tabproto.sql
\i 002-down-s_serverlogs_tabproto_compressed.sql
\i 003-down-load_s_serverlogs_tabproto_compressed.sql
\i 004-down-load_s_serverlogs_tabproto.sql
\i 005-down-load_s_cpu_usage_tabproto.sql
\i 006-down-load_s_cpu_usage_serverlogs.sql
\i 007-down-load_s_cpu_usage.sql
\i 008-down-create_load_s_cpu_usage_report.sql


select create_load_s_cpu_usage_report('prod');
