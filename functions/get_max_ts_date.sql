create or replace function get_max_ts_date(p_schema_name text, p_table_name text) returns date
as $$
declare
	v_sql text;	
	v_max_date date;
	rec record;
begin

		v_max_date := null;		
		for rec in (select 
						case when p_table_name = 'p_cpu_usage_report' then	
								'select max(cpu_usage_ts)::date as d from ' || min(schemaname) || '."' || max(parentpartitiontablename) || '"'
							else
								'select max(ts)::date as d from ' || min(schemaname) || '."' || max(parentpartitiontablename) || '"'
						end	as e
					from pg_partitions
					where tablename = p_table_name and
							schemaname = p_schema_name)
					
		loop
			execute rec.e into v_max_date;
		end loop;					
	
		if (v_max_date is null) then
			RAISE EXCEPTION 'get_max_ts_date() could not get proper date for %', p_table_name;
		end if;

		return v_max_date;		
		
end;
$$ language plpgsql;

select get_max_ts_date('prod', 'p_threadinfo');


select max(ts) from prod.p_cpu_usage

select max(ts) from prod."p_cpu_usage_1_prt_10010101";



