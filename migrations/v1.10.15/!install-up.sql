\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

alter table p_cpu_usage_bootstrap_rpt alter column cpu_usage_parent_vizql_destroy_sess_ts type timestamp without time zone using to_timestamp(cpu_usage_parent_vizql_destroy_sess_ts, 'yyyy-mm-dd HH24.MI.SS.MS');

insert into db_version_meta(version_number) values ('v1.10.14');

COMMIT;