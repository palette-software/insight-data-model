\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-load-load_s_http_requests_with_workbooks.sql 

insert into db_version_meta(version_number) values ('v1.9.10');

COMMIT;
