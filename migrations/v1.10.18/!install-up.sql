\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-handle_utc_midnight_interactor_sess.sql
\i 002-up-load_from_stage_to_dwh_single_range_part.sql
\i 003-up-load_s_interactor_session.sql

insert into db_version_meta(version_number) values ('v1.10.18');

COMMIT;