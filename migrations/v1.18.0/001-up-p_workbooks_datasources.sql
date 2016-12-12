create or replace view p_workbooks_datasources as
SELECT     
    type
    , p_filepath
    , id as workbook_datasource_id
    , name as workbook_datasource_name
    , repository_url
    , owner_id
    , created_at
    , updated_at    
    , project_id
    , project_name
    , project_name_id
    , size
    , lock_version
    , state
    , null as db_class
    , null as db_name
    , null as table_name
    , site_id
    , site_name 
    , site_name_id
    , revision
    , repository_data_id
    , repository_extract_data_id
    , embedded
    , incrementable_extracts
    , refreshable_extracts
    , data_engine_extracts
    , extracts_refreshed_at
    , first_published_at
    , null as connectable
    , null as is_hierarchical
    , extracts_incremented_at
    , luid
    , asset_key_id
    , document_version
    , description
    , content_version
    , p_cre_date
    , p_active_flag
    , p_valid_from
    , p_valid_to
    , p_id        
    , publisher_id
    , publisher_name
    , publisher_name_id
    , workbook_name_id as workbook_datasource_name_id    
    , show_toolbar
    , display_tabs
    , default_view_index
    , thumb_user
    , view_count
    , share_description
    , primary_content_url
    , checksum
    , version      
FROM 
    p_workbooks
    
union all    

SELECT     
    type
    , p_filepath
    , id as workbook_datasource_id
    , name as workbook_datasource_name
    , repository_url
    , owner_id
    , created_at
    , updated_at
    , project_id
    , project_name
    , project_name_id
    , size
    , lock_version
    , state
    , db_class
    , db_name
    , table_name
    , site_id
    , site_name
    , site_name_id
    , revision
    , repository_data_id
    , repository_extract_data_id
    , embedded
    , incrementable_extracts
    , refreshable_extracts
    , data_engine_extracts
    , extracts_refreshed_at
    , first_published_at
    , connectable
    , is_hierarchical
    , extracts_incremented_at
    , luid
    , asset_key_id
    , document_version
    , description
    , content_version
    , p_cre_date
    , p_active_flag
    , p_valid_from
    , p_valid_to
    , p_id        
    , publisher_id
    , publisher_name
    , publisher_name_id
    , workbook_name_id as workbook_datasource_name_id    
    , null as show_toolbar
    , null as display_tabs
    , null as default_view_index
    , null as thumb_user
    , null as view_count
    , null as share_description
    , null as primary_content_url
    , null as checksum
    , null as version
FROM 
    p_datasources
;