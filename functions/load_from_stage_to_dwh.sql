CREATE or replace function load_from_stage_to_dwh(p_schema_name text, p_table_name text) returns bigint
AS $$
declare
	v_sql text;
	v_sql_cur text;
	v_num_inserted bigint;
	c refcursor;
	rec record;
	v_cols text;
begin	
		v_sql_cur := 'select distinct 
							#column_host_name# as host_name,
							#column_ts_date# as ts_date,
							''truncate table #schema_name#."p_#table_name#_1_prt_'' || to_char(#column_ts_date#, ''yyyymmdd'') || ''_2_prt_'' || #column_host_name# || ''"'' as truncate_partition
					 from 
						#schema_name#.s_#table_name#';
	
		v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);
		v_sql_cur := replace(v_sql_cur, '#table_name#', substr(p_table_name, 3));
		
		if (upper(p_table_name) = 'P_CPU_USAGE') then
			v_sql_cur := replace(v_sql_cur, '#column_host_name#', 'host_name');
			v_sql_cur := replace(v_sql_cur, '#column_ts_date#', 'ts_date');
		elsif (upper(p_table_name) = 'P_CPU_USAGE_REPORT') then
			v_sql_cur := replace(v_sql_cur, '#column_host_name#', 'cpu_usage_host_name');
			v_sql_cur := replace(v_sql_cur, '#column_ts_date#', 'cpu_usage_ts_date');
		end if;				
	
		raise notice 'I: %', v_sql_cur;
		
		open c for execute (v_sql_cur);
		loop
			  fetch c into rec;
			  exit when not found;
			  			  
			  v_sql := rec.truncate_partition;
			  raise notice 'I: %', v_sql;
			  
			  begin
			  	execute v_sql;			  
			  exception when undefined_table 
			  		-- the partition is not there (only possible when a new host's just installed)
			  		then null;
			  end;
			  			  
			  v_sql := 'truncate table #schema_name#."p_#table_name#_1_prt_' || to_char(rec.ts_date, 'yyyymmdd') || '_2_prt_new_host"';
			  v_sql := replace(v_sql, '#schema_name#', p_schema_name);
			  v_sql := replace(v_sql, '#table_name#', substr(p_table_name, 3));
				
			  execute v_sql;
			  
		end loop;
		close c;									
		
		v_cols := '';
		
		for rec in (select 
						column_name
					from 
						information_schema.columns
					where 
						table_schema = p_schema_name and
						table_name = p_table_name and
						column_name <> 'p_id'						
					order by
						ordinal_position
					)
		loop
			v_cols := v_cols || rec.column_name || ',';
		end loop;
		
		v_cols := rtrim(v_cols, ','); 
		
		v_sql := 'insert into #schema_name#.p_#table_name#(' || v_cols || ')
				  select ' || v_cols || ' from #schema_name#.s_#table_name#';
				
		v_sql := replace(v_sql, '#schema_name#', p_schema_name);
		v_sql := replace(v_sql, '#table_name#', substr(p_table_name, 3));
		
		raise notice 'I: %', v_sql;
		execute v_sql;
		
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;			
		return v_num_inserted;
END;
$$ LANGUAGE plpgsql;