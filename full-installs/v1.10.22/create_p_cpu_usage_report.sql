CREATE or replace function create_p_cpu_usage_report(p_schema_name text) returns int
AS $$
declare	
	rec record;
	v_sql text;
begin	
	
		v_sql := 'create table ' || p_schema_name || '.p_cpu_usage_report (
					p_id bigserial,					
		';
								
		for rec in (select col_name || ' ' || data_type || decode(data_type, 'character varying', ' (' || character_maximum_length || ')',
														 'numeric', ' (' || numeric_precision_radix || ',' || coalesce(numeric_scale, '0') || ')',
														 '') || ',' as col_def
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
						 data_type ,
						 character_maximum_length,
						 numeric_precision_radix,
						 numeric_scale
					from
						information_schema.columns c
					where
						table_schema = p_schema_name and
						table_name in ('h_sites', 'h_projects', 'h_workbooks', 'h_system_users') or
                        (table_name = 'p_cpu_usage' and column_name not in ('session_start_ts', 'session_end_ts', 'session_duration'))
						
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
			  v_sql := v_sql || rec.col_def || '\n';
			  
		end loop;

        v_sql := v_sql || ' session_start_ts timestamp without time zone,
                           session_end_ts timestamp without time zone,
                           session_duration double precision,
                           thread_name text, 
                           site_name_id text,
                           project_name_id text,
                           site_project text,
                           workbook_name_id text)
        
		WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
		DISTRIBUTED BY (cpu_usage_p_id)
		PARTITION BY RANGE (cpu_usage_ts_rounded_15_secs)
		SUBPARTITION BY LIST (cpu_usage_host_name)
		SUBPARTITION TEMPLATE (SUBPARTITION init VALUES (''init'')
		WITH (appendonly=true, orientation=column, compresstype=quicklz))
		(PARTITION "10010101" START (date ''1001-01-01'') INCLUSIVE
			END (date ''1001-01-02'') EXCLUSIVE
		WITH (appendonly=true, orientation=column, compresstype=quicklz)	
		)';
				
		raise notice 'I: %', v_sql;
		execute v_sql;
		
		return 0;
END;
$$ LANGUAGE plpgsql;