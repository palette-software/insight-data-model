CREATE OR REPLACE FUNCTION load_s_process_class_agg_report(p_schema_name text) returns bigint
AS $$
declare
    v_sql text;
    v_num_inserted bigint := 0;
    v_num_inserted_host bigint := 0;
    v_from_for_host text;
    v_sql_cur text;    
    rec record;
    v_max_tho_p_id bigint;
BEGIN

    execute 'set local search_path = ' || p_schema_name;            
    
    for rec in (select distinct host_name
                from 
                    p_threadinfo_delta)
    loop
    
        v_sql_cur := 'select to_char(coalesce(max(ts_rounded_15_secs), date''1001-01-01''), ''yyyy-mm-dd'') from p_process_class_agg_report where host_name = ''#host_name#''';
        v_sql_cur := replace(v_sql_cur, '#host_name#', rec.host_name);
        execute v_sql_cur into v_from_for_host;
           
        v_sql_cur := 'select coalesce(max(max_tho_p_id), 0)
                        from
                            p_process_class_agg_report
                        where
                            host_name = ''#host_name#''
                            and ts_rounded_15_secs >= date''#v_from_for_host#''
                    ';
                        
        v_sql_cur := replace(v_sql_cur, '#host_name#', rec.host_name);
        v_sql_cur := replace(v_sql_cur, '#v_from_for_host#', v_from_for_host);        
        execute v_sql_cur into v_max_tho_p_id;

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
                and tho.ts_rounded_15_secs >= date''#v_from_for_host#''
                -- The last 15 seconds could have new records with the new p_threadinfo load so
                -- we always skip the very recent 15 seconds in order to avoid "merge"
                -- This way the max(tho.p_id) always be the same for the group by
                and host_name = ''#host_name#''
                and ts_rounded_15_secs <> (select
                                                max(ts_rounded_15_secs) max_ts_rounded_15_secs
                                            from 
                                                p_threadinfo_delta
                                            where
                                                host_name = ''#host_name#''
                                                and ts_rounded_15_secs >= date''#v_from_for_host#''
                                            )

            group by
                tho.ts_rounded_15_secs,
                tho.host_name,
                pc.process_name,
                pc.process_class,
                tableau_process
            ) a
        where
            a.max_tho_p_id > #v_max_tho_p_id#
        ';
                    
        v_sql := replace(v_sql, '#v_from_for_host#', v_from_for_host);
        v_sql := replace(v_sql, '#host_name#', rec.host_name);
        v_sql := replace(v_sql, '#v_max_tho_p_id#', v_max_tho_p_id);
                
        raise notice 'I: %', v_sql;
            
        execute v_sql;
        GET DIAGNOSTICS v_num_inserted_host = ROW_COUNT;
        
        v_num_inserted := v_num_inserted + v_num_inserted_host;
            
    end loop;
    
    return v_num_inserted;
END;
$$ LANGUAGE plpgsql;
