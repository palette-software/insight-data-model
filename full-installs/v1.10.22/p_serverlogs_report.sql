create view p_serverlogs_report
as
SELECT  s.p_id
       , s.serverlogs_id
       , s.p_filepath
       , s.filename
       , s.process_name
       , s.host_name
       , s.ts
       , s.process_id
       , s.thread_id
       , s.sev
       , s.req
       , s.sess
       , s.site
       , s.username
       , s.username_without_domain
       , s.k
       , s.v::varchar(10000000) 
       , s.parent_vizql_session
       , s.parent_vizql_destroy_sess_ts
       , s.parent_dataserver_session
       , s.spawned_by_parent_ts
       , s.parent_process_type
       , s.parent_vizql_site
       , s.parent_vizql_username
       , s.parent_dataserver_site
       , s.parent_dataserver_username
       , s.p_cre_date
       , s.thread_name
	   , s.elapsed_ms::double precision / 1000 as elapsed_secs
	   , s.elapsed_ms::double precision / 1000 / 60 / 60 / 24 as elapsed_days
	   , s.start_ts
	   , s.session_start_ts_utc
	   , s.session_end_ts_utc
	   , s.site_name_id
	   , s.project_name_id
	   , s.workbook_name_id
	   , s.workbook_rev
	   , s.publisher_username_id
	   , s.user_type
 FROM p_serverlogs s;
