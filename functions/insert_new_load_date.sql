CREATE or replace function insert_new_load_date(p_schema_name text, p_load_date date) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;
begin		

	execute 'set local search_path = ' || p_schema_name;

	perform check_if_load_date_already_in_table(p_schema_name, 'load_dates', p_load_date, false);

	v_sql := 'insert into p_load_dates (p_load_date) values (' || p_load_date || ')';

	raise notice 'I: %', v_sql;
	execute v_sql;

	GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
	return v_num_inserted;

END;
$$ LANGUAGE plpgsql;