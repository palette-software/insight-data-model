CREATE OR REPLACE FUNCTION delete_recent_records_from_p_serverlogs(p_schema_name text)
RETURNS bigint AS
$BODY$
declare
	v_sql text;
	v_num_deleted bigint;
begin	

		v_sql := 'delete from #schema_name#.p_serverlogs
				 where 
					(substr(filename, 1, 11) = ''tabprotosrv'' or substr(filename, 1, 10) = ''dataserver'')
					and ts >= (select #schema_name#.get_max_ts_date(''#schema_name#'', ''p_serverlogs''))';

		v_sql := replace(v_sql, '#schema_name#', p_schema_name);
		
		execute v_sql;
						
		GET DIAGNOSTICS v_num_deleted = ROW_COUNT;	
		return v_num_deleted;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY INVOKER;