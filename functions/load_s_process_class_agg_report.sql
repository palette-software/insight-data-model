-- One parametered version searches for the last loaded day or now::date and calles the
-- method with same name but two arguments. We always load one day at once.
CREATE OR REPLACE FUNCTION load_s_process_class_agg_report(p_schema_name text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;
	v_from text;
	v_sql_cur text;    
BEGIN

    execute 'set local search_path = ' || p_schema_name;
    
    -- At first find the day that should be the next one loaded
    -- This means it is the last that has data either in the agg_report table or in cpu_usage_report
	v_sql_cur := 'select get_max_ts_date(''#schema_name#'', ''p_process_class_agg_report'')';
    v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);
	execute v_sql_cur into v_from;

    v_sql := 
    'insert into s_process_class_agg_report
	    (   max_tho_p_id,
            ts_rounded_15_secs,
            process_name,
            host_name,
            cpu_usage_core_consumption,
            cpu_usage_cpu_time_consumption_seconds,
            cpu_usage_memory_usage_bytes,
            tableau_process
		)
    select
        max_tho_p_id,
        ts_rounded_15_secs,
        process_name,
        host_name,
        core_consumption,
        cpu_time_consumption_seconds,
        memory_usage_bytes,
        tableau_process
    from
        (
        select
            max(tho.p_id) as max_tho_p_id,
            tho.ts_rounded_15_secs,
            case
                when pc.process_class = ''Tableau'' then pc.process_name
                else coalesce(pc.process_class, ''Non-Tableau'')
            end as process_name,
            tho.host_name,
            sum(tho.cpu_core_consumption) as core_consumption,
            sum(tho.cpu_time_delta_ticks::numeric / 10000000) as cpu_time_consumption_seconds,
            sum(tho.memory_usage_bytes) as memory_usage_bytes,
            case
                when pc.process_class = ''Tableau'' then true
                else false
            end as tableau_process
        from
            p_threadinfo_delta tho
            left outer join p_process_classification pc on (pc.process_name = tho.process_name)
        where
        	tho.thread_id = -1
        	and tho.ts_rounded_15_secs >= date''#v_from#'' - 1
            -- The last 15 seconds could have new records with the new p_threadinfo load so
            -- we always skip the very recent 15 seconds in order to avoid "merge"
            -- This way the max(tho.p_id) always be the same for the group by
            and (host_name, ts_rounded_15_secs) not in 
                                                    (select 
                                                        host_name, 
                                                        max(ts_rounded_15_secs) max_ts_rounded_15_secs
                                                    from 
                                                        p_threadinfo_delta
                                                    where
                                                        ts_rounded_15_secs >= date''#v_from#'' - 1
                                                    group by host_name)

        group by
            tho.ts_rounded_15_secs,
            tho.host_name,
            pc.process_name,
            pc.process_class,
            tableau_process
        ) a
    where
        a.max_tho_p_id > (select max(coalesce(max_tho_p_id, 0))
                          from
                            p_process_class_agg_report
                          where
                            ts_rounded_15_secs >= date''#v_from#'' - 1
                            and a.host_name = host_name
                         )
    ';
                
    v_sql := replace(v_sql, '#v_from#', v_from);
    raise notice 'I: %', v_sql;
        
    execute v_sql;
    GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
	return v_num_inserted;
END;
$$ LANGUAGE plpgsql;