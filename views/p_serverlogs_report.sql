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
	   , min(ts) over (partition by parent_vizql_session) as session_start_ts_utc
	   , max(ts) over (partition by parent_vizql_session) as session_end_ts_utc
	   , h.site_name_id
	   , h.project_name_id
	   , h.workbook_name_id
	   --, workbook_rev
	   , publisher_username_id	
 FROM p_serverlogs s
  	left outer join 
			(SELECT       				  
				  r.vizql_session,
				  max(r.site_name || ' (' || r.site_id || ')') as site_name_id,
				  max(r.project_name || ' (' || r.project_id || ')') as project_name_id,
				  max(r.workbook_name || ' (' || r.workbook_id || ')') as workbook_name_id,
				  --max(wb.revision) as workbook_rev,
				  max(r.publisher_username || ' (' || r.publisher_user_id || ')') as publisher_username_id
				FROM 
					palette.p_http_requests r
					--inner join palette.h_workbooks wb on (wb.p_id = r.h_workbooks_p_id)
				WHERE
				  coalesce(r.currentsheet, '') <> '' AND 
				  r.vizql_session IS NOT NULL AND 
				  r.vizql_session <> '-' AND 
				  r.site_id IS NOT NULL   
				group by					
				  	r.vizql_session
	) h on (s.parent_vizql_session = h.vizql_session)
 ;