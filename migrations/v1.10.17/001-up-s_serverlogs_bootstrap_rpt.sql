CREATE or replace function create_s_serverlogs_bootstrap_rpt(p_schema_name text) returns int
AS $$
declare
	v_sql text;
begin	
		v_sql := 'create table #schema_name#.s_serverlogs_bootstrap_rpt 
		WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
		as 
		select * from #schema_name#.p_serverlogs_bootstrap_rpt where 1 = 2
		DISTRIBUTED BY (p_serverlogs_p_id);
		';
		
		v_sql := replace(v_sql, '#schema_name#', p_schema_name);
		execute v_sql;		
		return 0;
END;
$$ LANGUAGE plpgsql;