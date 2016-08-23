CREATE or replace function load_from_stage_to_dwh(p_schema_name text, p_table_name text) returns bigint
AS $$
declare
	v_sql text;
	v_sql_cur text;
	v_num_inserted bigint;
	c refcursor;
	rec record;
	v_cols text;
begin	

		if lower(p_table_name) in ('p_cpu_usage', 'p_cpu_usage_report') then
			perform load_from_stage_to_dwh_multi_range_part(p_schema_name, p_table_name);
		elseif lower(p_table_name) in ('p_cpu_usage_agg_report', 'p_interactor_session', 'p_process_class_agg_report', 'p_cpu_usage_bootstrap_rpt', 'p_serverlogs_bootstrap_rpt') then
			perform load_from_stage_to_dwh_single_range_part(p_schema_name, p_table_name);
		else 
            raise notice '--WARNING: No load management happened for % - wrong table specified?--', p_table_name;            
		end if;
		
    	return 0;
END;
$$ LANGUAGE plpgsql;