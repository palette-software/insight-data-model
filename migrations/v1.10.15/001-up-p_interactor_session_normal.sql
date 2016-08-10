create or replace view p_interactor_session_normal AS
SELECT vizql_session
       , process_name
       , host_name
       , cpu_time_consumption_seconds
       , session_start_ts
       , session_end_ts
       , session_duration
       , publisher_friendly_name_id
       , publisher_user_name_id
       , interactor_friendly_name_id
       , interactor_user_name_id
       , site_name_id
       , project_name_id
       , workbook_name_id
       , workbook_revision
       , http_user_agent
       , num_fatals
       , num_errors
       , num_warnings
       , case when	   				
					min(case when init_show_bootstrap_normal then 1 end) over (partition by vizql_session) = 1
				then
					true
				else 
					false
	   	end as init_show_bootstrap_normal
       , min(show_count) over (partition by vizql_session) as show_count
       , min(bootstrap_count) over (partition by vizql_session) as bootstrap_count
       , show_elapsed_secs
       , bootstrap_elapsed_secs
       , show_bootstrap_delay_secs
       , user_type
       , p_id
	   , currentsheet	   
	   , http_referer
	   , http_request_uri
	   , remote_ip
	   , user_ip
	   , user_cookie
	   , status
	   , first_show_created_at
 FROM p_interactor_session;
