select create_load_p_cpu_usage_bootstrap_rpt('palette');

CREATE or replace function create_load_p_cpu_usage_bootstrap_rpt(p_schema_name text) returns int
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
						column_name not in ('p_id', 'p_cre_date')
					order by
						ordinal_position)
		loop			
			  v_col_list_select := v_col_list_select || ' ,cpu.' || rec.col_name || '\n';		
			  v_col_list_insert := v_col_list_insert || ' ,' || rec.col_name || '\n';	
		end loop;
		
		v_col_list_select := ltrim(v_col_list_select, ' ,');
		v_col_list_insert := ltrim(v_col_list_insert, ' ,');
							
		v_sql := 		
				'
				CREATE or replace function load_p_cpu_usage_bootstrap_rpt(p_schema_name text) returns bigint
				AS \$\$
				declare
					v_sql text;
					v_num_inserted bigint;
					v_from text;
					v_to text;
					v_sql_cur text;	
				begin		

					execute ''set local search_path = '' || p_schema_name;
					
					v_sql_cur := ''
					    select
						    to_char(coalesce(
							    max(cpu_usage_ts_rounded_15_secs),
								date''''1001-01-01''''), ''''yyyy-mm-dd'''')
						from p_cpu_usage_bootstrap_rpt'';
						
					raise notice ''I: %'', v_sql_cur;
					execute v_sql_cur into v_from;
						
					v_sql_cur := 
						''select
							to_char(coalesce(min(cpu_usage_ts_rounded_15_secs), date''''#v_from#'''' + 1), ''''yyyy-mm-dd hh24:mi:ss.ms'''')
						from
							p_cpu_usage_report cpu
							left outer join p_interactor_session s on (
						                                    s.session_start_ts >= date''''#v_from#'''' and		                                    
						                                    s.vizql_session = cpu.cpu_usage_parent_vizql_session and
						                                    s.process_name = ''''vizqlserver'''')
						where        
						 	cpu.cpu_usage_parent_vizql_session is not null and
							cpu.cpu_usage_parent_vizql_session not in (''''Non-Interactor Vizql'''', ''''-'''') and
						 	cpu.cpu_usage_ts_rounded_15_secs >= date''''#v_from#'''' + 1 and
							cpu.cpu_usage_ts <= s.session_start_ts +
																(interval''''1 second'''' * coalesce(s.bootstrap_elapsed_secs, 0)) +
																(interval''''1 second'''' * coalesce(s.show_elapsed_secs,0)) +
																(interval''''1 second'''' * coalesce(s.show_bootstrap_delay_secs,0))										
														+ interval ''''15 second''''
						'';
					
					v_sql_cur := replace(v_sql_cur, ''#v_from#'', v_from);	
					raise notice ''I: %'', v_sql_cur;
					execute v_sql_cur into v_to;

					v_sql_cur := 
					''delete
						from  
							p_cpu_usage_bootstrap_rpt b	
						where 
							b.cpu_usage_ts_rounded_15_secs >= date''''#v_from#'''' and
							b.cpu_usage_ts_rounded_15_secs <= timestamp''''#v_to#''''
					'';
					v_sql_cur := replace(v_sql_cur, ''#v_from#'', v_from);
					v_sql_cur := replace(v_sql_cur, ''#v_to#'', v_to);

				    raise notice ''I: %'', v_sql_cur;
					execute v_sql_cur;
					
						
					v_sql := ''insert into p_cpu_usage_bootstrap_rpt
					    (\n'
						||
							v_col_list_insert
						||
						' )
						select \n' 
						||					
							replace(v_col_list_select, 'cpu.p_cpu_usage_report_p_id', 'cpu.p_id')
						||
						'from
							p_cpu_usage_report cpu
						left outer join p_interactor_session s on (
						                                    s.session_start_ts >= date''''#v_from#'''' and
															-- plus one hour as a safety net
						                                    s.session_start_ts <= timestamp''''#v_to#'''' + interval''''1 hour'''' and
						                                    s.vizql_session = cpu.cpu_usage_parent_vizql_session and
						                                    s.process_name = ''''vizqlserver'''')
						where
							cpu.cpu_usage_ts_rounded_15_secs >= date''''#v_from#'''' and	
							cpu.cpu_usage_ts_rounded_15_secs <= timestamp''''#v_to#'''' and	
							cpu_usage_parent_vizql_session is not null and
						    cpu_usage_parent_vizql_session not in (''''Non-Interactor Vizql'''', ''''-'''')  and
						                      cpu_usage_ts <= s.session_start_ts +
																(interval''''1 second'''' * coalesce(s.bootstrap_elapsed_secs, 0)) +
																(interval''''1 second'''' * coalesce(s.show_elapsed_secs,0)) +
																(interval''''1 second'''' * coalesce(s.show_bootstrap_delay_secs,0))										
														+ interval ''''15 second''''
						'';			
							
						v_sql := replace(v_sql, ''#v_from#'', v_from);
						v_sql := replace(v_sql, ''#v_to#'', v_to);		
						
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