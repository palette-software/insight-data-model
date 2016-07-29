\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-create_p_serverlogs_bootstrap_rpt.sql

alter table p_serverlogs_bootstrap_rpt rename to p_serverlogs_bootstrap_rpt_old;

select create_p_serverlogs_bootstrap_rpt('#schema_name#');

CREATE OR REPLACE FUNCTION insert_srvlogs_bootstrap_by_day() RETURNS bigint
AS $$
declare
	v_cnt int;
	rec record;
	v_sql text;	
	v_datum_text varchar;
begin	

	for rec in (select (select min(ts)::date -1 from p_serverlogs_bootstrap_rpt_old) + generate_series(1,
							((select max(ts)::date from p_serverlogs_bootstrap_rpt_old) - (select min(ts)::date from p_serverlogs_bootstrap_rpt_old)) + 1
							) as d 				 
				order by d)
	loop
		
		raise notice 'I: %', rec.d;		
		
		v_datum_text = 'date''' || to_char(rec.d, 'yyyy-mm-dd') || '''';
		
		v_sql := 				   
		'
		insert into p_serverlogs_bootstrap_rpt (						
				        p_serverlogs_p_id
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
				       , v
				       , parent_vizql_session
				       , parent_vizql_destroy_sess_ts
				       , parent_dataserver_session
				       , spawned_by_parent_ts
				       , parent_process_type
				       , parent_vizql_site
				       , parent_vizql_username
				       , parent_dataserver_site
				       , parent_dataserver_username
				       , p_serverlogs_p_cre_date
				       , thread_name
				       , elapsed_ms
				       , start_ts
				       , session_start_ts_utc
				       , session_end_ts_utc
				       , site_name_id
				       , project_name_id
				       , workbook_name_id
				       , workbook_rev
				       , publisher_username_id
				       , user_type
				       , session_elapsed_seconds
				       , p_cre_date
				       , session_duration		
		)
		select 
		        p_serverlogs_p_id
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
		       , v
		       , parent_vizql_session
		       , parent_vizql_destroy_sess_ts
		       , parent_dataserver_session
		       , spawned_by_parent_ts
		       , parent_process_type
		       , parent_vizql_site
		       , parent_vizql_username
		       , parent_dataserver_site
		       , parent_dataserver_username
		       , p_serverlogs_p_cre_date
		       , thread_name
		       , elapsed_ms
		       , start_ts
		       , session_start_ts_utc
		       , session_end_ts_utc
		       , site_name_id
		       , project_name_id
		       , workbook_name_id
		       , workbook_rev
		       , publisher_username_id
		       , user_type
		       , session_elapsed_seconds
		       , p_cre_date
		       , session_duration
		from 
			p_serverlogs_bootstrap_rpt_old
		where
			ts >= ' || v_datum_text || ' and
			ts < ' || v_datum_text || ' + 1
		'
		;
	
		raise notice 'I: %', v_sql;	
		execute v_sql;
		
	end loop;	
	return 0;
END;
$$ LANGUAGE plpgsql;
 
select insert_srvlogs_bootstrap_by_day();
drop FUNCTION insert_srvlogs_bootstrap_by_day();
drop table p_serverlogs_bootstrap_rpt_old;

CREATE INDEX p_serverlogs_bootstrap_rpt_parent_vizql_session_idx ON p_serverlogs_bootstrap_rpt (parent_vizql_session);

insert into db_version_meta(version_number) values ('v1.10.7');

COMMIT;