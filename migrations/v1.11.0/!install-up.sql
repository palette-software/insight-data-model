\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-create_p_threadinfo_delta.sql
select create_p_threadinfo_delta('#schema_name#');

\i 002-up-get_max_ts.sql
\i 003-up-load_p_threadinfo_delta.sql
\i 004-up-manage_multi_range_partitions.sql
\i 005-up-manage_partitions.sql

select manage_partitions('palette', 'p_threadinfo_delta');

insert into p_threadinfo_delta
select *
from
    (select
         -1,
         max(threadinfo_id),
         max(host_name),
         '-1',
         max(ts) as ts,
         max(ts_rounded_15_secs),
         max(ts_date),
         0,
         0,
         max(start_ts),
         0,
         0,
         0,
         0,
         0,
         0,
         'N'
    from
        p_threadinfo
    ) m    
where
    m.ts > date'1001-01-01';

drop function load_s_process_class_agg_report(p_schema_name text, p_from text);

alter table p_process_class_agg_report add column max_tho_p_id bigint default null;
alter table s_process_class_agg_report add column max_tho_p_id bigint default null;

\i 006-up-load_s_process_class_agg_report.sql

insert into db_version_meta(version_number) values ('v1.11.0');

COMMIT;