CREATE OR REPLACE FUNCTION delete_recent_records_from_p_serverlogs(p_schema_name text)
RETURNS bigint AS
$BODY$
declare
	v_sql text;
	v_sql_cur text;
	v_num_deleted bigint;
	v_max_ts_date_p_cpu_usage text;
	c refcursor;
	rec record;		
begin	

		execute 'set local search_path = ' || p_schema_name;
		
		v_sql_cur := 'select distinct 
							#column_host_name# as host_name,
							#column_ts_date# as ts_date,
							''delete from "p_#table_name#_1_prt_'' || to_char(#column_ts_date#, ''yyyymmdd'') || ''_2_prt_'' || #column_host_name# || ''"'' as delete_partition
					 from 
							s_#table_name#';
			
		v_sql_cur := replace(v_sql_cur, '#table_name#', 'serverlogs');		
		v_sql_cur := replace(v_sql_cur, '#column_host_name#', 'host_name');
		v_sql_cur := replace(v_sql_cur, '#column_ts_date#', 'ts::date');
		
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
			  			  
			  v_sql := 'delete from "p_#table_name#_1_prt_' || to_char(rec.ts_date, 'yyyymmdd') || '_2_prt_new_host"';			  
			  v_sql := replace(v_sql, '#table_name#', substr('p_serverlogs', 3));
			  raise notice 'I: %', v_sql;
			  execute v_sql;
			  
		end loop;
		close c;			
				
						
		GET DIAGNOSTICS v_num_deleted = ROW_COUNT;	
		return v_num_deleted;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY INVOKER;