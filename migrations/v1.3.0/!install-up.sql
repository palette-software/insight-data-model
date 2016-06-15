\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

\i 001-up-alter_p_interactor_session.sql
\i 002-up-load_p_interactor_session.sql

insert into db_version_meta(version_number) values ('v1.3.0');
