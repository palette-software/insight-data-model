\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;


\i 001-up-drop_create_view_p_workbooks.sql
\i 002-up-create_create_view_p_workbooks.sql
\i 003-up-drop_p_workbooks_view.sql
\i 004-up-create_view_p_workbooks.sql
\i 005-up-grantselect_p_workbooks.sql
\i 006-up-drop_create_view_p_datasources.sql
\i 007-up-create_create_view_p_datasources.sql
\i 008-up-drop_p_datasources_view.sql
\i 009-up-create_view_p_datasources.sql
\i 010-up-grantselect_p_datasources.sql

insert into db_version_meta(version_number) values ('v1.7.0');

COMMIT;
