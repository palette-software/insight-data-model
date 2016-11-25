CREATE or replace function load_s_http_requests_with_workbooks(p_schema_name text, p_load_date date) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;
    v_load_date_txt text := to_char(p_load_date, 'yyyy-mm-dd');
begin

    execute 'set local search_path = ' || p_schema_name;
    
	v_sql := 'insert into s_http_requests_with_workbooks
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
	  CASE 
	  	WHEN sum(case when http_request_uri like ''%#/authoring#/%'' escape character ''#'' and p_http_requests.action = ''show'' then 1 else 0 end) > 0 THEN ''web author'' 
	  	WHEN sum(case when p_http_requests.action = ''show'' then 1 else 0 end) > 0 THEN ''interactor'' END
      	AS user_type
	FROM 
		p_http_requests 
	WHERE
	  coalesce(currentsheet, '''') <> '''' AND 
	  vizql_session IS NOT NULL AND 
	  vizql_session <> ''-'' AND 
	  site_id IS NOT NULL AND
      created_at >= date''#v_load_date_txt#'' - interval ''1 day'' AND
      created_at <= date''#v_load_date_txt#'' + interval ''26 hours''
	group by
		site_id,
	  	vizql_session,
	  	split_part(currentsheet,''/'', 1)';

    v_sql := replace(v_sql, '#v_load_date_txt#', v_load_date_txt);
    raise notice 'I: %', v_sql;
	execute v_sql;
		
	GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
		
	return v_num_inserted;
END;
$$ LANGUAGE plpgsql;
