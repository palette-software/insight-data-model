\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-p_desktop_session.sql
\i 002-up-s_desktop_session.sql
\i 003-up-load_s_desktop_session.sql
\i 004-up-get_max_ts.sql
\i 005-up-manage_partitions.sql
\i 006-up-manage_single_range_partitions.sql

insert into db_version_meta(version_number) values ('v1.14.0');

COMMIT;