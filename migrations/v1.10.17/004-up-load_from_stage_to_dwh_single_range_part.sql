CREATE or replace function load_from_stage_to_dwh_single_range_part(p_schema_name text, p_table_name text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;	
	v_cols text;
	rec record;
begin	

        execute 'set local search_path = ' || p_schema_name;
        
		v_sql := 'delete from p_#table_name#
                  where
                        #column_ts# between 
                                    (select min(#column_ts#) from s_#table_name#) and
                                    (select max(#column_ts#) from s_#table_name#)
                     ';

		v_sql := replace(v_sql, '#table_name#', substr(p_table_name, 3));
                        
		if (upper(p_table_name) = 'P_CPU_USAGE_AGG_REPORT') then
			v_sql := replace(v_sql, '#column_ts#', 'timestamp_utc');
		elsif (upper(p_table_name) = 'P_INTERACTOR_SESSION') then
			v_sql := replace(v_sql, '#column_ts#', 'session_start_ts');
        elsif (upper(p_table_name) = 'P_PROCESS_CLASS_AGG_REPORT') then
			v_sql := replace(v_sql, '#column_ts#', 'ts_rounded_15_secs');
        elsif (upper(p_table_name) = 'P_CPU_USAGE_BOOTSTRAP_RPT') then
			v_sql := replace(v_sql, '#column_ts#', 'cpu_usage_ts_rounded_15_secs');
        elsif (upper(p_table_name) = 'P_SERVERLOGS_BOOTSTRAP_RPT') then
			v_sql := replace(v_sql, '#column_ts#', 'start_ts');
		end if;
                        
		raise notice 'I: %', v_sql;		
        execute v_sql;
                		
		v_cols := '';
		
		for rec in (select 
						column_name
					from 
						information_schema.columns
					where 
						table_schema = p_schema_name and
						table_name = p_table_name and
						column_name not in ('p_id', 'p_cre_date')
					order by
						ordinal_position
					)
		loop
			v_cols := v_cols || rec.column_name || ',';
		end loop;
		
		v_cols := rtrim(v_cols, ','); 
		
		v_sql := 'insert into p_#table_name#(' || v_cols || ')
				  select ' || v_cols || ' from s_#table_name#';
                  
		v_sql := replace(v_sql, '#table_name#', substr(p_table_name, 3));
        
		raise notice 'I: %', v_sql;
		execute v_sql;
        
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
		return v_num_inserted;
END;
$$ LANGUAGE plpgsql;