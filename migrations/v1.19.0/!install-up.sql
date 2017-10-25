\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

alter table threadinfo add column read_operation_count BIGINT default null;
alter table threadinfo add column write_operation_count BIGINT default null;
alter table threadinfo add column other_operation_count BIGINT default null;
alter table threadinfo add column read_transfer_count BIGINT default null;
alter table threadinfo add column write_transfer_count BIGINT default null;
alter table threadinfo add column other_transfer_count BIGINT default null;

alter table p_threadinfo_delta add column read_operation_count BIGINT default null;
alter table p_threadinfo_delta add column read_operation_count_delta BIGINT default null;
alter table p_threadinfo_delta add column write_operation_count BIGINT default null;
alter table p_threadinfo_delta add column write_operation_count_delta BIGINT default null;
alter table p_threadinfo_delta add column other_operation_count BIGINT default null;
alter table p_threadinfo_delta add column other_operation_count_delta BIGINT default null;
alter table p_threadinfo_delta add column read_transfer_count BIGINT default null;
alter table p_threadinfo_delta add column read_transfer_count_delta BIGINT default null;
alter table p_threadinfo_delta add column write_transfer_count BIGINT default null;
alter table p_threadinfo_delta add column write_transfer_count_delta BIGINT default null;
alter table p_threadinfo_delta add column other_transfer_count BIGINT default null;
alter table p_threadinfo_delta add column other_transfer_count_delta BIGINT default null;

alter table s_process_class_agg_report add column read_operation_count BIGINT default null;
alter table s_process_class_agg_report add column write_operation_count BIGINT default null;
alter table s_process_class_agg_report add column other_operation_count BIGINT default null;
alter table s_process_class_agg_report add column read_transfer_count BIGINT default null;
alter table s_process_class_agg_report add column write_transfer_count BIGINT default null;
alter table s_process_class_agg_report add column other_transfer_count BIGINT default null;

alter table p_process_class_agg_report add column read_operation_count BIGINT default null;
alter table p_process_class_agg_report add column write_operation_count BIGINT default null;
alter table p_process_class_agg_report add column other_operation_count BIGINT default null;
alter table p_process_class_agg_report add column read_transfer_count BIGINT default null;
alter table p_process_class_agg_report add column write_transfer_count BIGINT default null;
alter table p_process_class_agg_report add column other_transfer_count BIGINT default null;

\i 001-up-manage_partitions.sql
\i 002-up-manage_single_range_partitions.sql
\i 003-up-manage_multi_range_partitions.sql


\i 004-up-load_p_threadinfo_delta.sql
\i 005-up-load_s_process_class_agg_report.sql    

\i 006-up-create_p_errorlogs.sql
select create_p_errorlogs('palette');
\i 007-up-s_errorlogs.sql
\i 008-up-load_s_errorlogs.sql

\i 009-up-p_high_load_threads.sql
\i 010-up-s_high_load_threads.sql
\i 011-up-load_s_high_load_threads.sql

grant select on p_errorlogs to palette_palette_looker;
grant select on p_high_load_threads to palette_palette_looker;

insert into db_version_meta(version_number) values ('v1.19.0');

COMMIT;
