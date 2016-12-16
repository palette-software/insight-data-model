\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-load_cross_utc_midnight_sessions.sql
\i 002-up-load_s_serverlogs_plus_2_hours.sql
    

insert into db_version_meta(version_number) values ('v1.18.3');

COMMIT;