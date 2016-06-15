\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;


\i 001-up-load_s_cpu_usage_dataserver.sql
\i 002-up-load_s_cpu_usage_rest.sql
\i 003-up-load_s_cpu_usage_tabproto.sql
\i 004-up-load_s_cpu_usage_vizql.sql


insert into db_version_meta(version_number) values ('v1.3.2');
