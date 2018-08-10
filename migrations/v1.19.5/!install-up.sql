\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;


alter sequence p_cpu_usage_hourly_p_id_seq cache 500;
alter sequence p_background_jobs_hourly_p_id_seq cache 500;


insert into db_version_meta(version_number) values ('v1.19.5');

COMMIT;