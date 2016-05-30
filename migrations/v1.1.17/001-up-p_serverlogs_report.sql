drop view p_serverlogs_report;

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
	   , min(s.ts) over (partition by s.parent_vizql_session) as session_start_ts_utc
	   , max(s.ts) over (partition by s.parent_vizql_session) as session_end_ts_utc
	   , h.site_name_id
	   , h.project_name_id
	   , h.workbook_name_id
	   , wb.revision as workbook_rev
	   , h.publisher_username_id	
 FROM p_serverlogs s
  	left outer join 
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
	) h on (s.parent_vizql_session = h.vizql_session)
	left outer join h_workbooks wb on (wb.p_id = h.h_workbooks_p_id)
 ;

grant select on p_serverlogs_report to palette_palette_looker;
