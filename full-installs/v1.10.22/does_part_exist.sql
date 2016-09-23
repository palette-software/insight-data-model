CREATE or replace function does_part_exist(p_schema_name text, p_table_name text, p_part_name text) returns boolean
AS $$
declare
	v_cnt int;
BEGIN

	v_cnt := 0;
	select count(1) into v_cnt
	from 
		pg_partitions 
	where 
		schemaname = p_schema_name and
		tablename = p_table_name and 
		partitionname = p_part_name;
		
	if v_cnt > 0 then
		return true;
	else
		return false;
	end if;
	
END;
$$ LANGUAGE plpgsql;