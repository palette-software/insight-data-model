alter table p_serverlogs_bootstrap_rpt rename to p_serverlogs_bootstrap_rpt_old;
insert into s_serverlogs_bootstrap_rpt select * from p_serverlogs_bootstrap_rpt_old;
select create_p_serverlogs_bootstrap_rpt('palette');
select manage_partitions('palette', 'p_serverlogs_bootstrap_rpt');

insert into p_serverlogs_bootstrap_rpt
	( p_serverlogs_p_id
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
       , session_duration
       , currentsheet
       , p_cre_date)
	   
 SELECT p_serverlogs_p_id
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
       , session_duration
       , currentsheet
       , p_cre_date
 FROM p_serverlogs_bootstrap_rpt_old;
 
 drop table p_serverlogs_bootstrap_rpt_old;