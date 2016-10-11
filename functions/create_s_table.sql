CREATE OR REPLACE FUNCTION palette.create_s_table(p_schema_name text, p_table_name text)
RETURNS integer AS
$BODY$
declare
	v_sql text;
	v_col_list_create text;
begin	
		v_sql := 'create table #schema_name#.#table_name#
		#columns_with_type#
		WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
		DISTRIBUTED BY (p_filepath);
		';
		
		v_col_list_create := '';
		
		for rec in (
			select
				c.column_name || ' ' ||
					c.data_type || 
					decode(c.data_type, 
							'character varying', 
							' (' || c.character_maximum_length || ')', 
							'numeric', 
							' (' || c.numeric_precision_radix || ',' || coalesce(c.numeric_scale, '0') || ')', 
							'') || ',' as col_def
			from
				information_schema.columns c
			where
				table_schema = p_schema_name and
				table_name = p_table_name and
				column_name not in ('p_id', 'p_active_flag', 'p_valid_from', 'p_valid_to', 'p_cre_date')
			order by
				ordinal_position)
		loop
			  v_col_list_create := v_col_list_create || ' ,' || rec.col_name || '\n';
		end loop;
		
		v_col_list_create := ltrim(v_col_list_create, ' ,');
		
		v_sql := replace(v_sql, '#schema_name#', p_schema_name);
		v_sql := replace(v_sql, '#table_name#', p_table_name);
		v_sql := replace(v_sql, '#columns_with_type#', v_col_list_create);
		
		execute v_sql;
		
		return 0;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY INVOKER;

