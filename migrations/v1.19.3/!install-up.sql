\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;


\i 001-up-p_cpu_usage_hourly.sql
\i 002-up-s_cpu_usage_hourly.sql
\i 003-up-p_background_jobs_hourly.sql
\i 004-up-s_background_jobs_hourly.sql
\i 005-up-load_s_background_jobs_hourly.sql
\i 006-up-load_s_cpu_usage_hourly.sql
\i 007-up-get_max_ts.sql
\i 008-up-manage_single_range_partitions.sql
\i 009-up-manage_partitions.sql

grant select on p_cpu_usage_hourly to palette_palette_looker;
grant select on p_background_jobs_hourly to palette_palette_looker;

INSERT INTO p_process_classification (process_name, process_class) VALUES ('hyperd', 'Tableau');

insert into db_version_meta(version_number) values ('v1.19.3');

COMMIT;