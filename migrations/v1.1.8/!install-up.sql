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



insert into db_version_meta(version_number) values ('v1.1.8');

alter table s_cpu_usage add column dataserver_session text default null;
alter table p_cpu_usage add column dataserver_session text default null;
alter table s_cpu_usage_report add column cpu_usage_dataserver_session text default null;
alter table p_cpu_usage_report add column cpu_usage_dataserver_session text default null;


\i 001-up-s_serverlogs_tabproto.sql
\i 002-up-s_serverlogs_tabproto_compressed.sql
\i 003-up-load_s_serverlogs_tabproto_compressed.sql
\i 004-up-load_s_serverlogs_tabproto.sql
\i 005-up-load_s_cpu_usage_tabproto.sql
\i 006-up-load_s_cpu_usage_serverlogs.sql
\i 007-up-load_s_cpu_usage.sql
\i 008-up-create_load_s_cpu_usage_report.sql


select create_load_s_cpu_usage_report('prod');