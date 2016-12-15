\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-create_load_p_background_jobs.sql

select create_load_p_background_jobs('#schema_name#');

insert into db_version_meta(version_number) values ('v1.18.2');

COMMIT;