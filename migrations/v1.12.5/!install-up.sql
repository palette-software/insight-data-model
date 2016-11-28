\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

drop function load_p_http_requests(text);

\i 001-up-create_load_p_http_requests.sql
select create_load_p_http_requests('#schema_name#');

delete from p_http_requests
where created_at >= (select max(created_at)::date from p_http_requests);


insert into db_version_meta(version_number) values ('v1.12.5');

COMMIT;