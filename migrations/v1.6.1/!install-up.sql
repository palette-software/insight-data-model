\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-load_s_cpu_usage_rest.sql
\i 002-up-load_s_cpu_usage_tdeserver.sql

insert into db_version_meta(version_number) values ('v1.6.1');

COMMIT;