\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

alter table p_cpu_usage_bootstrap_rpt ALTER COLUMN session_elapsed_seconds TYPE double precision;

\i 001-up-create_p_cpu_usage_bootstrap_rpt.sql
\i 002-up-create_p_cpu_usage_report.sql
\i 003-up-create_s_cpu_usage.sql
\i 004-up-handle_privileges.sql

insert into db_version_meta(version_number) values ('v1.10.22');

COMMIT;