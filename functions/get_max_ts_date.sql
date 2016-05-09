create or replace function get_max_ts_date(p_schema_name text, p_table_name text) returns date
as $$
declare
	v_sql text;	
	v_max_date date;
	rec record;
begin

		v_max_date := null;		
		for rec in (select
						a.e
					from
						(select 
							case when p_table_name = 'p_cpu_usage_report' then	
									'select max(cpu_usage_ts_rounded_15_secs)::date as d from ' || min(schemaname) || '."' || max(parentpartitiontablename) || '"'
								 when p_table_name in ('p_threadinfo', 'p_cpu_usage') then
								 	'select max(ts_rounded_15_secs)::date as d from ' || min(schemaname) || '."' || max(parentpartitiontablename) || '"'
								else
									'select max(ts)::date as d from ' || min(schemaname) || '."' || max(parentpartitiontablename) || '"'
							end	as e
						from pg_partitions
						where tablename = p_table_name and
								schemaname = p_schema_name
						) a
						where
							a.e is not null
					)
					
		loop
			execute rec.e into v_max_date;
		end loop;					
	
		if (v_max_date is null) then
			if p_table_name = 'p_cpu_usage_report' then
					execute 'select coalesce((select max(cpu_usage_ts_rounded_15_secs) from ' || p_schema_name || '.'  || p_table_name || '), date''1001-01-01'')' into v_max_date;
			elsif p_table_name in ('p_threadinfo', 'p_cpu_usage') then
					execute 'select coalesce((select max(ts_rounded_15_secs) from ' || p_schema_name || '.'  || p_table_name || '), date''1001-01-01'')' into v_max_date;
			else
					execute 'select coalesce((select max(ts) from ' || p_schema_name || '.'  || p_table_name || '), date''1001-01-01'')' into v_max_date;
			end if;
		end if;

		return v_max_date;		
		
end;
$$ language plpgsql;