\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-p_process_classification.sql
\i 002-up-load_p_process_class_agg_report.sql
\i 003-up-load_s_cpu_usage_dataserver.sql
\i 004-up-load_s_cpu_usage_rest.sql
\i 005-up-load_s_cpu_usage_tabproto.sql
\i 006-up-load_s_cpu_usage_tdeserver.sql
\i 007-up-load_s_cpu_usage_vizql.sql

grant select on p_process_classification to palette_palette_looker;

insert into db_version_meta(version_number) values ('v1.10.5');

COMMIT;
