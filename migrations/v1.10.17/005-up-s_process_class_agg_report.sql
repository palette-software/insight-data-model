CREATE or replace function create_s_process_class_agg_report(p_schema_name text) returns int
AS $$
declare
	v_sql text;
begin	
		v_sql := 'create table #schema_name#.s_process_class_agg_report 
		WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
		as 
		select * from #schema_name#.p_process_class_agg_report where 1 = 2
		DISTRIBUTED BY (session_start_ts);
		';
		
		v_sql := replace(v_sql, '#schema_name#', p_schema_name);
		execute v_sql;		
		return 0;
END;
$$ LANGUAGE plpgsql;