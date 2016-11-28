\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;


\i 001-up-create_load_p_http_requests.sql
\i 002-up-insert_p_serverlogs_from_s_serverlogs.sql

select create_load_p_http_requests('#schema_name#');

insert into db_version_meta(version_number) values ('v1.12.6');

COMMIT;