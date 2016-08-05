\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-load_p_threadinfo.sql

alter table p_cpu_usage alter column parent_vizql_destroy_sess_ts type timestamp without time zone;
alter table s_cpu_usage alter column parent_vizql_destroy_sess_ts type timestamp without time zone;

alter table p_cpu_usage_report alter column cpu_usage_parent_vizql_destroy_sess_ts type timestamp without time zone;
alter table s_cpu_usage_report alter column cpu_usage_parent_vizql_destroy_sess_ts type timestamp without time zone;

insert into db_version_meta(version_number) values ('v1.10.13');

COMMIT;