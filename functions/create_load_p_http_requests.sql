CREATE or replace function create_load_p_http_requests(p_schema_name text) returns int
AS $$
declare	
	rec record;
	v_insert_part text;
	v_select_part text;
	v_sql text;
begin							
	
	   	v_insert_part := '';
		v_select_part := '';
		
		for rec in (select 
						column_name as col_name,
						'r.' || column_name as col_name_with_alias
					from
						information_schema.columns c
					where
						table_schema = p_schema_name and
						table_name = 'http_requests' and
						column_name not in ('id', 'p_id', 'p_filepath', 'p_cre_date') and
						column_name in (select 
											column_name 
										from
											information_schema.columns 
										where
											table_schema = p_schema_name and
											table_name = 'p_http_requests' and
											column_name not in ('site_name',
																'interactor_user_id',
																'interactor_system_users_id',
																'interactor_username',
																'interactor_friendly_name',
																'workbook_id',
																'workbook_name',
																'workbook_repository_url',
																'publisher_user_id',
																'project_id',
																'publisher_system_users_id',
																'publisher_username',
																'publisher_friendly_name',
																'project_name',
																'created_at_month',
																'h_projects_p_id',
																'publisher_h_users_p_id',
																'publisher_h_system_users_p_id',
																'h_sites_p_id',
																'h_workbooks_p_id',
																'interactor_h_users_p_id',
																'interactor_h_system_users_p_id',
                                                                'view_id')
										)	
					order by						
						ordinal_position)
		loop			
		
			  v_insert_part := v_insert_part || rec.col_name || ',';
			  v_select_part := v_select_part || rec.col_name_with_alias || ',';
			  
		end loop;
					
					
		v_sql := 		
				'CREATE or replace function #function_schema_name#.load_p_http_requests(p_schema_name text) returns bigint
				AS \$\$
				declare
					v_sql text;
					v_num_inserted bigint;
					v_sql_cur text;
                    v_max_date date;
				begin
                
                            execute ''set local search_path = '' || p_schema_name;
                            
                            v_sql_cur := ''select get_max_ts(''''#schema_name#'''', ''''p_threadinfo_delta'''')'';
                        	v_sql_cur := replace(v_sql_cur, ''#schema_name#'', p_schema_name);
                        	execute v_sql_cur into v_max_date;
                            
							v_sql := 
								''								
				';
					
					
		v_sql := v_sql || 'insert into p_http_requests(http_requests_p_id, http_requests_id,';	
		
		v_sql := v_sql || v_insert_part;
		v_sql := v_sql || '
				 "site_name",
				 "interactor_user_id",
				 "interactor_system_users_id",
				 "interactor_username",
				 "interactor_friendly_name",
				 "workbook_id",
				 "workbook_name",
				 "workbook_repository_url",
				 "publisher_user_id",
				 "project_id",
				 "publisher_system_users_id",
				 "publisher_username",
				 "publisher_friendly_name",
				 "project_name",
				 "created_at_month",
				 "h_projects_p_id",
				 "publisher_h_users_p_id",
				 "publisher_h_system_users_p_id",
				 "h_sites_p_id",
				 "h_workbooks_p_id",
				 "interactor_h_users_p_id",
				 "interactor_h_system_users_p_id",
                 "view_id")';
						
		v_sql := v_sql || '
			with t_requests as 
				(select t.*, 
						SPLIT_PART(t.currentsheet,''''/'''',1) workbook_url,
                        (string_to_array(t.currentsheet, ''''/'''')) [1] || ''''/sheets/'''' || (string_to_array(t.currentsheet, ''''/'''')) [2] as view_rep_url
				from 
					http_requests t
                where 1 = 1
                    and t.p_id > (select coalesce(max(http_requests_p_id), 0)
                                 from
                                    p_http_requests
                                 where
                                    created_at >= date''''#v_max_date#''''
                                  )
                    
                )
					
				SELECT
                    r.p_id,
					r.id,
  		';
		
		v_sql := v_sql || v_select_part;
		
		v_sql := v_sql || '				
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
				  date_trunc(''''month'''', r.created_at) as creatad_at_month,
				  p.p_id as h_projects_p_id,
				  wb_u.p_id as publisher_h_users_p_id,
				  wb_su.p_id as publisher_h_system_users_p_id,
				  s.p_id as h_sites_p_id,
				  wb.p_id as h_workbooks_p_id,
				  u.p_id as interactor_h_users_p_id,
				  su.p_id as interactor_h_system_users_p_id,
                  v.id as view_id
		';
		
		
		v_sql := v_sql || 
		' FROM  
				    t_requests r
				    left outer join h_users u on (u.id  = r.user_id and
																u.site_id = r.site_id and
															    r.created_at between u.p_valid_from and u.p_valid_to)
				    left outer join h_system_users su on (su.id = u.system_user_id and
																			r.created_at between su.p_valid_from and su.p_valid_to)															  															  
					left outer join h_workbooks wb on (wb.site_id = r.site_id and
																	wb.repository_url = r.workbook_url and 
													  				r.created_at between wb.p_valid_from and wb.p_valid_to)
					left outer join h_projects p on (p.site_id = r.site_id and
																	   p.id = wb.project_id and
																	   r.created_at between p.p_valid_from and p.p_valid_to)
				    left outer join h_users wb_u on (wb_u.id  = wb.owner_id and
																   wb_u.site_id = wb.site_id and
																	  r.created_at between wb_u.p_valid_from and wb_u.p_valid_to)
				    left outer join h_system_users wb_su on (wb_su.id = wb_u.system_user_id and
																			  r.created_at between wb_su.p_valid_from and wb_su.p_valid_to)
				 	left outer join h_sites s on (s.id = r.site_id and
				  						  							r.created_at between s.p_valid_from and s.p_valid_to)
                    left outer join h_views v on (v.site_id = r.site_id and
                                                                v.repository_url = r.view_rep_url and
				  						  						r.created_at between v.p_valid_from and v.p_valid_to)
			'';				
		';			
		
						
		
		v_sql := v_sql || '		
											
				v_sql := replace(v_sql, ''#v_max_date#'', to_char(v_max_date, ''yyyy-mm-dd''));
				
				raise notice ''I: %'', v_sql;
				execute v_sql;		
				GET DIAGNOSTICS v_num_inserted = ROW_COUNT;			
				return v_num_inserted;
		END;
		\$\$ LANGUAGE plpgsql;';
				
				
		v_sql := replace(v_sql, '#function_schema_name#', p_schema_name);
		raise notice 'I: %', v_sql;
		execute v_sql;
		
		return 0;
END; 
$$ LANGUAGE plpgsql;