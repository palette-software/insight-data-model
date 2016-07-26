\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

alter table p_serverlogs add column session_elapsed_seconds double precision default 0;


\i 

insert into db_version_meta(version_number) values ('v1.10.4');

COMMIT;
