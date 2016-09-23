CREATE or replace function load_from_stage_to_dwh_single_range_part(p_schema_name text, p_table_name text) returns bigint
AS $$
declare
	v_sql text;
    v_sql_cur text;
	v_num_inserted bigint;
    v_from text;
    v_to text;
    v_col_ts text;
begin	

        execute 'set local search_path = ' || p_schema_name;               
		
        v_col_ts := '';
        
		if (upper(p_table_name) = 'P_CPU_USAGE_AGG_REPORT') then
			v_col_ts := 'timestamp_utc';
		elsif (upper(p_table_name) = 'P_INTERACTOR_SESSION') then
			v_col_ts := 'session_start_ts';
        elsif (upper(p_table_name) = 'P_PROCESS_CLASS_AGG_REPORT') then
			v_col_ts := 'ts_rounded_15_secs';
        elsif (upper(p_table_name) = 'P_CPU_USAGE_BOOTSTRAP_RPT') then
			v_col_ts := 'cpu_usage_ts_rounded_15_secs';
        elsif (upper(p_table_name) = 'P_SERVERLOGS_BOOTSTRAP_RPT') then
			v_col_ts := 'start_ts';
		end if;
                
        v_sql_cur := 'select to_char(coalesce(min(#column_ts#), date''1001-01-01''), ''yyyy-mm-dd hh24:mi:ss.ms'') from s_#table_name#';
        v_sql_cur := replace(v_sql_cur, '#table_name#', substr(p_table_name, 3));
        v_sql_cur := replace(v_sql_cur, '#column_ts#', v_col_ts);
        raise notice 'I: %', v_sql_cur;
		execute v_sql_cur into v_from;                
		v_from := 'timestamp''' || v_from || '''';

		v_sql_cur := 'select 
							to_char(coalesce(max(#column_ts#), date''1001-01-01''), ''yyyy-mm-dd hh24:mi:ss.ms'')
					  from
					  		s_#table_name#';
		v_sql_cur := replace(v_sql_cur, '#table_name#', substr(p_table_name, 3));
        v_sql_cur := replace(v_sql_cur, '#column_ts#', v_col_ts);
        raise notice 'I: %', v_sql_cur;
		execute v_sql_cur into v_to;
		v_to := 'timestamp''' || v_to || '''';                        
                        
        v_sql := 'delete from p_#table_name#
                  where
                        #column_ts# >= #v_from# and
                        #column_ts# <= #v_to#';
        
        v_sql := replace(v_sql, '#table_name#', substr(p_table_name, 3));
        v_sql := replace(v_sql, '#column_ts#', v_col_ts);
        v_sql := replace(v_sql, '#v_from#', v_from);
        v_sql := replace(v_sql, '#v_to#', v_to);
		raise notice 'I: %', v_sql;
        execute v_sql;
        
        v_num_inserted := ins_stage_to_dwh(p_schema_name, p_table_name);

		return v_num_inserted;
END;
$$ LANGUAGE plpgsql;