CREATE or replace function create_s_cpu_usage(p_schema_name text) returns int
AS $$
declare
	v_sql text;
begin	
		v_sql := 'create table #schema_name#.s_cpu_usage
		WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
		as 
		select * from #schema_name#.p_cpu_usage where 1 = 2
		DISTRIBUTED BY (p_threadinfo_id);
		';
		
		v_sql := replace(v_sql, '#schema_name#', p_schema_name);
		execute v_sql;
        
        alter table s_cpu_usage alter column parent_vizql_destroy_sess_ts type timestamp without time zone using to_timestamp(parent_vizql_destroy_sess_ts, 'yyyy-mm-dd HH24.MI.SS.MS');

        v_sql := 'alter table #schema_name#.s_cpu_usage alter column session_duration set default 0';
        v_sql := replace(v_sql, '#schema_name#', p_schema_name);
        execute v_sql;
        
		return 0;
END;
$$ LANGUAGE plpgsql;