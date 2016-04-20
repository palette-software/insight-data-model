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

insert into db_version_meta(version_number) values ('v1.1.9');

alter table threadinfo rename to threadinfo_old;

CREATE TABLE threadinfo
(LIKE threadinfo_old INCLUDING DEFAULTS)
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

alter sequence threadinfo_p_id_seq owned by threadinfo.p_id;

\i 001-up-manage_partitions.sql
\i 002-up-manage_partitions_for_recreate_threadinfo.sql

select manage_partitions_for_recreate_threadinfo('staging', 'threadinfo_old', 'threadinfo');
insert into threadinfo select * from threadinfo_old;
drop table threadinfo_old;
drop function manage_partitions_for_recreate_threadinfo(p_schema_name text, p_base_table_name text, p_target_table_name text);