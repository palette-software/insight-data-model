\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-p_load_dates.sql
grant select on p_load_dates to palette_palette_looker;
insert into p_load_dates (load_date) (select max(timestamp_utc) from p_cpu_usage_agg_report);
drop table p_cpu_usage_agg_report;
drop function load_s_cpu_usage_agg_report(p_schema_name text, p_load_date date);
\i 002-up-insert_new_load_date.sql
drop function manage_partitions(p_schema_name text, p_table_name text);
\i 003-up-manage_partitions.sql
drop function manage_single_range_partitions(p_schema_name text, p_table_name text);
\i 004-up-manage_single_range_partitions.sql
drop function get_max_ts(p_schema_name text, p_table_name text);
\i 005-up-get_max_ts.sql

insert into db_version_meta(version_number) values ('v1.17.0');

COMMIT;
