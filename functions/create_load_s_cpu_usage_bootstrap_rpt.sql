CREATE or replace function create_load_s_cpu_usage_bootstrap_rpt(p_schema_name text) returns int
AS $$
declare	
	rec record;
	v_sql text;
	v_col_list_select text;
	v_col_list_insert text;
begin
	
		v_col_list_select := '';
		v_col_list_insert := '';
		
		for rec in (select 
						c.column_name as col_name							
					from
						information_schema.columns c
					where
						table_schema = p_schema_name and
						table_name = 'p_cpu_usage_bootstrap_rpt' and
						column_name not in ('p_id', 'p_cre_date', 'session_elapsed_seconds', 'currentsheet', 'view_id')
					order by
						ordinal_position)
		loop			
			  v_col_list_select := v_col_list_select || ' ,cpu.' || rec.col_name || '\n';		
			  v_col_list_insert := v_col_list_insert || ' ,' || rec.col_name || '\n';	
		end loop;
		
		v_col_list_select := ltrim(v_col_list_select, ' ,');
		v_col_list_insert := ltrim(v_col_list_insert, ' ,');
							
		v_col_list_select := replace(v_col_list_select, 'cpu.p_cpu_usage_report_p_id', 'cpu.p_id');
		
		v_sql := 
				'
				CREATE or replace function load_s_cpu_usage_bootstrap_rpt(p_schema_name text, p_load_date date) returns bigint
				AS \$\$
				declare
					v_sql text;
					v_num_inserted bigint;
                    v_load_date_txt text := to_char(p_load_date, ''yyyy-mm-dd'');
				begin		

					execute ''set local search_path = '' || p_schema_name;					
						
					v_sql := ''insert into s_cpu_usage_bootstrap_rpt
					    (\n'
						||
							v_col_list_insert
						||
						',session_elapsed_seconds
						 ,currentsheet
                         ,view_id
						)
						
						select \n' 
						||					
							replace(v_col_list_select, 'cpu.', 'a.')
						||
						    ',sum(extract(''''epoch'''' from ts_diff))
														over (partition by 
																	a.cpu_usage_host_name, 
																	a.cpu_usage_parent_vizql_session 
																order by a.cpu_usage_ts_rounded_15_secs,
																		a.cpu_usage_p_id 
																ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as session_elapsed_seconds
							,currentsheet
                            ,view_id
						from
								(
								select \n' 
								||					
									v_col_list_select
								||
									',coalesce(cpu.cpu_usage_ts_rounded_15_secs - lag(cpu.cpu_usage_ts_rounded_15_secs) over (partition by 
																																	cpu.cpu_usage_host_name, 
																															  		cpu.cpu_usage_parent_vizql_session 
																													order by 
																															cpu.cpu_usage_ts_rounded_15_secs,
																															cpu.cpu_usage_p_id),
																													interval ''''0'''') as ts_diff
									,s.currentsheet
                                    ,s.view_id
								from
									p_cpu_usage_report cpu
								left outer join p_interactor_session s on (1 = 1
    								                                    and s.session_start_ts >= date''''#v_load_date_txt#'''' - interval''''2 hours''''
    								                                    and s.session_start_ts < date''''#v_load_date_txt#'''' + interval''''1 day''''
    								                                    and s.vizql_session = cpu.cpu_usage_parent_vizql_session
    								                                    and s.process_name = ''''vizqlserver'''')
																	
								where
                                    1 = 1
									and cpu.cpu_usage_ts_rounded_15_secs >= date''''#v_load_date_txt#''''
									and cpu.cpu_usage_ts_rounded_15_secs < date''''#v_load_date_txt#'''' + interval''''1 day''''
									and cpu_usage_parent_vizql_session is not null
								    and cpu_usage_parent_vizql_session not in (''''Non-Interactor Vizql'''', ''''-'''')
    			                    and cpu_usage_ts <= s.session_start_ts +
                    													(interval''''1 second'''' * coalesce(s.bootstrap_elapsed_secs, 0)) +
                    													(interval''''1 second'''' * coalesce(s.show_elapsed_secs,0)) +
                    													(interval''''1 second'''' * coalesce(s.show_bootstrap_delay_secs,0)) +
                    								    			    interval ''''15 second''''
								) a
								''															
						;
							
						v_sql := replace(v_sql, ''#v_load_date_txt#'', v_load_date_txt);							
						
						raise notice ''I: %'', v_sql;
						execute v_sql;

						GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
						return v_num_inserted;

				END;
				\$\$ LANGUAGE plpgsql;
				
				';
				
				
		v_sql := replace(v_sql, '#function_schema_name#', p_schema_name);
		
		raise notice 'I: %', v_sql;
		execute v_sql;
		
		return 0;
END; 
$$ LANGUAGE plpgsql;