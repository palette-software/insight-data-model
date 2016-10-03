CREATE OR REPLACE FUNCTION create_p_cpu_usage_bootstrap_rpt(p_schema_name text)
RETURNS integer AS
$BODY$
declare
	v_sql text;			
	rec record;	
	v_col_list text;
begin	

		execute 'set local search_path = ' || p_schema_name;

		v_col_list := '';
		
		for rec in (select 
						case when c.column_name in ('p_id', 'p_cre_date') 
							then
								'p_cpu_usage_report_' || c.column_name
							else 	
								c.column_name
						end || ' ' ||
									c.data_type || decode(c.data_type, 'character varying', ' (' || c.character_maximum_length || ')',
														 'numeric', ' (' || c.numeric_precision_radix || ',' || coalesce(c.numeric_scale, '0') || ')',
														 '') || ',' as col_def
					from information_schema.columns c
					 where
					 	c.table_name = 'p_cpu_usage_report' and
						c.table_schema = p_schema_name
					 order by
					 	ordinal_position
					)
		loop
			
			v_col_list := v_col_list || ' ' || rec.col_def;
			
		end loop;
				
		--v_col_list := rtrim(v_col_list, ',');
				
		v_sql := '
		create table p_cpu_usage_bootstrap_rpt ( 
			p_id bigserial,
		' ||
			v_col_list		
		||
			'session_elapsed_seconds double precision,
            currentsheet varchar(255),
            view_id int,
			p_cre_date timestamp without time zone default now()'			
		||
		')
		WITH (appendonly=true, orientation=column, compresstype=quicklz)
		DISTRIBUTED BY (p_id)
		PARTITION BY RANGE (cpu_usage_ts_rounded_15_secs)
		(PARTITION "100101" 
			START (date ''1001-01-01'') INCLUSIVE
			END (date ''1001-02-01'') EXCLUSIVE 	
		WITH (appendonly=true, orientation=column, compresstype=quicklz));
		';
		
		raise notice 'I: %', v_sql;
		execute v_sql;
		
		return 0;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY INVOKER;
