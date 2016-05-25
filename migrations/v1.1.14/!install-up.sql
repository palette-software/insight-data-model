\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

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

insert into db_version_meta(version_number) values ('v1.1.14');

CREATE INDEX serverlogs_p_id_idx ON serverlogs USING btree (p_id);  
CREATE INDEX p_serverlogs_process_name_serverlogs_id_idx ON p_serverlogs USING btree (process_name, serverlogs_id);

alter table p_cpu_usage_agg_report add column vizql_session_count int default null;

\i 001-up-load_p_cpu_usage_agg_report.sql
\i 002-up-p_interactor_session_agg_cpu_usage.sql
\i 003-up-load_p_interactor_session_agg_cpu_usage.sql
\i 004-up-p_interactor_cpu_usage_report.sql
\i 005-up-p_processinfo.sql

CREATE INDEX p_cpu_usage_report_cpu_usage_vizql_session_idx ON p_cpu_usage_report USING btree (cpu_usage_vizql_session)
where cpu_usage_process_name in ('vizqlserver', 'dataserver', 'tabprotosrv', 'tdeserver');
