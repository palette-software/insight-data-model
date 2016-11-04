CREATE or replace function check_if_load_date_already_in_table(p_schema_name text, p_table_name text, p_load_date date, p_allow_next_day_overflow bool) returns int
AS $$
declare
	v_sql_cur text;
    v_max_ts timestamp;
    v_load_date timestamp := p_load_date;
    v_day_overflow interval := interval'2 hours';
begin
    
    execute 'set local search_path = ' || p_schema_name;
    
    v_sql_cur := 'select get_max_ts(''#schema_name#'', ''' || p_table_name || ''')';
	v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);
    execute v_sql_cur into v_max_ts;
    
    if p_allow_next_day_overflow then
        v_load_date := p_load_date + v_day_overflow;
    end if;
    
    if v_max_ts >= v_load_date then
        raise EXCEPTION 'Table already contains data for the day. Table: %, load_date: %', p_table_name, p_load_date;
    end if;
    return 0;
END;
$$ LANGUAGE plpgsql;