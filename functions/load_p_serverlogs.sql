CREATE or replace function load_p_serverlogs(p_schema_name text) returns bigint
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
				
		execute 'select ' || p_schema_name || '.load_p_serverlogs_rest(''' || p_schema_name || ''')' into v_num_inserted;
		v_num_inserted_all := v_num_inserted_all + v_num_inserted;

		execute 'select ' || p_schema_name || '.load_p_serverlogs_vizql(''' || p_schema_name || ''')' into v_num_inserted;
		v_num_inserted_all := v_num_inserted_all + v_num_inserted;

		execute 'truncate table ' || p_schema_name || '.s_serverlogs';
				
		execute 'select ' || p_schema_name || '.load_p_serverlogs_dataserver(''' || p_schema_name || ''')' into v_num_inserted;
		v_num_inserted_all := v_num_inserted_all + v_num_inserted;
		
		execute 'select ' || p_schema_name || '.load_p_serverlogs_tabproto(''' || p_schema_name || ''')' into v_num_inserted;
		v_num_inserted_all := v_num_inserted_all + v_num_inserted;											

		-- delete from p_serverlogs where dataserver , tabproto
		-- 
						
		return v_num_inserted_all;
END;
$$ LANGUAGE plpgsql;