CREATE OR REPLACE FUNCTION get_max_ts(p_schema_name text, p_table_name text) RETURNS timestamp 
AS $$
declare
	v_sql text;	
	v_max_timestamp timestamp;
	v_column_name varchar;
	rec record;
begin

		v_max_timestamp := null;
		v_column_name := case 	when p_table_name in ('p_cpu_usage_report', 'p_cpu_usage_bootstrap_rpt') then 'cpu_usage_ts_rounded_15_secs'
						when p_table_name in ('p_threadinfo', 'p_threadinfo_delta', 'p_process_class_agg_report', 'p_cpu_usage') then 'ts_rounded_15_secs'
						when p_table_name = 'p_cpu_usage_agg_report' then 'timestamp_utc'
						when p_table_name = 'p_interactor_session' then 'session_start_ts'                        
						else 'ts'
					end;		
		for rec in (select
						a.e
					from
						(select 'select max(' || v_column_name || ') from ' || min(schemaname) || '."' || parentpartitiontablename || '"' as e
						from pg_partitions
						where tablename = p_table_name and
								schemaname = p_schema_name
						group by parentpartitiontablename
						) a
						where
							a.e is not null
						order by e desc
					)
					
		loop
			execute rec.e into v_max_timestamp;
			exit when v_max_timestamp is not null;
		end loop;					
	
		if (v_max_timestamp is null)
			then execute 'select coalesce(max(' || v_column_name || '), date''1001-01-01'') from ' || p_schema_name || '.'  || p_table_name into v_max_timestamp;
		end if;

		return v_max_timestamp;		
end;
$$ LANGUAGE plpgsql;