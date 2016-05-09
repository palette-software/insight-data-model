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

insert into db_version_meta(version_number) values ('v1.1.12');

alter table serverlogs rename to serverlogs_old;

CREATE TABLE serverlogs
(LIKE serverlogs_old INCLUDING DEFAULTS)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (p_id)
PARTITION BY RANGE (ts)
SUBPARTITION BY LIST (host_name)
SUBPARTITION TEMPLATE (SUBPARTITION init VALUES ('init')
WITH (appendonly=true, orientation=column, compresstype=quicklz))
(PARTITION "10010101" START (date '1001-01-01') INCLUSIVE
	END (date '1001-01-02') EXCLUSIVE 
WITH (appendonly=true, orientation=column, compresstype=quicklz)	
);

alter sequence serverlogs_p_id_seq owned by serverlogs.p_id;

\i 001-up-manage_partitions.sql
\i 002-up-manage_partitions_for_recreate_serverlogs.sql

select manage_partitions_for_recreate_serverlogs('#schema_name#', 'serverlogs_old', 'serverlogs');

insert into serverlogs select * from serverlogs_old;
drop table serverlogs_old;
drop function manage_partitions_for_recreate_serverlogs(p_schema_name text, p_base_table_name text, p_target_table_name text);


\i 003-up-delete_recent_records_from_p_serverlogs.sql
\i 004-up-insert_p_serverlogs_from_s_serverlogs.sql
\i 005-up-load_p_cpu_usage_agg_report.sql
\i 006-up-load_s_serverlogs_vizql.sql
\i 007-up-p_cpu_usage_agg_report.sql

drop function create_s_serverlogs(p_schema_name text);
drop table s_serverlogs;
alter table p_serverlogs alter column v type varchar(10000000);
alter table p_serverlogs add column thread_name text default null;

create index p_serverlogs_vizql_session_idx on p_serverlogs(sess);
create index p_serverlogs_parent_vizql_session_idx on p_serverlogs(parent_vizql_session);

\i 008-up-s_serverlogs.sql

DROP FUNCTION load_p_serverlogs(p_schema_name text);
DROP FUNCTION load_s_cpu_usage(p_schema_name text);
DROP FUNCTION load_s_serverlogs_compressed(p_schema_name text);
DROP FUNCTION load_p_serverlogs_rest(p_schema_name text);
DROP FUNCTION load_p_serverlogs_vizql(p_schema_name text);

\i 009-up-load_s_serverlogs_rest.sql

alter table p_cpu_usage add column cpu_time_consumption_minutes Double precision default null;
alter table p_cpu_usage_report add column cpu_usage_cpu_time_consumption_minutes Double precision default null;
alter table p_cpu_usage_report rename column cpu_usage_start_ts to session_start_ts;
alter table p_cpu_usage_report rename column cpu_usage_end_ts to session_end_ts;
alter table p_cpu_usage_report add column session_duration interval default null;
alter table p_cpu_usage_report add column thread_name text default null;
alter table p_cpu_usage_report add column site_name_id text default null;
alter table p_cpu_usage_report add column project_name_id text default null;
alter table p_cpu_usage_report add column site_project text default null;
alter table p_cpu_usage_report add column workbook_name_id text default null;

drop table s_cpu_usage;
select create_s_cpu_usage('#schema_name#');

drop table s_cpu_usage_report;
select create_s_cpu_usage_report('#schema_name#');

\i 010-up-create_load_s_cpu_usage_report.sql
select create_load_s_cpu_usage_report('#schema_name#');

\i 011-up-get_max_ts_date.sql
\i 012-up-load_from_stage_to_dwh.sql
\i 013-up-load_p_threadinfo.sql


\i 014-up-load_s_cpu_usage_dataserver.sql
\i 015-up-load_s_cpu_usage_rest.sql
\i 016-up-load_s_cpu_usage_tabproto.sql
\i 017-up-load_s_cpu_usage_vizql.sql
\i 018-up-load_s_serverlogs_dataserver.sql
\i 019-up-load_s_serverlogs_dataserver_compressed.sql
\i 020-up-load_s_serverlogs_tabproto.sql
\i 021-up-load_s_serverlogs_tabproto_compressed.sql
\i 022-up-load_s_serverlogs_vizql_compressed.sql


alter table plainlogs rename to plainlogs_old;

CREATE TABLE plainlogs
(LIKE plainlogs_old INCLUDING DEFAULTS)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (p_id)
PARTITION BY RANGE (ts)
(START (date '2016-01-01') INCLUSIVE
	END (date '2020-01-01') EXCLUSIVE 
	every(interval'1 day')
WITH (appendonly=true, orientation=column, compresstype=quicklz)	
);

alter sequence plainlogs_p_id_seq owned by plainlogs.p_id;

insert into plainlogs select * from plainlogs_old;
drop table plainlogs_old;

select grant_objects_to_looker_role('#schema_name#');
