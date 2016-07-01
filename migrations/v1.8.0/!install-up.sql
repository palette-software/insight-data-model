\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-drop_p_interactor_cpu_usage_report.sql
\i 002-up-alter_p_cpu_usage_report.sql
\i 003-up-create_drop_child_indexes.sql
\i 004-up-replace_vizql_session_index.sql

insert into db_version_meta(version_number) values ('v1.8.0');

COMMIT;
