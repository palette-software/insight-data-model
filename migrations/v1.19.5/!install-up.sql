\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;


alter sequence p_cpu_usage_hourly_p_id_seq cache 500;
alter sequence p_background_jobs_hourly_p_id_seq cache 500;

\i 001-up-load_s_serverlogs_dataserver.sql
\i 002-up-load_s_serverlogs_rest.sql
\i 003-up-load_s_serverlogs_tabproto.sql
\i 004-up-load_s_serverlogs_vizql.sql

insert into db_version_meta(version_number) values ('v1.19.5');

COMMIT;