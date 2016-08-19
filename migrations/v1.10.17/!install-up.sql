\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;


insert into db_version_meta(version_number) values ('v1.10.17');

COMMIT;