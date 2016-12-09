\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-p_load_dates.sql
grant select on p_load_dates to palette_palette_looker;
drop table p_cpu_usage_agg_report;
drop table s_cpu_usage_agg_report;
\i 002-up-insert_new_load_date.sql
select insert_new_load_date('palette', (select max(timestamp_utc)::date from p_cpu_usage_agg_report));
\i 003-up-manage_partitions.sql
\i 004-up-manage_single_range_partitions.sql
\i 005-up-get_max_ts.sql

insert into db_version_meta(version_number) values ('v1.17.0');

COMMIT;
