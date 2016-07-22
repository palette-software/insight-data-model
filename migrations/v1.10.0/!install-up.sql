\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-create_p_serverlogs_bootstrap_rpt.sql
\i 002-up-create_p_cpu_usage_bootstrap_rpt.sql

select create_p_serverlogs_bootstrap_rpt('palette');
select create_p_cpu_usage_bootstrap_rpt('palette');

\i 003-up-load_p_serverlogs_bootstrap_rpt.sql
\i 004-up-load_p_cpu_usage_bootstrap_rpt.sql


insert into db_version_meta(version_number) values ('v1.10.0');


COMMIT;
