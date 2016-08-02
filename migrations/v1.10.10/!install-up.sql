\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-handle_privileges.sql
\i 

insert into db_version_meta(version_number) values ('v1.10.10');

COMMIT;