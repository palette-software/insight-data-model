\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-create_load_s_cpu_usage_report.sql
\i 002-up-insert_p_serverlogs_from_s_serverlogs.sql
\i 003-up-load_s_cpu_usage_tdeserver.sql
\i 004-up-load_s_cpu_usage_vizql.sql
\i 005-up-load_s_serverlogs_dataserver_compressed.sql
\i 006-up-load_s_serverlogs_tabproto_compressed.sql
\i 007-up-load_s_serverlogs_vizql.sql
\i 008-up-load_s_serverlogs_vizql_compressed.sql


select create_load_s_cpu_usage_report('#schema_name#');


insert into db_version_meta(version_number) values ('v1.9.11');

COMMIT;
