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
						table_name in ('h_users', 'h_system_users')
					) a	
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

							v_sql_cur := ''select to_char((select #schema_name#.get_max_ts_date(''''#schema_name#'''', ''''p_cpu_usage_report'''')), ''''yyyy-mm-dd'''')'';
							v_sql_cur := replace(v_sql_cur, ''#schema_name#'', p_schema_name);
							
						
							execute v_sql_cur into v_max_ts_date;
							v_max_ts_date := ''date'''''' || v_max_ts_date || '''''''';
							
							v_sql := 
								''								
				';
					
					
		v_sql := v_sql || 'insert into #schema_name#.s_cpu_usage_report (';	
		
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
		with t_h_workbooks as 
				(
					select * 
					from
						#schema_name#.h_workbooks
					where
						p_id in
								(select p_id
								from
									#schema_name#.h_workbooks
								intersect
								select distinct h_workbooks_p_id
								from
									#schema_name#.p_cpu_usage
								where
									ts_rounded_15_secs >= #v_max_ts_date#
								)
				),
				t_interactor_h_users as 
				(
					select * 
					from
						#schema_name#.h_users
					where
						p_id in
								(select p_id
								from
									#schema_name#.h_users
								intersect
								select distinct interactor_h_users_p_id
								from
									#schema_name#.p_cpu_usage
								where
									ts_rounded_15_secs >= #v_max_ts_date#
								)									
				),								
				t_interactor_h_system_users as 
				(
					select * 
					from
						#schema_name#.h_system_users
					where
						p_id in
								(select p_id
								from
									#schema_name#.h_system_users
								intersect
								select distinct interactor_h_system_users_p_id
								from
									#schema_name#.p_cpu_usage
								where
									ts_rounded_15_secs >= #v_max_ts_date#
								)									
				),	
				t_publisher_h_users as 
				(
					select * 
					from
						#schema_name#.h_users
					where
						p_id in
								(select p_id
								from
									#schema_name#.h_users
								intersect
								select distinct publisher_h_users_p_id
								from
									#schema_name#.p_cpu_usage
								where
									ts_rounded_15_secs >= #v_max_ts_date#
								)									
				),								
				t_publisher_h_system_users as 
				(
					select * 
					from
						#schema_name#.h_system_users
					where
						p_id in
								(select p_id
								from
									#schema_name#.h_system_users
								intersect
								select distinct publisher_h_system_users_p_id
								from
									#schema_name#.p_cpu_usage
								where
									ts_rounded_15_secs >= #v_max_ts_date#
								)									
				)
							
		select ';
		
		v_sql := v_sql || v_select_part;
		
		v_sql := v_sql || 'min(case when cpu.vizql_session not in (''''-'''', ''''default'''') then cpu.ts end) over (partition by cpu.host_name, cpu.vizql_session) as session_start_ts,
						   max(case when cpu.vizql_session not in (''''-'''', ''''default'''') then cpu.ts end) over (partition by cpu.host_name, cpu.vizql_session) as session_end_ts,
						   
						   max(case when cpu.vizql_session not in (''''-'''', ''''default'''') then cpu.ts end) over (partition by cpu.host_name, cpu.vizql_session) -
						   		min(case when cpu.vizql_session not in (''''-'''', ''''default'''') then cpu.ts end) over (partition by cpu.host_name, cpu.vizql_session) as session_duration,
						   cpu.process_name || '''':'''' || cpu.process_id || '''':'''' || cpu.thread_id as thread_name,							
						   s.name || '''' ('''' || s.id || '''')'''' as site_name_id,
						   p.name || '''' ('''' || p.id || '''')'''' as project_name_id,
						   s.name || '''':'''' || p.name as site_project,
						   wb.name || '''' ('''' || wb.id || '''')'''' as workbook_name_id														   
				';
		
		v_sql := v_sql || '
				FROM #schema_name#.p_cpu_usage cpu
				 	left outer join #schema_name#.h_projects p on (p.p_id = cpu.h_projects_p_id)
					left outer join #schema_name#.h_sites s on (s.p_id = cpu.h_sites_p_id)
					left outer join t_interactor_h_system_users su_int on (su_int .p_id = cpu.interactor_h_system_users_p_id)
					left outer join t_h_workbooks wb on (wb.p_id = cpu.h_workbooks_p_id)		
					left outer join t_publisher_h_users u_pub on (u_pub.p_id = cpu.publisher_h_users_p_id) 
					left outer join t_publisher_h_system_users us_pub on (us_pub.p_id = cpu.publisher_h_system_users_p_id)
				WHERE
					cpu.ts_rounded_15_secs >= #v_max_ts_date#
		';
		
		v_sql := v_sql || '
				'';
											
				v_sql := replace(v_sql, ''#schema_name#'', p_schema_name);
				v_sql := replace(v_sql, ''#v_max_ts_date#'', v_max_ts_date);
				
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