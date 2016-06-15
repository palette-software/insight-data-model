create or replace function get_max_ts_date(p_schema_name text, p_table_name text) returns date
as $$
begin
	execute 'set local search_path = ' || p_schema_name;
	return get_max_ts(p_schema_name, p_table_name)::date;				
end;
$$ language plpgsql;