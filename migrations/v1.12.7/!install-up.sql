\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-insert_p_serverlogs_from_s_serverlogs.sql
\i 002-up-load_s_http_requests_with_workbooks.sql
\i 003-up-load_s_serverlogs_dataserver.sql
\i 004-up-load_s_serverlogs_plus_2_hours.sql
\i 005-up-load_s_serverlogs_rest.sql
\i 006-up-load_s_serverlogs_tabproto.sql
\i 007-up-load_s_serverlogs_tdeserver.sql
\i 008-up-load_s_serverlogs_vizql.sql

insert into db_version_meta(version_number) values ('v1.12.7');

COMMIT;