CREATE or replace function create_s_interactor_session(p_schema_name text) returns int
AS $$
declare
	v_sql text;
begin	
		v_sql := 'create table #schema_name#.s_interactor_session 
		WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
		as 
		select * from #schema_name#.p_interactor_session where 1 = 2
		DISTRIBUTED BY (session_start_ts);
		';
		
		v_sql := replace(v_sql, '#schema_name#', p_schema_name);
		execute v_sql;		
		return 0;
END;
$$ LANGUAGE plpgsql;