CREATE or replace function create_s_serverlogs(p_schema_name text) returns int
AS $$
declare
	v_sql text;
begin	
		v_sql := 'create table #schema_name#.s_serverlogs
		WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
		as 
		select * from #schema_name#.p_serverlogs where 1 = 2
		DISTRIBUTED BY (serverlogs_id);		
		';
		
		v_sql := replace(v_sql, '#schema_name#', p_schema_name);
		execute v_sql;		
		return 0;
END;
$$ LANGUAGE plpgsql;