\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-load_s_serverlogs_dataserver.sql


insert into db_version_meta(version_number) values ('v1.11.4');

COMMIT;