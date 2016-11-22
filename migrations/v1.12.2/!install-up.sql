\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

grant select on p_threadinfo_delta to palette_palette_looker;

ALTER TABLE p_cpu_usage_report ALTER cpu_usage_cpu_core_consumption SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_cpu_time_consumption_hours SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_cpu_time_consumption_minutes SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_cpu_time_consumption_seconds SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_cpu_time_consumption_ticks SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_dataserver_session SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_h_projects_p_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_h_sites_p_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_h_workbooks_p_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_host_name SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_interactor_h_system_users_p_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_interactor_h_users_p_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_is_allocatable SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_is_thread_level SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_max_reporting_granularity SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_memory_usage_bytes SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_p_id SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_p_threadinfo_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_parent_dataserver_session SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_parent_process_type SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_parent_vizql_destroy_sess_ts SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_parent_vizql_session SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_process_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_process_level SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_process_name SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_process_owner SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_publisher_h_system_users_p_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_publisher_h_users_p_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_repository_url SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_site_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_spawned_by_parent_ts SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_thread_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_ts SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_ts_date SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_ts_day_hour SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_ts_interval_ticks SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_ts_rounded_15_secs SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_user_ip SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_user_type SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_username SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_vizql_session SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER cpu_usage_workbook_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_activated_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_activation_code SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_admin_level SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_asset_key_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_auth_user_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_created_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_custom_display_name SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_deleted_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_domain_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_email SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_friendly_name SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_hashed_password SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_id SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_keychain SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_name SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_p_active_flag SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_p_cre_date SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_p_filepath SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_p_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_p_valid_from SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_p_valid_to SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_salt SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_state SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_sys SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER interactor_s_user_updated_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER p_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER project_controlled_permissions_enabled SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER project_created_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER project_description SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER project_id SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER project_luid SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER project_name SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER project_name_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER project_owner_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER project_p_active_flag SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER project_p_cre_date SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER project_p_filepath SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER project_p_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER project_p_valid_from SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER project_p_valid_to SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER project_site_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER project_special SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER project_state SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER project_updated_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_activated_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_activation_code SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_admin_level SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_asset_key_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_auth_user_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_created_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_custom_display_name SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_deleted_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_domain_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_email SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_friendly_name SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_hashed_password SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_id SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_keychain SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_name SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_p_active_flag SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_p_cre_date SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_p_filepath SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_p_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_p_valid_from SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_p_valid_to SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_salt SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_state SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_sys SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_s_user_updated_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_admin_level SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_created_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_extracts_required SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_licensing_role_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_login_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_luid SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_nonce SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_p_active_flag SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_p_cre_date SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_p_filepath SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_p_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_p_valid_from SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_p_valid_to SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_publisher_tristate SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_raw_data_suppressor_tristate SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_row_limit SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_site_id SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_storage_limit SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_system_admin_auto SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_system_user_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER publisher_user_updated_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER session_duration SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER session_end_ts SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER session_start_ts SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER site_authoring_disabled SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_content_admin_mode SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_created_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_custom_subscription_email SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_custom_subscription_footer SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_id SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER site_livedb_connections_whitelist_enabled SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_luid SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_metrics_level SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_name SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER site_name_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_p_active_flag SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_p_cre_date SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_p_filepath SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_p_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_p_valid_from SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_p_valid_to SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_project SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_query_limit SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_refresh_token_setting SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_sheet_image_enabled SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_status SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_status_reason SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_storage_quota SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_subscriptions_enabled SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_updated_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_url_namespace SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_user_quota SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER site_version_history_enabled SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER thread_name SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_asset_key_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_checksum SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_content_version SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_created_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_data_engine_extracts SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_default_view_index SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_description SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_display_tabs SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_document_version SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_embedded SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_extracts_incremented_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_extracts_refreshed_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_first_published_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_id SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER workbook_incrementable_extracts SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_lock_version SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_luid SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_name SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER workbook_name_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_owner_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_p_active_flag SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_p_cre_date SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_p_filepath SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_p_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_p_valid_from SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_p_valid_to SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_primary_content_url SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_project_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_refreshable_extracts SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_repository_data_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_repository_extract_data_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_repository_url SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_revision SET STATISTICS -1;
ALTER TABLE p_cpu_usage_report ALTER workbook_share_description SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_show_toolbar SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_site_id SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_size SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_state SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_thumb_user SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_updated_at SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_version SET STATISTICS 0;
ALTER TABLE p_cpu_usage_report ALTER workbook_view_count SET STATISTICS 0;

ALTER TABLE p_serverlogs ALTER p_cre_date SET STATISTICS 0;
ALTER TABLE p_serverlogs ALTER p_filepath SET STATISTICS 0;
ALTER TABLE p_serverlogs ALTER v SET STATISTICS 0;
ALTER TABLE p_serverlogs ALTER v_truncated SET STATISTICS 0;

ALTER TABLE serverlogs ALTER p_cre_date SET STATISTICS 0;
ALTER TABLE serverlogs ALTER p_filepath SET STATISTICS 0;
ALTER TABLE serverlogs ALTER v SET STATISTICS 0;
    

insert into db_version_meta(version_number) values ('v1.12.2');

COMMIT;