\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-s_plainlogs_session_map.sql
\i 002-up-s_serverlogs_spawner.sql
\i 003-up-s_tde_filename_pids.sql
\i 004-up-s_cpu_usage_dist_dims.sql
\i 005-up-create_load_s_cpu_usage_report.sql
\i 006-up-load_s_serverlogs_tdeserver.sql
\i 007-up-handle_privileges.sql

set role palette_etl_user;
drop table if exists session_map;
drop table if exists t_s_spawner;
drop table if exists tde_filename_pids;

set role palette_palette_updater;
select create_load_s_cpu_usage_report('#schema_name#');

set role gpadmin;
select handle_privileges('palette');


insert into db_version_meta(version_number) values ('v1.10.11');

COMMIT;
