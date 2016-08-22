alter table p_interactor_session rename to p_interactor_session_old;
\i 004-up-p_interactor_session.sql
\i 004-up-s_interactor_session.sql
select create_s_interactor_session('palette');
insert into s_interactor_session select * from p_interactor_session_old;
select manage_partitions('palette', 'p_interactor_session');

insert into p_interactor_session (
		vizql_session
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
       , init_show_bootstrap_normal
       , show_count
       , bootstrap_count
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
)
SELECT  
		vizql_session
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
       , init_show_bootstrap_normal
       , show_count
       , bootstrap_count
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
 FROM s_interactor_session;
 
 drop table p_interactor_session_old;