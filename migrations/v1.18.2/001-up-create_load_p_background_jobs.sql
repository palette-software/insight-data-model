CREATE or replace function create_load_p_background_jobs(p_schema_name text) returns int
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
						'bj.' || column_name as col_name_with_alias
					from
						information_schema.columns c
					where
						table_schema = p_schema_name and
						table_name = 'background_jobs' and
						column_name not in ('id', 'p_id', 'p_filepath', 'p_cre_date') and
						column_name in (select 
										column_name 
									from
										information_schema.columns 
									where
										table_schema = p_schema_name and
										table_name = 'p_background_jobs' and
										column_name not in ('date_hour',
															'workbooks_datasources_id',
															'workbooks_datasources_name',
                                                            'publisher_id',
															'publisher_name',
															'publisher_friendlyname',
                                                            'project_id',
															'project_name',
															'site_name',
															'wd_type',
															'h_projects_p_id',
															'h_workbooks_datasources_p_id',
															'h_system_users_p_id',
															'h_users_p_id',
															'h_sites_p_id')
									)
					order by						
						ordinal_position)
		loop			
		
			  v_insert_part := v_insert_part || rec.col_name || ',';
			  v_select_part := v_select_part || rec.col_name_with_alias || ',';
			  
		end loop;
					
					
		v_sql := 		
				'CREATE or replace function #function_schema_name#.load_p_background_jobs(p_schema_name text, p_load_date date) returns bigint
				AS \$\$
				declare
					v_sql text;
					v_num_inserted bigint;
					v_sql_cur text;                    
                    v_load_date_txt text := to_char(p_load_date, ''yyyy-mm-dd'');
				begin	
                        execute ''set local search_path = '' || p_schema_name;
                        
                        perform check_if_load_date_already_in_table(p_schema_name, ''p_background_jobs'', p_load_date, false);
    

                        
						v_sql := 
								''								
				';
					
					
		v_sql := v_sql || 'insert into p_background_jobs(background_jobs_p_id, background_jobs_id,';
		
		v_sql := v_sql || v_insert_part;
		v_sql := v_sql || '
				"date_hour",
				"workbooks_datasources_id",
				"workbooks_datasources_name",
                "publisher_id",
				"publisher_name",
				"publisher_friendlyname",
                "project_id",
				"project_name",
				"site_name",
				"wd_type",
				"h_projects_p_id",
				"h_workbooks_datasources_p_id",
				"h_system_users_p_id",
				"h_users_p_id",
				"h_sites_p_id")
		';
		
		v_sql := v_sql || ' with t_workbooks_datasources as
                            (
                            SELECT
                              ''''Workbook'''' wd_type,
                              h_workbooks.id workbooks_datasources_id,
                              h_workbooks.site_id,
                              h_workbooks.name,
                              h_workbooks.owner_id,
                              h_workbooks.project_id,
                              h_workbooks.p_valid_from,
                              h_workbooks.p_valid_to,
                              h_workbooks.p_id
                            FROM h_workbooks
                            UNION ALL
                            SELECT
                              ''''Datasource'''' wd_type,
                              h_datasources.id workbooks_datasources_id,
                              h_datasources.site_id,
                              h_datasources.name,
                              h_datasources.owner_id,
                              h_datasources.project_id,
                              h_datasources.p_valid_from,
                              h_datasources.p_valid_to,
                              h_datasources.p_id
                            FROM h_datasources 
                            ) ';
		
		v_sql := v_sql || ' select distinct bj.p_id, bj.id,';
		v_sql := v_sql || v_select_part;
		
		v_sql := v_sql || '				
                 DATE_TRUNC(''''hour'''',bj.started_at) date_hour,
        		 wd.workbooks_datasources_id,
        		 wd.name,
                 su.id as publisher_id,
        		 su.name as publisher_name,
        		 su.friendly_name as publisher_friendlyname,
                 wd.project_id,
        		 p.name as project_name,
        		 s.name site_name,
        		 wd.wd_type,
        		 p.p_id project_p_id,
        		 wd.p_id wd_p_id,
        		 su.p_id as system_user_p_id,
        		 u.p_id as user_p_id,
        		 s.p_id site_p_id
		';
		
		
		v_sql := v_sql || 
		' FROM
            (select t.*,
                    split_part(replace(args, ''''---'''', ''''''''), ''''\\n- '''', 2) as wd_type,
                    split_part(replace(args, ''''---'''', ''''''''), ''''\\n- '''', 3) as wd_id
            from
                background_jobs t) bj
            left outer join t_workbooks_datasources wd on (1 = 1 
                                                        and wd.site_id = bj.site_id
                                                        and wd.wd_type = bj.wd_type
                                                        and wd.workbooks_datasources_id = bj.wd_id
                                                        and bj.updated_at BETWEEN wd.p_valid_from AND wd.p_valid_to)
                                                        
            left outer join h_users u on (1 = 1 
                                        and u.site_id = bj.site_id
                                        and u.id = wd.owner_id
                                        and bj.updated_at BETWEEN u.p_valid_from AND u.p_valid_to)
                                        
            left outer join h_system_users su on (1 = 1
                                                and su.id = u.system_user_id
                                                and bj.updated_at BETWEEN su.p_valid_from AND su.p_valid_to)
                                                
            left outer join h_projects p on (1 = 1
                                            and p.id = wd.project_id
                                            and p.site_id = wd.site_id
                                            and bj.updated_at BETWEEN p.p_valid_from AND p.p_valid_to)
                  
            left outer join h_sites s on (1 = 1
                                        and s.id = bj.site_id
                                        and bj.updated_at BETWEEN s.p_valid_from AND s.p_valid_to)
         where 1 = 1            
            and bj.updated_at >= date''''#v_load_date_txt#''''
            and bj.updated_at < date''''#v_load_date_txt#'''' + interval ''''1 day''''
		'';
		
		
		';			
		
		v_sql := v_sql || '		
											
				v_sql := replace(v_sql, ''#v_load_date_txt#'', v_load_date_txt);
				
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