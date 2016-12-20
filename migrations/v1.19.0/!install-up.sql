\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

drop view p_processinfo;
drop table p_threadinfo;
drop function create_p_threadinfo_delta(p_schema_name text);
drop function load_p_threadinfo(p_schema_name text, p_load_type text);
alter table p_threadinfo_delta rename to p_threadinfo;
drop function load_p_threadinfo_delta(p_schema_name text);
\i 001-up-get_max_ts.sql
\i 002-up-load_s_cpu_usage_dataserver.sql
\i 003-up-load_s_cpu_usage_rest.sql
\i 004-up-load_s_cpu_usage_tabproto.sql
\i 005-up-load_s_cpu_usage_tdeserver.sql
\i 006-up-load_s_cpu_usage_vizql.sql
\i 007-up-load_s_process_class_agg_report.sql
\i 008-up-load_s_serverlogs_tabproto.sql
\i 009-up-manage_multi_range_partitions.sql
\i 010-up-manage_partitions.sql
\i 011-up-load_p_threadinfo.sql

insert into db_version_meta(version_number) values ('v1.19.0');

COMMIT;
