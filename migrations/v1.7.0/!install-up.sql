\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;


\i 001-up-drop_p_workbooks_view.sql
\i 002-up-create_p_workbooks_view.sql
\i 003-up-grantselect_p_workbooks.sql
\i 004-up-drop_p_datasources_view.sql
\i 005-up-create_p_datasources_view.sql
\i 006-up-grantselect_p_datasources.sql

insert into db_version_meta(version_number) values ('v1.7.0');

COMMIT;
