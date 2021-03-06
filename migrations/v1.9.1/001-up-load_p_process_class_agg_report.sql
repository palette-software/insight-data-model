CREATE or replace function load_p_process_class_agg_report(p_schema_name text, p_from text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;
	v_sql_cur text;
    v_to text;
    v_tableau_process_list text;
BEGIN
	execute 'set local search_path = ' || p_schema_name;

    -- Get the upper limit of the current load iteration
	v_sql_cur := 'select
		to_char(coalesce(min(cpu_usage_ts_rounded_15_secs), date''#p_from#'' + 1), ''yyyy-mm-dd hh24:mi:ss.ms'')
	from
		p_cpu_usage_report
	where
        cpu_usage_thread_id = -1
	 	and cpu_usage_ts_rounded_15_secs >= date''#p_from#'' + 1
	';
	v_sql_cur := replace(v_sql_cur, '#p_from#', p_from);
	raise notice 'I: %', v_sql_cur;
	execute v_sql_cur into v_to;

	-- We delete at most two days here as if we deleted only one we never would progress if
	-- loading is a couple of days behind.
	v_sql_cur := 'delete
		from p_process_class_agg_report
		where ts_rounded_15_secs >= date''#p_from#''
		and ts_rounded_15_secs <= timestamp''#v_to#''
	';
	v_sql_cur := replace(v_sql_cur, '#p_from#', p_from);
	v_sql_cur := replace(v_sql_cur, '#v_to#', v_to);

    raise notice 'I: %', v_sql_cur;
	execute v_sql_cur;

    v_tableau_process_list := '
        ''vizqlserver'', ''tdeserver64'', ''backgrounder'',
        ''vizportal'', ''zookeeper'', ''tabprotosrv'', ''tableau'', ''clustercontroller'',
        ''tabspawn'', ''redis-server'', ''tabadminservice'', ''tabsvc'', ''postgres'',
        ''dataserver'', ''filestore'', ''tabadmsvc'', ''tabadmwrk'', ''tdeserver'', ''wgserver'',
		''tabadmin'', ''tabcmd'', ''7z''
    ';
	-- Loading with the same logic as delete. When everything is find we load only "today" but if we lagged
    -- behind we load two days as that is needed for "progressing" and not getting stuck in a single day.
	-- The plus 1 in the to clause is needed as we compare timestamp to date and in that case date is
	-- implicit converted to timestamp at 00:00:00.000
	v_sql := 'insert into p_process_class_agg_report
	    (
            ts_rounded_15_secs,
            process_name,
            host_name,
            cpu_usage_core_consumption,
            cpu_usage_cpu_time_consumption_seconds,
            cpu_usage_memory_usage_bytes,
            tableau_process
		)
	    select
    	    cpu_usage_ts_rounded_15_secs,
            case
                when cpu_usage_process_name in (#v_tableau_process_list#) then cpu_usage_process_name
                else ''Non-Tableau''
            end as process_name,
            cpu_usage_host_name,
            sum(cpu_usage_cpu_core_consumption) as cpu_usage_core_consumption,
            sum(cpu_usage_cpu_time_consumption_seconds) as cpu_usage_cpu_time_consumption_seconds,
            sum(cpu_usage_memory_usage_bytes) as cpu_usage_memory_usage_bytes,
            case
                when cpu_usage_process_name in (#v_tableau_process_list#) then true
                else false
            end as tableau_process
        from
	        p_cpu_usage_report
        where
			cpu_usage_thread_id = -1
			and cpu_usage_ts_rounded_15_secs >= date''#p_from#''
			and cpu_usage_ts_rounded_15_secs <= timestamp''#v_to#''
        group by
	        cpu_usage_ts_rounded_15_secs,
	        cpu_usage_host_name,
	        process_name,
            tableau_process
		';

		v_sql := replace(v_sql, '#p_from#', p_from);
		v_sql := replace(v_sql, '#v_to#', v_to);
		v_sql := replace(v_sql, '#v_tableau_process_list#', v_tableau_process_list);

		raise notice 'I: %', v_sql;
		execute v_sql;

		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;

		return v_num_inserted;
END;
$$ LANGUAGE plpgsql;
