\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-load_s_serverlogs_tdeserver.sql
\i 002-up-update_p_serverlogs_process_id_tdeserver.sql

insert into db_version_meta(version_number) values ('v1.8.1');

COMMIT;
