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


drop view p_serverlogs_report;


CREATE OR REPLACE FUNCTION drop_child_indexes (index_name varchar)
RETURNS VOID
AS
$functionBody$
DECLARE
  child_index_name varchar;
BEGIN

  FOR child_index_name IN
    SELECT child_index.indexrelid::regclass
      FROM pg_index AS parent_index
        -- Find the partitioning scheme for the table the index is on
        INNER JOIN pg_partition ON pg_partition.parrelid = parent_index.indrelid
        -- Follow the links through to the individual partitions
        INNER JOIN pg_partition_rule ON pg_partition_rule.paroid = pg_partition.oid
        -- Find the indexes on each partition
        INNER JOIN pg_index AS child_index ON child_index.indrelid = pg_partition_rule.parchildrelid
          -- Which are on the same field as the named index
          AND child_index.indkey = parent_index.indkey
          -- Using the same comparison operator
          AND child_index.indclass = parent_index.indclass
      -- Filtered for the index we're trying to drop
      WHERE parent_index.indexrelid = $1::regclass::oid
      -- Drop leaves first, even if it doesn't really matter in this case
      ORDER BY pg_partition.parlevel DESC

LOOP
  RAISE NOTICE '%', child_index_name||' ';
  EXECUTE 'DROP INDEX '||child_index_name||';';
END LOOP;

END
$functionBody$
LANGUAGE plpgsql;

selcet drop_child_indexes('palette.p_serverlogs_process_name_serverlogs_id_idx');


alter table p_serverlogs alter column parent_vizql_session type varchar(100);

create index p_serverlogs_parent_vizql_session_idx on p_serverlogs(parent_vizql_session);


create view p_serverlogs_report
as
SELECT  p_id
       , serverlogs_id
       , p_filepath
       , filename
       , process_name
       , host_name
       , ts
       , process_id
       , thread_id
       , sev
       , req
       , sess
       , site
       , username
       , username_without_domain
       , k
       , v::varchar(10000000) 
       , parent_vizql_session
       , parent_vizql_destroy_sess_ts
       , parent_dataserver_session
       , spawned_by_parent_ts
       , parent_process_type
       , parent_vizql_site
       , parent_vizql_username
       , parent_dataserver_site
       , parent_dataserver_username
       , p_cre_date
       , thread_name
	   , elapsed_ms::double precision / 1000 as elapsed_secs
	   , elapsed_ms::double precision / 1000 / 60 / 60 / 24 as elapsed_days
	   , start_ts
 FROM p_serverlogs;

grant select on p_serverlogs_report to palette_palette_looker;


insert into db_version_meta(version_number) values ('v1.1.15');
