CREATE OR REPLACE FUNCTION insert_p_serverlogs_from_s_serverlogs(p_schema_name text)
RETURNS bigint AS
$BODY$
declare
	v_sql text;
	v_num_inserted bigint;	
	rec record;
	v_cols text;	
begin			
		
		v_cols := '';
		
		for rec in (select 
						column_name
					from 
						information_schema.columns
					where 
						table_schema = p_schema_name and
						table_name = 'p_serverlogs' and
						column_name <> 'p_id'
					order by
						ordinal_position
					)
		loop
			v_cols := v_cols || rec.column_name || ',';
		end loop;

		v_cols := rtrim(v_cols, ','); 
		
		v_sql := 'insert into #schema_name#.p_serverlogs(' || v_cols || ')
				  select ' || v_cols || ' from #schema_name#.s_serverlogs';
				
		v_sql := replace(v_sql, '#schema_name#', p_schema_name);		
		
		raise notice 'I: %', v_sql;
		execute v_sql;
				
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;			
		return v_num_inserted;
		
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY INVOKER;