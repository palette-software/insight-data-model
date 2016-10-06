\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i create_p_threadinfo_delta.sql
select create_p_threadinfo_delta('#schema_name#');

\i get_max_ts.sql
\i load_p_threadinfo_delta.sql
\i manage_multi_range_partitions.sql
\i manage_partitions.sql

select manage_partitions('palette', 'p_threadinfo_delta');

insert into p_threadinfo_delta
select
     -1,
     max(threadinfo_id),
     max(host_name),
     max(process_name),
     max(ts),
     max(ts_rounded_15_secs),
     max(ts_date),
     max(process_id),
     max(thread_id),
     max(start_ts),
     max(cpu_time_ticks),
     max(cpu_time_delta_ticks),
     max(ts_interval_ticks),
     max(cpu_core_consumption),
     max(memory_usage_bytes),
     max(memory_usage_delta_bytes),
     max(is_thread_level)
from
    p_threadinfo
where
    ts_rounded_15_secs >= now()::date
;


drop function load_s_process_class_agg_report(p_schema_name text, p_from text);

alter table p_process_class_agg_report add column max_tho_p_id bigint default null;
alter table s_process_class_agg_report add column max_tho_p_id bigint default null;


\i load_s_process_class_agg_report.sql

update p_process_class_agg_report
set
    max_tho_p_id = (select max(p_id) from p_threadinfo_delta where thread_id = -1)
where
    ts_rounded_15_secs >= (select get_max_ts_date('#schema_name#', 'p_process_class_agg_report'));    



insert into db_version_meta(version_number) values ('v1.11.0');

COMMIT;