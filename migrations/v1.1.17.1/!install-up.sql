\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

select 
		case when (cnt_repo - cnt_cpu_usage_report - 4) = 0
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

alter table p_serverlogs add column session_start_ts_utc timestamp without time zone default null;
alter table p_serverlogs add column session_end_ts_utc timestamp without time zone default null;
alter table p_serverlogs add column site_name_id text default null;
alter table p_serverlogs add column project_name_id text default null;
alter table p_serverlogs add column workbook_name_id text default null;
alter table p_serverlogs add column workbook_rev text default null;
alter table p_serverlogs add column publisher_username_id text default null;

create table tmp_upd_slogs
as
select
	s.vizql_session,
	s.site_name_id,
	s.project_name_id,
	s.workbook_name_id,
	s.publisher_username_id,
	s.h_workbooks_p_id,
	wb.revision
from
	(SELECT       				  
		  r.vizql_session,
		  max(r.site_name || ' (' || r.site_id || ')') as site_name_id,
		  max(r.project_name || ' (' || r.project_id || ')') as project_name_id,
		  max(r.workbook_name || ' (' || r.workbook_id || ')') as workbook_name_id,				  
		  max(r.publisher_username || ' (' || r.publisher_user_id || ')') as publisher_username_id,
		  max(h_workbooks_p_id) as h_workbooks_p_id
		FROM 
			p_http_requests r					
		WHERE
		  coalesce(r.currentsheet, '') <> '' AND 
		  r.vizql_session IS NOT NULL AND 
		  r.vizql_session <> '-' AND 
		  r.site_id IS NOT NULL   
		group by
		  	r.vizql_session
	) s
	left outer join h_workbooks wb on (wb.p_id = s.h_workbooks_p_id)
;

update p_serverlogs
set
	site_name_id = s.site_name_id,
	project_name_id = s.project_name_id ,
	workbook_name_id = s.workbook_name_id, 	
	publisher_username_id = s.publisher_username_id,
	workbook_rev = s.revision
from
	tmp_upd_slogs s	
where
	p_serverlogs.ts >= now()::date - 7 and
	p_serverlogs.parent_vizql_session = s.vizql_session	
;

drop table tmp_upd_slogs;

update p_serverlogs
set
	session_start_ts_utc = s.session_start_ts_utc,
	session_end_ts_utc = s.session_end_ts_utc
from
	 (
	 select parent_vizql_session,
	 		min(ts) as session_start_ts_utc,
			max(ts) as session_end_ts_utc
	 from
	 	p_serverlogs
	 where
	 	ts >= now()::date - 7
	  group by
	  	parent_vizql_session
	 ) s
where
	p_serverlogs.ts >= now()::date - 7 and
	p_serverlogs.parent_vizql_session = s.parent_vizql_session		
;

\i 001-up-p_serverlogs_report.sql
\i 002-up-does_part_exist.sql
\i 003-up-is_subpart_template_same.sql
\i 004-up-manage_partitions.sql
\i 005-up-delete_recent_records_from_p_serverlogs.sql
\i 006-up-insert_p_serverlogs_from_s_serverlogs.sql
\i 007-up-load_p_serverlogs_datasrv_tabproto.sql

insert into db_version_meta(version_number) values ('v1.1.17.1');
