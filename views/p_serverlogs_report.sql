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