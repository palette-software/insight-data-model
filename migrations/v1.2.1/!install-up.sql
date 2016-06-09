\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

select 
		-- 4 is the number of columns that are additional columns in the p_cpu_usage_report table
		case when cnt_repo = cnt_cpu_usage_report - 4
			then 'Repository check OK. (There are no new columns for p_cpu_usage_report table)'
		else
			-- Division by zero on purpose, so that we can exit from this install script.
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

\i 001-up-get_max_ts_date.sql

insert into db_version_meta(version_number) values ('v1.2.1');