\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-create_load_p_http_requests.sql
select create_load_p_http_requests('palette');

insert into db_version_meta(version_number) values ('v1.10.27');

COMMIT;