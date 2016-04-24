CREATE or replace function load_s_cpu_usage(p_schema_name text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;
	v_num_inserted_all bigint;
	v_sql_cur text;
	c refcursor;
	rec record;
	v_max_ts_date text;
begin		

		v_num_inserted_all := 0;
		
		execute 'select ' || p_schema_name || '.load_s_cpu_usage_vizql(''' || p_schema_name || ''')' into v_num_inserted;
		v_num_inserted_all := v_num_inserted_all + v_num_inserted;

		execute 'select ' || p_schema_name || '.load_s_cpu_usage_dataserver(''' || p_schema_name || ''')' into v_num_inserted;
		v_num_inserted_all := v_num_inserted_all + v_num_inserted;

		execute 'select ' || p_schema_name || '.load_s_cpu_usage_tabproto(''' || p_schema_name || ''')' into v_num_inserted;
		v_num_inserted_all := v_num_inserted_all + v_num_inserted;
		
		execute 'select ' || p_schema_name || '.load_s_cpu_usage_rest(''' || p_schema_name || ''')' into v_num_inserted;
		v_num_inserted_all := v_num_inserted_all + v_num_inserted;
									  			
		return v_num_inserted_all;
END;
$$ LANGUAGE plpgsql;