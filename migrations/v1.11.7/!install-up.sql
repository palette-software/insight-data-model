\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-get_max_ts_by_host.sql
\i 002-up-load_p_threadinfo.sql

insert into db_version_meta(version_number) values ('v1.11.7');

COMMIT;