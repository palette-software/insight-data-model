CREATE or replace function create_p_cpu_usage_bootstrap_rpt(p_schema_name text) returns int
AS $$
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
			'currentsheet varchar(255),
			elapsed_seconds_to_bootstrap bigint,
			p_cre_date timestamp without time zone default now()'			
		||
		')
		WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)				
		DISTRIBUTED BY (p_id)
		PARTITION BY RANGE (cpu_usage_ts_rounded_15_secs)
		(START (date ''2016-05-01'') INCLUSIVE
			END (date ''2017-05-01'') EXCLUSIVE 
			every(interval ''1 month'')		
		)
		';
		
		raise notice 'I: %', v_sql;
		execute v_sql;
		
		return 0;
END;
$$ LANGUAGE plpgsql;
