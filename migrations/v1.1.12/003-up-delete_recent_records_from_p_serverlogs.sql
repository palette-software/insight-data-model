CREATE OR REPLACE FUNCTION delete_recent_records_from_p_serverlogs(p_schema_name text)
RETURNS bigint AS
$BODY$
declare
	v_sql text;
	v_sql_cur text;
	v_num_deleted bigint;
	v_max_ts_date_p_cpu_usage text;
begin	

		v_sql_cur := 'select to_char((select #schema_name#.get_max_ts_date(''#schema_name#'', ''p_cpu_usage'')), ''yyyy-mm-dd'')';		
		v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);		
		execute v_sql_cur into v_max_ts_date_p_cpu_usage;		
		v_max_ts_date_p_cpu_usage := 'date''' || v_max_ts_date_p_cpu_usage || '''';
		
		
		v_sql := 'delete from #schema_name#.p_serverlogs
				 where 
					(substr(filename, 1, 11) = ''tabprotosrv'' or substr(filename, 1, 10) = ''dataserver'')
					and ts >= #max_ts_date_p_cpu_usage#';

		v_sql := replace(v_sql, '#schema_name#', p_schema_name);
		v_sql := replace(v_sql, '#max_ts_date_p_cpu_usage#', v_max_ts_date_p_cpu_usage);
		
		execute v_sql;
						
		GET DIAGNOSTICS v_num_deleted = ROW_COUNT;	
		return v_num_deleted;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY INVOKER;