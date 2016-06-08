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

alter table p_interactor_session_agg_cpu_usage rename to p_interactor_session;
drop function load_p_interactor_session_agg_cpu_usage(text);
\i 001-up-load_p_interactor_session.sql
\i 002-up-get_max_ts.sql
\i 003-up-get_max_ts_date.sql

drop index palette.p_serverlogs_process_name_serverlogs_id_idx;
drop index palette.serverlogs_p_id_idx;
drop function load_p_serverlogs_datasrv_tabproto(text);

\i 004-up-create_load_p_background_jobs.sql
\i 005-up-create_load_s_cpu_usage_report.sql
\i 006-up-delete_recent_records_from_p_serverlogs.sql
\i 007-up-insert_p_serverlogs_from_s_serverlogs.sql
\i 008-up-is_subpart_template_same.sql
\i 009-up-load_s_serverlogs_dataserver.sql
\i 010-up-load_s_serverlogs_rest.sql
\i 011-up-load_s_serverlogs_tabproto.sql
\i 012-up-load_s_serverlogs_tdeserver.sql
\i 013-up-load_s_serverlogs_vizql.sql


insert into db_version_meta(version_number) values ('v1.2.0');
