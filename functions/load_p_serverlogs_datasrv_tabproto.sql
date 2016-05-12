CREATE or replace function load_p_serverlogs_datasrv_tabproto(p_schema_name text) returns bigint
AS $$
declare
	v_sql text;	
begin		

	execute 'select ' || p_schema_name || '.' || 'delete_recent_records_from_p_serverlogs(''' || p_schema_name || ''')';
	execute 'select ' || p_schema_name || '.' || 'load_s_serverlogs_dataserver(''' || p_schema_name || ''')';
	execute 'select ' || p_schema_name || '.' || 'load_s_serverlogs_tabproto(''' || p_schema_name || ''')';	
	execute 'select ' || p_schema_name || '.' || 'manage_partitions(''' || p_schema_name || ''',''p_serverlogs'')';
	execute 'select ' || p_schema_name || '.' || 'insert_p_serverlogs_from_s_serverlogs(''' || p_schema_name || ''')';

	return 0;
END;
$$ LANGUAGE plpgsql