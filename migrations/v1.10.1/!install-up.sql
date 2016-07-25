\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-p_interactor_session_normal.sql

grant select on p_interactor_session_normal to palette_palette_looker;

insert into db_version_meta(version_number) values ('v1.10.1');

COMMIT;
