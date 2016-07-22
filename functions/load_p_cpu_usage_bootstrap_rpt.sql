CREATE or replace function load_p_cpu_usage_bootstrap_rpt(p_schema_name text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;
	v_from text;
	v_to text;
	v_sql_cur text;	
begin		

	execute 'set local search_path = ' || p_schema_name;
	
	v_sql_cur := '
	    select
		    to_char(coalesce(
			    max(cpu_usage_ts_rounded_15_secs),
				date''1001-01-01''), ''yyyy-mm-dd'')
		from p_cpu_usage_bootstrap_rpt';
		
	raise notice 'I: %', v_sql_cur;
	execute v_sql_cur into v_from;
		
	v_sql_cur := 
		'select
			to_char(coalesce(min(cpu_usage_ts_rounded_15_secs), date''#v_from#'' + 1), ''yyyy-mm-dd hh24:mi:ss.ms'')
		from
			p_cpu_usage_report cpu
			left outer join p_interactor_session s on (
		                                    s.session_start_ts >= date''#v_from#'' and		                                    
		                                    s.vizql_session = cpu.cpu_usage_parent_vizql_session and
		                                    s.process_name = ''vizqlserver'')
		where        
		 	cpu.cpu_usage_parent_vizql_session is not null and
			cpu.cpu_usage_parent_vizql_session not in (''Non-Interactor Vizql'', ''-'') and
		 	cpu.cpu_usage_ts_rounded_15_secs >= date''#v_from#'' + 1 and
			cpu.cpu_usage_ts <= s.session_start_ts +
												(interval''1 second'' * coalesce(s.bootstrap_elapsed_secs, 0)) +
												(interval''1 second'' * coalesce(s.show_elapsed_secs,0)) +
												(interval''1 second'' * coalesce(s.show_bootstrap_delay_secs,0))										
										+ interval ''15 second''
		';
	
	v_sql_cur := replace(v_sql_cur, '#v_from#', v_from);	
	raise notice 'I: %', v_sql_cur;
	execute v_sql_cur into v_to;

	v_sql_cur := 
	'delete
		from  
			p_cpu_usage_bootstrap_rpt b	
		where 
			b.cpu_usage_ts_rounded_15_secs >= date''#v_from#'' and
			b.cpu_usage_ts_rounded_15_secs <= timestamp''#v_to#''
	';
	v_sql_cur := replace(v_sql_cur, '#v_from#', v_from);
	v_sql_cur := replace(v_sql_cur, '#v_to#', v_to);

    raise notice 'I: %', v_sql_cur;
	execute v_sql_cur;
	
		
	v_sql := 'insert into p_cpu_usage_bootstrap_rpt
	    (				     
         p_cpu_usage_report_p_id
       , cpu_usage_p_id
       , cpu_usage_p_threadinfo_id
       , cpu_usage_ts
       , cpu_usage_ts_rounded_15_secs
       , cpu_usage_ts_date
       , cpu_usage_ts_day_hour
       , cpu_usage_vizql_session
       , cpu_usage_repository_url
       , cpu_usage_user_ip
       , cpu_usage_site_id
       , cpu_usage_workbook_id
       , cpu_usage_cpu_time_consumption_ticks
       , cpu_usage_cpu_time_consumption_seconds
       , cpu_usage_cpu_time_consumption_minutes
       , cpu_usage_cpu_time_consumption_hours
       , cpu_usage_ts_interval_ticks
       , cpu_usage_cpu_core_consumption
       , cpu_usage_memory_usage_bytes
       , cpu_usage_process_name
       , cpu_usage_process_owner
       , cpu_usage_is_allocatable
       , cpu_usage_process_level
       , cpu_usage_is_thread_level
       , cpu_usage_host_name
       , cpu_usage_process_id
       , cpu_usage_thread_id
       , session_start_ts
       , session_end_ts
       , cpu_usage_username
       , cpu_usage_h_workbooks_p_id
       , cpu_usage_h_projects_p_id
       , cpu_usage_publisher_h_users_p_id
       , cpu_usage_publisher_h_system_users_p_id
       , cpu_usage_h_sites_p_id
       , cpu_usage_interactor_h_users_p_id
       , cpu_usage_interactor_h_system_users_p_id
       , cpu_usage_max_reporting_granularity
       , cpu_usage_dataserver_session
       , cpu_usage_parent_vizql_session
       , cpu_usage_parent_dataserver_session
       , cpu_usage_spawned_by_parent_ts
       , cpu_usage_parent_vizql_destroy_sess_ts
       , cpu_usage_parent_process_type
       , site_p_id
       , site_p_filepath
       , site_id
       , site_name
       , site_url_namespace
       , site_status
       , site_created_at
       , site_updated_at
       , site_user_quota
       , site_content_admin_mode
       , site_storage_quota
       , site_metrics_level
       , site_status_reason
       , site_subscriptions_enabled
       , site_custom_subscription_footer
       , site_custom_subscription_email
       , site_luid
       , site_query_limit
       , site_authoring_disabled
       , site_sheet_image_enabled
       , site_livedb_connections_whitelist_enabled
       , site_refresh_token_setting
       , site_version_history_enabled
       , site_p_cre_date
       , site_p_active_flag
       , site_p_valid_from
       , site_p_valid_to
       , project_p_id
       , project_p_filepath
       , project_id
       , project_name
       , project_owner_id
       , project_created_at
       , project_updated_at
       , project_state
       , project_description
       , project_site_id
       , project_special
       , project_luid
       , project_controlled_permissions_enabled
       , project_p_cre_date
       , project_p_active_flag
       , project_p_valid_from
       , project_p_valid_to
       , workbook_p_id
       , workbook_p_filepath
       , workbook_id
       , workbook_name
       , workbook_repository_url
       , workbook_description
       , workbook_created_at
       , workbook_updated_at
       , workbook_owner_id
       , workbook_project_id
       , workbook_view_count
       , workbook_size
       , workbook_embedded
       , workbook_thumb_user
       , workbook_refreshable_extracts
       , workbook_extracts_refreshed_at
       , workbook_lock_version
       , workbook_state
       , workbook_version
       , workbook_checksum
       , workbook_display_tabs
       , workbook_data_engine_extracts
       , workbook_incrementable_extracts
       , workbook_site_id
       , workbook_revision
       , workbook_repository_data_id
       , workbook_repository_extract_data_id
       , workbook_first_published_at
       , workbook_primary_content_url
       , workbook_share_description
       , workbook_show_toolbar
       , workbook_extracts_incremented_at
       , workbook_default_view_index
       , workbook_luid
       , workbook_asset_key_id
       , workbook_document_version
       , workbook_content_version
       , workbook_p_cre_date
       , workbook_p_active_flag
       , workbook_p_valid_from
       , workbook_p_valid_to
       , interactor_s_user_p_id
       , interactor_s_user_p_filepath
       , interactor_s_user_id
       , interactor_s_user_name
       , interactor_s_user_email
       , interactor_s_user_hashed_password
       , interactor_s_user_salt
       , interactor_s_user_sys
       , interactor_s_user_keychain
       , interactor_s_user_domain_id
       , interactor_s_user_friendly_name
       , interactor_s_user_custom_display_name
       , interactor_s_user_activation_code
       , interactor_s_user_activated_at
       , interactor_s_user_state
       , interactor_s_user_admin_level
       , interactor_s_user_created_at
       , interactor_s_user_updated_at
       , interactor_s_user_deleted_at
       , interactor_s_user_auth_user_id
       , interactor_s_user_asset_key_id
       , interactor_s_user_p_cre_date
       , interactor_s_user_p_active_flag
       , interactor_s_user_p_valid_from
       , interactor_s_user_p_valid_to
       , publisher_user_p_id
       , publisher_user_p_filepath
       , publisher_user_id
       , publisher_user_login_at
       , publisher_user_licensing_role_id
       , publisher_user_nonce
       , publisher_user_row_limit
       , publisher_user_storage_limit
       , publisher_user_created_at
       , publisher_user_extracts_required
       , publisher_user_updated_at
       , publisher_user_admin_level
       , publisher_user_publisher_tristate
       , publisher_user_raw_data_suppressor_tristate
       , publisher_user_site_id
       , publisher_user_system_user_id
       , publisher_user_system_admin_auto
       , publisher_user_luid
       , publisher_user_p_cre_date
       , publisher_user_p_active_flag
       , publisher_user_p_valid_from
       , publisher_user_p_valid_to
       , publisher_s_user_p_id
       , publisher_s_user_p_filepath
       , publisher_s_user_id
       , publisher_s_user_name
       , publisher_s_user_email
       , publisher_s_user_hashed_password
       , publisher_s_user_salt
       , publisher_s_user_sys
       , publisher_s_user_keychain
       , publisher_s_user_domain_id
       , publisher_s_user_friendly_name
       , publisher_s_user_custom_display_name
       , publisher_s_user_activation_code
       , publisher_s_user_activated_at
       , publisher_s_user_state
       , publisher_s_user_admin_level
       , publisher_s_user_created_at
       , publisher_s_user_updated_at
       , publisher_s_user_deleted_at
       , publisher_s_user_auth_user_id
       , publisher_s_user_asset_key_id
       , publisher_s_user_p_cre_date
       , publisher_s_user_p_active_flag
       , publisher_s_user_p_valid_from
       , publisher_s_user_p_valid_to
       , session_duration
       , thread_name
       , site_name_id
       , project_name_id
       , site_project
       , workbook_name_id
       , cpu_usage_user_type
	   , elapsed_seconds_to_bootstrap
		)
		select     
	   		cpu.p_id
	       , cpu.cpu_usage_p_id
	       , cpu.cpu_usage_p_threadinfo_id
	       , cpu.cpu_usage_ts
	       , cpu.cpu_usage_ts_rounded_15_secs
	       , cpu.cpu_usage_ts_date
	       , cpu.cpu_usage_ts_day_hour
	       , cpu.cpu_usage_vizql_session
	       , cpu.cpu_usage_repository_url
	       , cpu.cpu_usage_user_ip
	       , cpu.cpu_usage_site_id
	       , cpu.cpu_usage_workbook_id
	       , cpu.cpu_usage_cpu_time_consumption_ticks
	       , cpu.cpu_usage_cpu_time_consumption_seconds
	       , cpu.cpu_usage_cpu_time_consumption_minutes
	       , cpu.cpu_usage_cpu_time_consumption_hours
	       , cpu.cpu_usage_ts_interval_ticks
	       , cpu.cpu_usage_cpu_core_consumption
	       , cpu.cpu_usage_memory_usage_bytes
	       , cpu.cpu_usage_process_name
	       , cpu.cpu_usage_process_owner
	       , cpu.cpu_usage_is_allocatable
	       , cpu.cpu_usage_process_level
	       , cpu.cpu_usage_is_thread_level
	       , cpu.cpu_usage_host_name
	       , cpu.cpu_usage_process_id
	       , cpu.cpu_usage_thread_id
	       , cpu.session_start_ts
	       , cpu.session_end_ts
	       , cpu.cpu_usage_username
	       , cpu.cpu_usage_h_workbooks_p_id
	       , cpu.cpu_usage_h_projects_p_id
	       , cpu.cpu_usage_publisher_h_users_p_id
	       , cpu.cpu_usage_publisher_h_system_users_p_id
	       , cpu.cpu_usage_h_sites_p_id
	       , cpu.cpu_usage_interactor_h_users_p_id
	       , cpu.cpu_usage_interactor_h_system_users_p_id
	       , cpu.cpu_usage_max_reporting_granularity
	       , cpu.cpu_usage_dataserver_session
	       , cpu.cpu_usage_parent_vizql_session
	       , cpu.cpu_usage_parent_dataserver_session
	       , cpu.cpu_usage_spawned_by_parent_ts
	       , cpu.cpu_usage_parent_vizql_destroy_sess_ts
	       , cpu.cpu_usage_parent_process_type
	       , cpu.site_p_id
	       , cpu.site_p_filepath
	       , cpu.site_id
	       , cpu.site_name
	       , cpu.site_url_namespace
	       , cpu.site_status
	       , cpu.site_created_at
	       , cpu.site_updated_at
	       , cpu.site_user_quota
	       , cpu.site_content_admin_mode
	       , cpu.site_storage_quota
	       , cpu.site_metrics_level
	       , cpu.site_status_reason
	       , cpu.site_subscriptions_enabled
	       , cpu.site_custom_subscription_footer
	       , cpu.site_custom_subscription_email
	       , cpu.site_luid
	       , cpu.site_query_limit
	       , cpu.site_authoring_disabled
	       , cpu.site_sheet_image_enabled
	       , cpu.site_livedb_connections_whitelist_enabled
	       , cpu.site_refresh_token_setting
	       , cpu.site_version_history_enabled
	       , cpu.site_p_cre_date
	       , cpu.site_p_active_flag
	       , cpu.site_p_valid_from
	       , cpu.site_p_valid_to
	       , cpu.project_p_id
	       , cpu.project_p_filepath
	       , cpu.project_id
	       , cpu.project_name
	       , cpu.project_owner_id
	       , cpu.project_created_at
	       , cpu.project_updated_at
	       , cpu.project_state
	       , cpu.project_description
	       , cpu.project_site_id
	       , cpu.project_special
	       , cpu.project_luid
	       , cpu.project_controlled_permissions_enabled
	       , cpu.project_p_cre_date
	       , cpu.project_p_active_flag
	       , cpu.project_p_valid_from
	       , cpu.project_p_valid_to
	       , cpu.workbook_p_id
	       , cpu.workbook_p_filepath
	       , cpu.workbook_id
	       , cpu.workbook_name
	       , cpu.workbook_repository_url
	       , cpu.workbook_description
	       , cpu.workbook_created_at
	       , cpu.workbook_updated_at
	       , cpu.workbook_owner_id
	       , cpu.workbook_project_id
	       , cpu.workbook_view_count
	       , cpu.workbook_size
	       , cpu.workbook_embedded
	       , cpu.workbook_thumb_user
	       , cpu.workbook_refreshable_extracts
	       , cpu.workbook_extracts_refreshed_at
	       , cpu.workbook_lock_version
	       , cpu.workbook_state
	       , cpu.workbook_version
	       , cpu.workbook_checksum
	       , cpu.workbook_display_tabs
	       , cpu.workbook_data_engine_extracts
	       , cpu.workbook_incrementable_extracts
	       , cpu.workbook_site_id
	       , cpu.workbook_revision
	       , cpu.workbook_repository_data_id
	       , cpu.workbook_repository_extract_data_id
	       , cpu.workbook_first_published_at
	       , cpu.workbook_primary_content_url
	       , cpu.workbook_share_description
	       , cpu.workbook_show_toolbar
	       , cpu.workbook_extracts_incremented_at
	       , cpu.workbook_default_view_index
	       , cpu.workbook_luid
	       , cpu.workbook_asset_key_id
	       , cpu.workbook_document_version
	       , cpu.workbook_content_version
	       , cpu.workbook_p_cre_date
	       , cpu.workbook_p_active_flag
	       , cpu.workbook_p_valid_from
	       , cpu.workbook_p_valid_to
	       , cpu.interactor_s_user_p_id
	       , cpu.interactor_s_user_p_filepath
	       , cpu.interactor_s_user_id
	       , cpu.interactor_s_user_name
	       , cpu.interactor_s_user_email
	       , cpu.interactor_s_user_hashed_password
	       , cpu.interactor_s_user_salt
	       , cpu.interactor_s_user_sys
	       , cpu.interactor_s_user_keychain
	       , cpu.interactor_s_user_domain_id
	       , cpu.interactor_s_user_friendly_name
	       , cpu.interactor_s_user_custom_display_name
	       , cpu.interactor_s_user_activation_code
	       , cpu.interactor_s_user_activated_at
	       , cpu.interactor_s_user_state
	       , cpu.interactor_s_user_admin_level
	       , cpu.interactor_s_user_created_at
	       , cpu.interactor_s_user_updated_at
	       , cpu.interactor_s_user_deleted_at
	       , cpu.interactor_s_user_auth_user_id
	       , cpu.interactor_s_user_asset_key_id
	       , cpu.interactor_s_user_p_cre_date
	       , cpu.interactor_s_user_p_active_flag
	       , cpu.interactor_s_user_p_valid_from
	       , cpu.interactor_s_user_p_valid_to
	       , cpu.publisher_user_p_id
	       , cpu.publisher_user_p_filepath
	       , cpu.publisher_user_id
	       , cpu.publisher_user_login_at
	       , cpu.publisher_user_licensing_role_id
	       , cpu.publisher_user_nonce
	       , cpu.publisher_user_row_limit
	       , cpu.publisher_user_storage_limit
	       , cpu.publisher_user_created_at
	       , cpu.publisher_user_extracts_required
	       , cpu.publisher_user_updated_at
	       , cpu.publisher_user_admin_level
	       , cpu.publisher_user_publisher_tristate
	       , cpu.publisher_user_raw_data_suppressor_tristate
	       , cpu.publisher_user_site_id
	       , cpu.publisher_user_system_user_id
	       , cpu.publisher_user_system_admin_auto
	       , cpu.publisher_user_luid
	       , cpu.publisher_user_p_cre_date
	       , cpu.publisher_user_p_active_flag
	       , cpu.publisher_user_p_valid_from
	       , cpu.publisher_user_p_valid_to
	       , cpu.publisher_s_user_p_id
	       , cpu.publisher_s_user_p_filepath
	       , cpu.publisher_s_user_id
	       , cpu.publisher_s_user_name
	       , cpu.publisher_s_user_email
	       , cpu.publisher_s_user_hashed_password
	       , cpu.publisher_s_user_salt
	       , cpu.publisher_s_user_sys
	       , cpu.publisher_s_user_keychain
	       , cpu.publisher_s_user_domain_id
	       , cpu.publisher_s_user_friendly_name
	       , cpu.publisher_s_user_custom_display_name
	       , cpu.publisher_s_user_activation_code
	       , cpu.publisher_s_user_activated_at
	       , cpu.publisher_s_user_state
	       , cpu.publisher_s_user_admin_level
	       , cpu.publisher_s_user_created_at
	       , cpu.publisher_s_user_updated_at
	       , cpu.publisher_s_user_deleted_at
	       , cpu.publisher_s_user_auth_user_id
	       , cpu.publisher_s_user_asset_key_id
	       , cpu.publisher_s_user_p_cre_date
	       , cpu.publisher_s_user_p_active_flag
	       , cpu.publisher_s_user_p_valid_from
	       , cpu.publisher_s_user_p_valid_to
	       , cpu.session_duration
	       , cpu.thread_name
	       , cpu.site_name_id
	       , cpu.project_name_id
	       , cpu.site_project
	       , cpu.workbook_name_id
	       , cpu.cpu_usage_user_type 
		   , extract(''epoch'' from (
		   							max(cpu.cpu_usage_ts) over (partition by cpu.cpu_usage_parent_vizql_session)
		   							-
		   							cpu.session_start_ts
		   							)		   
		   			) as elapsed_seconds_to_bootstrap
		from
			p_cpu_usage_report cpu
		left outer join p_interactor_session s on (
		                                    s.session_start_ts >= date''#v_from#'' and
											-- plus one hour as a safety net
		                                    s.session_start_ts <= timestamp''#v_to#'' + interval''1 hour'' and
		                                    s.vizql_session = cpu.cpu_usage_parent_vizql_session and
		                                    s.process_name = ''vizqlserver'')
		where
			cpu.cpu_usage_ts_rounded_15_secs >= date''#v_from#'' and	
			cpu.cpu_usage_ts_rounded_15_secs <= timestamp''#v_to#'' and	
			cpu_usage_parent_vizql_session is not null and
		    cpu_usage_parent_vizql_session not in (''Non-Interactor Vizql'', ''-'')  and
		                      cpu_usage_ts <= s.session_start_ts +
												(interval''1 second'' * coalesce(s.bootstrap_elapsed_secs, 0)) +
												(interval''1 second'' * coalesce(s.show_elapsed_secs,0)) +
												(interval''1 second'' * coalesce(s.show_bootstrap_delay_secs,0))										
										+ interval ''15 second''
		';			
			
		v_sql := replace(v_sql, '#v_from#', v_from);
		v_sql := replace(v_sql, '#v_to#', v_to);		
		
		raise notice 'I: %', v_sql;
		execute v_sql;

		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
		return v_num_inserted;

END;
$$ LANGUAGE plpgsql;