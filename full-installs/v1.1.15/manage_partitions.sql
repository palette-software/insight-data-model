CREATE or replace function manage_partitions(p_schema_name text, p_table_name text) returns int
AS $$
declare
	v_sql_cur text;
	c refcursor;
	rec record;
	v_sql text;
	v_max_ts_date_p_threadinfo text;
	v_max_ts_date_p_serverlogs text;
BEGIN

		v_sql_cur := 'select to_char((select #schema_name#.get_max_ts_date(''#schema_name#'', ''p_threadinfo'')), ''yyyy-mm-dd'')';
		v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);			
		execute v_sql_cur into v_max_ts_date_p_threadinfo;
		v_max_ts_date_p_threadinfo := 'date''' || v_max_ts_date_p_threadinfo || '''';
						
		v_sql_cur := '';
		v_sql := '';
		
		if p_table_name in ('threadinfo') then
			v_sql_cur := 'select distinct host_name::text as host_name from #schema_name#.ext_threadinfo';
		elseif p_table_name in ('serverlogs') then
			v_sql_cur := 'select distinct host_name::text as host_name from #schema_name#.ext_serverlogs';
		elseif p_table_name in ('p_serverlogs') then
			v_sql_cur := 'select distinct host_name::text as host_name from #schema_name#.s_serverlogs						   
			';
		elseif p_table_name in ('p_threadinfo') then
			v_sql_cur := 'select distinct host_name::text as host_name from #schema_name#.threadinfo 
							where ts >= #max_ts_date_p_threadinfo# - interval ''1 hour''
						';
		elseif p_table_name in ('p_cpu_usage') then
			v_sql_cur := 'select distinct host_name::text as host_name from #schema_name#.s_cpu_usage';
			
		elseif p_table_name in ('p_cpu_usage_report') then
					v_sql_cur := 'select distinct cpu_usage_host_name::text as host_name from #schema_name#.s_cpu_usage_report';						
		end if;
		
		v_sql_cur := v_sql_cur || 
					' union
						select distinct partitionname 
						from pg_partitions
						where 
							schemaname = ''#schema_name#'' and
							tablename = ''#table_name#'' and
							partitionlevel = 1 and
							partitionname not in (''init'', ''new_host'')
					order by 1';
					
		v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);
		v_sql_cur := replace(v_sql_cur, '#table_name#', p_table_name);
		v_sql_cur := replace(v_sql_cur, '#max_ts_date_p_threadinfo#', v_max_ts_date_p_threadinfo);		
		
		v_sql := 'ALTER TABLE #schema_name#.#table_name# SET SUBPARTITION TEMPLATE (';		

		open c for execute (v_sql_cur);
		loop
			  fetch c into rec;
			  exit when not found;
			  
			  v_sql := v_sql || ' SUBPARTITION "#host_name#" VALUES (''#host_name#'') WITH (appendonly=true, orientation=column, compresstype=quicklz),';
			  v_sql := replace(v_sql, '#host_name#', rec.host_name);
			  
		end loop;
		close c;
		
		v_sql := replace(v_sql, '#schema_name#', p_schema_name);
		v_sql := replace(v_sql, '#table_name#', p_table_name);
		v_sql := v_sql || ' DEFAULT SUBPARTITION new_host WITH (appendonly=true, orientation=column, compresstype=quicklz))';
		
		raise notice 'I: %', v_sql;
		
		if (v_sql like '%SUBPARTITION%VALUES%')
			then
				execute v_sql;
		end if;
		
		v_sql_cur := '';
		v_sql := '';
		
		if p_table_name in ('threadinfo') then
			v_sql_cur := 'select distinct ts::date d from #schema_name#.ext_threadinfo
							 order by 1';
		elseif p_table_name in ('serverlogs') then
			v_sql_cur := 'select distinct ts::date d from #schema_name#.ext_serverlogs';
		elseif p_table_name in ('p_serverlogs') then
			v_sql_cur := 'select distinct ts::date d from #schema_name#.s_serverlogs						  
					      order by 1';
		elseif p_table_name in ('p_threadinfo') then
			v_sql_cur := 'select distinct poll_cycle_ts::date d from #schema_name#.threadinfo
						   where ts >= #max_ts_date_p_threadinfo# - interval''1 hour''
						   order by 1';
		elseif p_table_name in ('p_cpu_usage') then
			v_sql_cur := 'select distinct ts_rounded_15_secs::date d from #schema_name#.s_cpu_usage							
							order by 1';			
		elseif p_table_name in ('p_cpu_usage_report') then
					v_sql_cur := 'select distinct cpu_usage_ts_rounded_15_secs::date d from #schema_name#.s_cpu_usage_report							
							order by 1';						
		end if;
		
		v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);
		v_sql_cur := replace(v_sql_cur, '#table_name#',  p_table_name);
		v_sql_cur := replace(v_sql_cur, '#max_ts_date_p_threadinfo#', v_max_ts_date_p_threadinfo);		

		
		open c for execute (v_sql_cur);
			loop
				  fetch c into rec;
				  exit when not found;
				  
				  v_sql := 'ALTER TABLE #schema_name#.#table_name# 
				  		         ADD PARTITION "#partition_name#" START (date''#start_date#'') INCLUSIVE END (date''#end_date#'') EXCLUSIVE WITH (appendonly=true, orientation=column, compresstype=quicklz)';
						
				  v_sql := replace(v_sql, '#schema_name#', p_schema_name);
				  v_sql := replace(v_sql, '#table_name#', p_table_name);		
				  v_sql := replace(v_sql, '#partition_name#', to_char(rec.d, 'yyyymmdd'));
				  v_sql := replace(v_sql, '#start_date#', to_char(rec.d, 'yyyy-mm-dd'));
				  v_sql := replace(v_sql, '#end_date#', to_char(rec.d + 1, 'yyyy-mm-dd'));				  			  			  				  
				  
				begin
				  	execute v_sql;
				exception when duplicate_object
						then null;
				end;
				  				  
				 raise notice 'I: %', v_sql;
			end loop;
			close c;
	
	return 0;

END;
$$ LANGUAGE plpgsql;