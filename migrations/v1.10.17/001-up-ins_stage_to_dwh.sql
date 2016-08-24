CREATE or replace function ins_stage_to_dwh(p_schema_name text, p_table_name text) returns bigint
AS $$
declare
	v_sql text;
	v_sql_cur text;
	v_num_inserted bigint;	
	v_cols text;
begin	
    
        execute 'set local search_path = ' || p_schema_name;
        
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