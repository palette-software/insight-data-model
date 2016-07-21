CREATE or replace function create_load_s_cpu_usage_report(p_schema_name text) returns int
AS $$
declare	
	rec record;
	v_sql text;
	v_insert_part text;
	v_select_part text;
		
begin							
	
		v_insert_part := '';
		v_select_part := '';
		
		for rec in (select col_name || ' ' || data_type || decode(data_type, 'character varying', ' (' || character_maximum_length || ')',
														 'numeric', ' (' || numeric_precision_radix || ',' || coalesce(numeric_scale, '0') || ')',
														 '') || ',' as col_def,
					alias_name || ',' as ins_def,
					col_name || ',' as col_name							

					from
					(
					select
						  1 as gen_seq,
						  table_name, 
						  column_name, 
						  ordinal_position,
						  case table_name
							when 'p_cpu_usage' then 'cpu_usage'
							when 'h_sites' then 'site'
							when 'h_projects' then 'project'
							when 'h_workbooks' then 'workbook'
							when 'h_system_users' then 'interactor_s_user'		
						 end || '_' || column_name as col_name,
						 case table_name
							when 'p_cpu_usage' then 'cpu'
							when 'h_sites' then 's'
							when 'h_projects' then 'p'
							when 'h_workbooks' then 'wb'
							when 'h_system_users' then 'su_int'		
						 end || '.' || column_name as alias_name,
						 data_type ,
						 character_maximum_length,
						 numeric_precision_radix,
						 numeric_scale
					from
						information_schema.columns c
					where
						table_schema = p_schema_name and
						column_name not in ('p_filepath') and
						(table_name in ('h_sites', 'h_projects', 'h_workbooks', 'h_system_users') or
						(table_name = 'p_cpu_usage' and column_name not in ('start_ts', 'end_ts')))
												
					union all 

					select 
						  2,
						  table_name, 
						  column_name, 
						  ordinal_position,
						  case table_name
							when 'h_users' then 'publisher_user'
							when 'h_system_users' then 'publisher_s_user'	
						 end || '_' || column_name as col_name,
						 case table_name
							when 'h_users' then 'u_pub'
							when 'h_system_users' then 'us_pub'	
						 end || '.' || column_name as alias_name,
						 data_type ,
						 character_maximum_length,
						 numeric_precision_radix,
						 numeric_scale
					from
						information_schema.columns c
					where
						table_schema = p_schema_name and
						table_name in ('h_users', 'h_system_users') and
						column_name not in ('p_filepath')
					) a	
					where
						(a.table_name, a.column_name) in 
							(select								
								case 
									when substr(c.column_name, 1, length('cpu_usage')) = 'cpu_usage' then 'p_cpu_usage'
									when substr(c.column_name, 1, length('interactor_s_user')) = 'interactor_s_user' then 'h_system_users'
									when substr(c.column_name, 1, length('project')) = 'project' then 'h_projects'
									when substr(c.column_name, 1, length('publisher_s_user')) = 'publisher_s_user' then 'h_system_users'
									when substr(c.column_name, 1, length('publisher_user')) = 'publisher_user' then 'h_users'
									when substr(c.column_name, 1, length('workbook')) = 'workbook' then 'h_workbooks'
									when substr(c.column_name, 1, length('site')) = 'site' then 'h_sites'									
								end as table_name,
								case 
									when substr(c.column_name, 1, length('cpu_usage')) = 'cpu_usage' then substr(c.column_name, length('cpu_usage') + 2)
									when substr(c.column_name, 1, length('interactor_s_user')) = 'interactor_s_user' then substr(c.column_name, length('interactor_s_user') + 2)
									when substr(c.column_name, 1, length('project')) = 'project' then substr(c.column_name, length('project') + 2)
									when substr(c.column_name, 1, length('publisher_s_user')) = 'publisher_s_user' then substr(c.column_name, length('publisher_s_user') + 2)
									when substr(c.column_name, 1, length('publisher_user')) = 'publisher_user' then substr(c.column_name, length('publisher_user') + 2)
									when substr(c.column_name, 1, length('workbook')) = 'workbook' then substr(c.column_name, length('workbook') + 2)
									when substr(c.column_name, 1, length('site')) = 'site' then substr(c.column_name, length('site') + 2)
									else
										c.column_name
								end orig_col_name
							from
								information_schema.columns c
							where
								c.table_schema = p_schema_name and
								c.table_name = 'p_cpu_usage_report')
					order by
						gen_seq,
						case table_name
							when 'p_cpu_usage' then 1
							when 'h_sites' then 2
							when 'h_projects' then 3
							when 'h_workbooks' then 4
							when 'h_users' then 5
							when 'h_system_users' then 6
						end,
						ordinal_position)
		loop			
		
			  v_insert_part := v_insert_part || rec.col_name || '\n';
			  v_select_part := v_select_part || rec.ins_def || '\n';
			  			  
		end loop;
					
					
		v_sql := 		
				'CREATE OR REPLACE FUNCTION #function_schema_name#.load_s_cpu_usage_report(p_schema_name text) returns bigint
				AS \$\$
				declare
					v_sql text;
					v_sql_cur text;
					v_num_inserted bigint;
					v_max_ts_date text;
					
				begin	

							execute ''set local search_path = '' || p_schema_name;
							
							v_sql_cur := ''select to_char((select get_max_ts_date(''''#schema_name#'''', ''''p_cpu_usage_report'''')), ''''yyyy-mm-dd'''')'';
							v_sql_cur := replace(v_sql_cur, ''#schema_name#'', p_schema_name);													
							execute v_sql_cur into v_max_ts_date;
							v_max_ts_date := ''date'''''' || v_max_ts_date || '''''''';

																					
							v_sql := ''create table tmp_cpu0 as 
										select distinct h_projects_p_id, h_sites_p_id, interactor_h_system_users_p_id, h_workbooks_p_id, publisher_h_users_p_id, publisher_h_system_users_p_id
										from 	
											p_cpu_usage cpu
										where
											cpu.ts_rounded_15_secs >= #v_max_ts_date#
										'';
							
							v_sql := replace(v_sql, ''#v_max_ts_date#'', v_max_ts_date);	
							execute v_sql;							
							
							analyze tmp_cpu0;
							
							
							v_sql := 
								''								
				';
					
					
		v_sql := v_sql || 'insert into s_cpu_usage_report (';	
		
		v_sql := v_sql || v_insert_part;
		v_sql := v_sql || 'session_start_ts,
						   session_end_ts,
						   session_duration,
						   thread_name,
						   site_name_id,
						   project_name_id,
						   site_project,
						   workbook_name_id						   						   						   
						  ';
						  
		v_sql := v_sql || ')		
							
		select ';
		
		v_sql := v_sql || v_select_part;
		
		v_sql := v_sql || ' cpu.start_ts as session_start_ts,
						   cpu.end_ts as session_end_ts,							
						   cpu.end_ts - cpu.start_ts as session_duration,
						   cpu.process_name || '''':'''' || cpu.process_id || '''':'''' || cpu.thread_id as thread_name,							
						   s.name || '''' ('''' || s.id || '''')'''' as site_name_id,
						   p.name || '''' ('''' || p.id || '''')'''' as project_name_id,
						   s.name || '''':'''' || p.name as site_project,
						   wb.name || '''' ('''' || wb.id || '''')'''' as workbook_name_id														   
				';
		
		v_sql := v_sql || '
				FROM tmp_cpu0 cpu0
                    left outer join h_projects p on (p.p_id = cpu0.h_projects_p_id)
                    left outer join h_sites s on (s.p_id = cpu0.h_sites_p_id)
                    left outer join h_system_users su_int on (su_int.p_id = cpu0.interactor_h_system_users_p_id)
                    left outer join h_workbooks wb on (wb.p_id = cpu0.h_workbooks_p_id)       
                    left outer join h_users u_pub on (u_pub.p_id = cpu0.publisher_h_users_p_id)
                    left outer join h_system_users us_pub on (us_pub.p_id = cpu0.publisher_h_system_users_p_id)
                    inner join p_cpu_usage cpu on
                    (coalesce(cpu.h_projects_p_id, -1) = coalesce(cpu0.h_projects_p_id, -1)
                     AND coalesce(cpu.h_sites_p_id, -1) = coalesce(cpu0.h_sites_p_id, -1)
                     AND coalesce(cpu.interactor_h_system_users_p_id, -1) = coalesce(cpu0.interactor_h_system_users_p_id, -1)
                     AND coalesce(cpu.h_workbooks_p_id, -1) = coalesce(cpu0.h_workbooks_p_id, -1)
                     AND coalesce(cpu.publisher_h_users_p_id, -1) = coalesce(cpu0.publisher_h_users_p_id, -1)
                     AND coalesce(cpu.publisher_h_system_users_p_id, -1) = coalesce(cpu0.publisher_h_system_users_p_id, -1)
                    )
                WHERE cpu.ts_rounded_15_secs >= #v_max_ts_date#
		';
		
		v_sql := v_sql || '
				'';

				v_sql := replace(v_sql, ''#v_max_ts_date#'', v_max_ts_date);
				
				raise notice ''I: %'', v_sql;
				execute ''set local join_collapse_limit = 1'';
				execute v_sql;		
				GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
				
				drop table tmp_cpu0;
				
				return v_num_inserted;
		END;
		\$\$ LANGUAGE plpgsql;';
				
				
		v_sql := replace(v_sql, '#function_schema_name#', p_schema_name);
		
		raise notice 'I: %', v_sql;
		execute v_sql;
		
		return 0;
END; 
$$ LANGUAGE plpgsql;