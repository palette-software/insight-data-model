CREATE or replace function load_s_http_requests_with_workbooks(p_schema_name text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;
begin
		v_sql := 'insert into #schema_name#.s_http_requests_with_workbooks
		(
			site_id,
			vizql_session,
			repository_url,
			workbook_id,
			user_ip,
			completed_at,
			h_workbooks_p_id,	
			h_projects_p_id,
			publisher_h_users_p_id,
			publisher_h_system_users_p_id,
			h_sites_p_id,
			interactor_h_users_p_id,
			interactor_h_system_users_p_id,
			user_type
		)
		SELECT       
		  site_id,
		  vizql_session,
		  split_part(currentsheet,''/'', 1) repository_url,
		  max(workbook_id),
		  max(user_ip) as user_ip,
		  max(completed_at) as completed_at,
		  max(h_workbooks_p_id), 
		  max(h_projects_p_id),
		  max(publisher_h_users_p_id),
		  max(publisher_h_system_users_p_id),
		  max(h_sites_p_id),
		  max(interactor_h_users_p_id) as interactor_h_users_p_id,
		  max(interactor_h_system_users_p_id) as interactor_h_system_users_p_id,
		  CASE WHEN p_http_requests.vizql_session is not NULL AND
                      max(split_part(p_http_requests.http_request_uri, ''/'', 2)) = ''authoring'' AND
                      max(p_http_requests.action) = ''show'' THEN ''web author''
               WHEN p_http_requests.vizql_session is not NULL AND
                      max(split_part(p_http_requests.http_request_uri, ''/'', 2)) != ''authoring'' AND
                      max(p_http_requests.action) = ''show'' THEN ''interactor'' END
          AS user_type
		FROM 
			#schema_name#.p_http_requests 
		WHERE
		  coalesce(currentsheet, '''') <> '''' AND 
		  vizql_session IS NOT NULL AND 
		  vizql_session <> ''-'' AND 
		  site_id IS NOT NULL   
		group by
			site_id,
		  	vizql_session,
		  	split_part(currentsheet,''/'', 1)';

		v_sql := replace(v_sql, '#schema_name#', p_schema_name);
		
		execute v_sql;
			
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
			
		return v_num_inserted;
END;
$$ LANGUAGE plpgsql;