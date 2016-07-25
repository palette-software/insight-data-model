\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-load_p_serverlogs_bootstrap_rpt.sql

grant select on p_serverlogs_bootstrap_rpt to palette_palette_looker;
grant select on p_cpu_usage_bootstrap_rpt to palette_palette_looker;


insert into db_version_meta(version_number) values ('v1.10.3');

COMMIT;
