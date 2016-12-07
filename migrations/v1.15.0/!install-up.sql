\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

alter table s_tde_filename_pids rename to t_tde_filename_pids;

truncate table t_tde_filename_pids;

alter table t_tde_filename_pids add column p_id bigserial;
alter table t_tde_filename_pids add column p_cre_date timestamp default now();
alter table t_tde_filename_pids set distributed by (host_name, file_prefix, ts_from);

insert into t_tde_filename_pids 
		(host_name,
		file_prefix,
		pid,
		ts_from,
		ts_to)
	select
		host_name,
		file_prefix,
		pid::bigint,
		ts as ts_from,
		coalesce(lead(ts) over (partition by host_name, file_prefix order by ts), date'9999-12-31') as ts_to
	from
	(
	  SELECT
	  	host_name,
	    substring(filename FROM '^[a-z_]+[0-9]+') AS file_prefix,
	    substr(line, 5) AS pid,
	    ts
	  FROM
	    palette.plainlogs
	  WHERE
	    line LIKE 'pid=%'
	  GROUP BY 
	  		host_name,
			substring(filename FROM '^[a-z_]+[0-9]+'),  		   
			substr(line, 5),
			ts
	) b
    where
        ts < (select max(timestamp_utc) from p_cpu_usage_agg_report)::date + interval'26 hours'
;

\i 001-up-load_t_tde_filename_pids.sql
\i 002-up-load_s_serverlogs_tdeserver.sql
\i 003-up-get_max_ts.sql

insert into db_version_meta(version_number) values ('v1.15.0');

COMMIT;