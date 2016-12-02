\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

grant select on p_background_jobs to palette_palette_looker;
grant select on p_http_requests to palette_palette_looker;

insert into db_version_meta(version_number) values ('v1.12.8');

COMMIT;