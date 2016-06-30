CREATE OR REPLACE VIEW p_workbooks AS
select wb.p_id,
       wb.id,
       wb.name,
       wb.repository_url,
       wb.description,
       wb.created_at,
       wb.updated_at,
       wb.owner_id,
       wb.project_id,
       wb.view_count,
       wb.size,
       wb.embedded,
       wb.thumb_user,
       wb.refreshable_extracts,
       wb.extracts_refreshed_at,
       wb.lock_version,
       wb.state,
       wb.version,
       wb.checksum,
       wb.display_tabs,
       wb.data_engine_extracts,
       wb.incrementable_extracts,
       wb.site_id,
       wb.revision,
       wb.repository_data_id,
       wb.repository_extract_data_id,
       wb.first_published_at,
       wb.primary_content_url,
       wb.share_description,
       wb.show_toolbar,
       wb.extracts_incremented_at,
       wb.default_view_index,
       wb.luid,
       wb.asset_key_id,
       wb.document_version,
       wb.p_cre_date,
       wb.p_active_flag,
       wb.p_valid_from,
       wb.p_valid_to,
       wb.p_filepath,
       ((p.name::text || ' ('::text) || p.id::text) || ')'::text AS project_name_id, 
       ((s.name::text || ' ('::text) || s.id::text) || ')'::text AS site_name_id, 
       ((wb_su.name::text || ' ('::text) || wb.owner_id::text) || ')'::text AS publisher_name_id, 
       ((wb.name::text || ' ('::text) || wb.id::text) || ')'::text AS workbook_name_id, 
       'WORKBOOK'::text AS type
from palette.h_workbooks wb
left outer join palette.h_projects p on (p.id = wb.project_id and p.site_id = wb.site_id and least(wb.p_valid_to, p.p_valid_to) >= greatest(wb.p_valid_from, p.p_valid_from))
left outer join palette.h_sites s on (s.id = wb.site_id and least(wb.p_valid_to, s.p_valid_to) >= greatest(wb.p_valid_from, s.p_valid_from))
left outer join palette.h_users wb_u on (wb_u.id  = wb.owner_id and wb_u.site_id = wb.site_id and least(wb.p_valid_to, wb_u.p_valid_to) >= greatest(wb.p_valid_from, wb_u.p_valid_from))
left outer join palette.h_system_users wb_su on (wb_su.id = wb_u.system_user_id and least(wb.p_valid_to, wb_su.p_valid_to) >= greatest(wb.p_valid_from, wb_su.p_valid_from))
group by
wb.p_id, wb.id, wb.name, wb.repository_url, wb.description, wb.created_at, wb.updated_at, wb.owner_id, wb.project_id, wb.view_count, wb.size, wb.embedded, wb.thumb_user, wb.refreshable_extracts, wb.extracts_refreshed_at, wb.lock_version, wb.state, wb.version, wb.checksum, wb.display_tabs, wb.data_engine_extracts, wb.incrementable_extracts, wb.site_id, wb.revision, wb.repository_data_id, wb.repository_extract_data_id, wb.first_published_at, wb.primary_content_url, wb.share_description, wb.show_toolbar, wb.extracts_incremented_at, wb.default_view_index, wb.luid, wb.asset_key_id, wb.document_version, wb.p_cre_date, wb.p_active_flag, wb.p_valid_from, wb.p_valid_to, wb.p_filepath, ((p.name::text || ' ('::text) || p.id::text) || ')'::text, ((s.name::text || ' ('::text) || s.id::text) || ')'::text, ((wb_su.name::text || ' ('::text) || wb.owner_id::text) || ')'::text, ((wb.name::text || ' ('::text) || wb.id::text) || ')'::text, 'WORKBOOK'::text
;
