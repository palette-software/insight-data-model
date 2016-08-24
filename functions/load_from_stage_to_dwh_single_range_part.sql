CREATE or replace function load_from_stage_to_dwh_single_range_part(p_schema_name text, p_table_name text) returns bigint
AS $$
declare
	v_sql text;
	v_sql_cur text;
	v_num_inserted bigint;
	c refcursor;
	rec record;	
begin	
	v_sql_cur := 'select distinct 
				#column_ts_date# as ts_date,
				''delete from #schema_name#."p_#table_name#_1_prt_'' || to_char(#column_ts_date#, #datepart#) || ''"'' as delete_partition
			from 
				#schema_name#.s_#table_name#';
	
	v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);
	v_sql_cur := replace(v_sql_cur, '#table_name#', substr(p_table_name, 3));

	if (lower(p_table_name) = 'p_serverlogs_bootstrap_rpt') then
		v_sql_cur := replace(v_sql_cur, '#column_ts_date#', 'start_ts::date');
		v_sql_cur := replace(v_sql_cur, '#datepart#', 'yyyymmdd');
	elsif (lower(p_table_name) = 'p_cpu_usage_agg_report') then
		v_sql_cur := replace(v_sql_cur, '#column_ts_date#', 'timestamp_utc::date');
		v_sql_cur := replace(v_sql_cur, '#datepart#', 'yyyy');
	elsif (lower(p_table_name) = 'p_cpu_usage_bootstrap_rpt') then
		v_sql_cur := replace(v_sql_cur, '#column_ts_date#', 'cpu_usage_ts_rounded_15_secs::date');
		v_sql_cur := replace(v_sql_cur, '#datepart#', 'yyyymm');
	elsif (lower(p_table_name) = 'p_interactor_session') then
		v_sql_cur := replace(v_sql_cur, '#column_ts_date#', 'session_start_ts::date');
		v_sql_cur := replace(v_sql_cur, '#datepart#', 'yyyy');
	elsif (lower(p_table_name) = 'p_process_class_agg_report') then
		v_sql_cur := replace(v_sql_cur, '#column_ts_date#', 'ts_rounded_15_secs::date');
		v_sql_cur := replace(v_sql_cur, '#datepart#', 'yyyymm');
	end if;				

	raise notice 'I: %', v_sql_cur;

	open c for execute (v_sql_cur);
	loop
		fetch c into rec;
		exit when not found;

		v_sql := rec.delete_partition;
		raise notice 'I: %', v_sql;
			  
		begin
			execute v_sql;			  
			exception when undefined_table 
			-- the partition is not there (only possible when a new host's just installed)
				then null;
		end;

		--v_sql := 'delete from #schema_name#."p_#table_name#_1_prt_' || to_char(rec.ts_date, 'yyyymmdd');
		--v_sql := replace(v_sql, '#schema_name#', p_schema_name);
		--v_sql := replace(v_sql, '#table_name#', substr(p_table_name, 3));
		--execute v_sql;
			  
	end loop;
	close c;									
				
        v_num_inserted := ins_stage_to_dwh(p_schema_name, p_table_name);
        
	return v_num_inserted;
END;
$$ LANGUAGE plpgsql;
