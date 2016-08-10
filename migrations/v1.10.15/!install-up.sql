\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;
drop view p_interactor_session_normal;

\i 001-up-p_interactor_session_normal.sql
\i 002-up-load_p_interactor_session.sql
\i 003-up-load_s_serverlogs_tabproto.sql

grant select on p_interactor_session_normal to palette_palette_looker;

insert into db_version_meta(version_number) values ('v1.10.15');

COMMIT;
