\set ON_ERROR_STOP on

drop function grant_objects_to_looker_role(p_schema_name text);
i\ handle_privileges.sql
select handle_privileges('#schema_name#');


set role palette_#schema_name#_updater;

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

insert into db_version_meta(version_number) values ('v1.1.13');

alter table p_serverlogs add column elapsed_ms bigint default 0;
alter table p_serverlogs add column start_ts timestamp without time zone default null;
alter table s_serverlogs add column elapsed_ms bigint default null;
alter table s_serverlogs add column start_ts timestamp without time zone default null;

update p_serverlogs set start_ts = ts where start_ts is null;

\i 001-up-insert_p_serverlogs_from_s_serverlogs.sql
\i load_p_serverlogs_datasrv_tabproto.sql
\i load_s_cpu_usage_dataserver.sql
\i load_s_cpu_usage_tabproto.sql
\i load_s_serverlogs_dataserver.sql
\i load_s_serverlogs_rest.sql
\i load_s_serverlogs_tabproto.sql
\i load_s_serverlogs_tdeserver.sql
\i load_s_serverlogs_vizql.sql

drop view p_serverlogs_report
\i p_serverlogs_report.sql










