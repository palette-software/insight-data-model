\set ON_ERROR_STOP on
set search_path = '#schema_name#';

select 
		case when (cnt_repo - cnt_cpu_usage_report) = 0
			then 'Repository check OK. (There are no new columns for p_cpu_usage_reporting table)'
		else
			(1 / 0)::varchar
		end as chk
from
(select count(1) as cnt_repo
from
	information_schema.columns c
where	
	c.table_name in ('h_sites', 'h_projects', 'h_workbooks', 'h_users', 'h_system_users')
	and c.table_schema = '#schema_name#'
) a
,
(select count(1) as cnt_cpu_usage_report
from
	information_schema.columns c
where	
	c.table_name = 'p_cpu_usage_report'
	and c.table_schema = '#schema_name#'
	and 
	(c.column_name like 'site\_%'	 
	 or c.column_name like 'project\_%'
	 or c.column_name like 'workbook\_%'	 
	 or c.column_name like 'publisher_user\_%'
	 or c.column_name like 'publisher_s_user\_%'	 
	 )
) b
;

insert into db_version_meta(version_number) values ('v1.1.10');

drop view p_serverlogs;
\i 001-up-p_serverlogs.sql
drop table s_cpu_usage_serverlogs;
drop table s_serverlogs_tabproto;
drop table s_serverlogs_tabproto_compressed;
drop function load_s_serverlogs_tabproto(p_schema_name text);
drop function load_s_cpu_usage_tabproto(p_schema_name text);

\i 002-up-s_serverlogs_compressed.sql
drop function load_s_cpu_usage_serverlogs(p_schema_name text);
\i 003-up-create_s_serverlogs.sql
select create_s_serverlogs('#schema_name#');

drop function load_p_thread_info(p_schema_name text, p_load_type text);
\i 004-up-load_p_threadinfo.sql


alter table p_cpu_usage add column parent_vizql_session text default null;
alter table p_cpu_usage add column parent_dataserver_session text default null;
alter table p_cpu_usage add column spawned_by_parent_ts text default null;
alter table p_cpu_usage add column parent_vizql_destroy_sess_ts text default null;					
alter table p_cpu_usage add column parent_process_type text default null;

drop table s_cpu_usage;
select create_s_cpu_usage('#schema_name#');

alter table p_cpu_usage_report add column cpu_usage_parent_vizql_session text default null;
alter table p_cpu_usage_report add column cpu_usage_parent_dataserver_session text default null;
alter table p_cpu_usage_report add column cpu_usage_spawned_by_parent_ts text default null;
alter table p_cpu_usage_report add column cpu_usage_parent_vizql_destroy_sess_ts text default null;					
alter table p_cpu_usage_report add column cpu_usage_parent_process_type text default null;

drop table s_cpu_usage_report;
select create_s_cpu_usage_report('#schema_name#');
select create_load_s_cpu_usage_report('#schema_name#');

\i 005-up-get_max_ts_date.sql
\i 006-up-grant_objects_to_looker_role.sql

\i 007-up-load_p_serverlogs_rest.sql
\i 008-up-load_p_serverlogs_vizql.sql
\i 009-up-load_s_serverlogs_tabproto.sql
\i 010-up-load_s_serverlogs_dataserver.sql
\i 011-up-load_p_serverlogs.sql

\i 012-up-load_s_serverlogs_dataserver_compressed.sql
\i 013-up-load_s_serverlogs_vizql_compressed.sql
\i 014-up-load_s_serverlogs_tabproto_compressed.sql
\i 015-up-load_s_serverlogs_compressed.sql

\i 021-up-load_s_cpu_usage_rest.sql
\i 022-up-load_s_cpu_usage_vizql.sql
\i 023-up-load_s_cpu_usage_dataserver.sql
\i 024-up-load_s_cpu_usage_tabproto.sql
\i 025-up-load_s_cpu_usage.sql

\i 050-up-manage_partitions.sql

