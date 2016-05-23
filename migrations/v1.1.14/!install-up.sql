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

insert into db_version_meta(version_number) values ('v1.1.14');

CREATE INDEX serverlogs_p_id_idx ON palette.serverlogs USING btree (p_id);  
CREATE INDEX p_serverlogs_process_name_serverlogs_id_idx ON palette.p_serverlogs USING btree (process_name, serverlogs_id);

alter table p_cpu_usage_agg_report add column vizql_session_count int default null;

\i 001-up-load_p_cpu_usage_agg_report.sql




  
  