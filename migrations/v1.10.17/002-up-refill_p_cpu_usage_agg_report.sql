alter table p_cpu_usage_agg_report rename to p_cpu_usage_agg_report_old;
\i 002-up-p_cpu_usage_agg_report.sql
\i 002-up-s_cpu_usage_agg_report.sql
select create_s_cpu_usage_agg_report('palette');
insert into s_cpu_usage_agg_report select * from p_cpu_usage_agg_report_old;
select manage_partitions('palette', 'p_cpu_usage_agg_report');

insert into p_cpu_usage_agg_report (
 		 cpu_usage_host_name
       , cpu_usage_process_name
       , timestamp_utc
       , workbook_name
       , interactor_s_user_id
       , interactor_s_user_name
       , interactor_s_user_name_id
       , interactor_s_user_friendly_name
       , interactor_s_user_friendly_name_id
       , interactor_s_user_email
       , publisher_s_user_email
       , publisher_s_user_id
       , publisher_s_user_name
       , publisher_s_user_friendly_name
       , publisher_s_user_name_id
       , publisher_s_user_friendly_name_id
       , publisher_user_site_id
       , workbook_id
       , workbook_name_id
       , workbook_revision
       , workbook_name_id_revision
       , site_name
       , site_id
       , project_name
       , project_id
       , project_name_id
       , site_name_id
       , site_project
       , cpu_usage_cpu_time_consumption_seconds
       , cpu_usage_cpu_time_consumption_minutes
       , cpu_usage_cpu_time_consumption_hours
       , vizql_session_count
)
SELECT  cpu_usage_host_name
       , cpu_usage_process_name
       , timestamp_utc
       , workbook_name
       , interactor_s_user_id
       , interactor_s_user_name
       , interactor_s_user_name_id
       , interactor_s_user_friendly_name
       , interactor_s_user_friendly_name_id
       , interactor_s_user_email
       , publisher_s_user_email
       , publisher_s_user_id
       , publisher_s_user_name
       , publisher_s_user_friendly_name
       , publisher_s_user_name_id
       , publisher_s_user_friendly_name_id
       , publisher_user_site_id
       , workbook_id
       , workbook_name_id
       , workbook_revision
       , workbook_name_id_revision
       , site_name
       , site_id
       , project_name
       , project_id
       , project_name_id
       , site_name_id
       , site_project
       , cpu_usage_cpu_time_consumption_seconds
       , cpu_usage_cpu_time_consumption_minutes
       , cpu_usage_cpu_time_consumption_hours
       , vizql_session_count
 FROM s_cpu_usage_agg_report;
 
 drop table p_cpu_usage_agg_report_old;