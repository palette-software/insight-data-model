\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-p_workbooks_datasources.sql

grant select on p_workbooks_datasources to palette_palette_looker;

insert into db_version_meta(version_number) values ('v1.18.0');

COMMIT;
