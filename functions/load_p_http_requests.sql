CREATE or replace function load_p_http_requests(p_schema_name text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;
	
begin	
			v_sql := 
				'insert into #schema_name#.p_http_requests
				(
				   http_requests_id,
				   controller,
				   action,
				   http_referer,
				   http_user_agent,
				   http_request_uri,
				   remote_ip,
				   created_at,
				   session_id,
				   completed_at,
				   port,
				   user_id,
				   worker,
				   status,
				   user_cookie,
				   user_ip,
				   vizql_session,
				   site_id,
				   currentsheet,
				   site_name,
				   interactor_user_id,
				   interactor_system_users_id,
				   interactor_username,
				   interactor_friendly_name,
				   workbook_id,
				   workbook_name,
				   workbook_repository_url,
				   publisher_user_id,
				   project_id,
				   publisher_system_users_id,
				   publisher_username,
				   publisher_friendly_name,
				   project_name,   
				   created_at_month,
				   h_projects_p_id,
				   publisher_h_users_p_id,
				   publisher_h_system_users_p_id,
				   h_sites_p_id,
				   h_workbooks_p_id,
				   interactor_h_users_p_id,
				   interactor_h_system_users_p_id
				)

				with t_requests as 
				(select t.*, 
						SPLIT_PART(t.currentsheet,''/'',1) workbook_url 
				from 
					#schema_name#.http_requests t)
					
				SELECT
				  r.id,
				  r.controller,
				  r.action,
				  r.http_referer,
				  r.http_user_agent,
				  r.http_request_uri,
				  r.remote_ip,
				  r.created_at,
				  r.session_id,
				  r.completed_at,
				  r.port,
				  r.user_id,
				  r.worker,
				  r.status,
				  r.user_cookie,
				  r.user_ip,
				  r.vizql_session,
				  r.site_id,
				  r.currentsheet,
				  s.name as site_name,
				  u.id as interactor_user_id,
				  su.id as interactor_system_users_id,
				  su.name as interactor_username,
				  su.friendly_name as interactor_friendly_name,
				  wb.id as workbook_id,
				  wb.name as workbook_name,
				  wb.repository_url as workbook_repository_url,
				  wb.owner_id as publisher_user_id,
				  wb.project_id,
				  wb_su.id as publisher_system_users_id,
				  wb_su.name as publisher_username,
				  wb_su.friendly_name as publisher_friendly_name,
				  p.name as project_name,
				  date_trunc(''month'', r.created_at) as creatad_at_month,
				  p.p_id as h_projects_p_id,
				  wb_u.p_id as publisher_h_users_p_id,
				  wb_su.p_id as publisher_h_system_users_p_id,
				  s.p_id as h_sites_p_id,
				  wb.p_id as h_workbooks_p_id,
				  u.p_id as interactor_h_users_p_id,
				  su.p_id as interactor_h_system_users_p_id
				FROM t_requests r
				    left outer join #schema_name#.h_users u on (u.id  = r.user_id and
																u.site_id = r.site_id and
															    r.created_at between u.p_valid_from and u.p_valid_to)
				    left outer join #schema_name#.h_system_users su on (su.id = u.system_user_id and
																			r.created_at between su.p_valid_from and su.p_valid_to)															  															  
					left outer join #schema_name#.h_workbooks wb on (wb.site_id = r.site_id and
																	wb.repository_url = r.workbook_url and 
													  				r.created_at between wb.p_valid_from and wb.p_valid_to)
					left outer join #schema_name#.h_projects p on (p.site_id = r.site_id and
																	   p.id = wb.project_id and
																	   r.created_at between p.p_valid_from and p.p_valid_to)
				    left outer join #schema_name#.h_users wb_u on (wb_u.id  = wb.owner_id and
																   wb_u.site_id = wb.site_id and
																	  r.created_at between wb_u.p_valid_from and wb_u.p_valid_to)
				    left outer join #schema_name#.h_system_users wb_su on (wb_su.id = wb_u.system_user_id and
																			  r.created_at between wb_su.p_valid_from and wb_su.p_valid_to)
				 	left outer join #schema_name#.h_sites s on (s.id = r.site_id and
				  						  							r.created_at between s.p_valid_from and s.p_valid_to)';	
			v_sql := replace(v_sql, '#schema_name#', p_schema_name);			
			
			execute v_sql;
			
			GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
			
			return v_num_inserted;
END;
$$ LANGUAGE plpgsql;