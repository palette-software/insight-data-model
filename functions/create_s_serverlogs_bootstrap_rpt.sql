CREATE or replace function create_s_cpu_usage_agg_report(p_schema_name text) returns int
AS $$
declare
	v_sql text;
begin	

		execute 'set local search_path = ' || p_schema_name;
		
		v_sql := 'create table s_cpu_usage_agg_report
		WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
		as 
		select * from p_cpu_usage_agg_report where 1 = 2
		DISTRIBUTED BY (cpu_usage_host_name, cpu_usage_process_name, timestamp_utc);
		';
		
		execute v_sql;		
		return 0;
END;
$$ LANGUAGE plpgsql;