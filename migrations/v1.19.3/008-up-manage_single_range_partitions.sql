CREATE or replace function manage_single_range_partitions(p_schema_name text, p_table_name text) returns int
AS $$
declare
    v_sql_cur text;
    c refcursor;
    rec record;
    v_sql text;
    v_max_ts_date_p_threadinfo text;
    v_max_ts_date_p_serverlogs text;
    v_subpart_cols text;
    v_table_name text;
    v_last_partition date;
BEGIN

        v_subpart_cols := '';
        execute 'set local search_path = ' || p_schema_name;
        
        v_table_name := lower(p_table_name);
        
        v_sql_cur := '';
        v_sql := '';
        

        if v_table_name in ('p_interactor_session', 'p_desktop_session') then --year
            v_sql_cur := 'select distinct session_start_ts::date d from ' || 's' || ltrim(v_table_name, 'p');
        elseif v_table_name in ('p_process_class_agg_report') then --month
            v_sql_cur := 'select distinct ts_rounded_15_secs::date d from '|| 's' || ltrim(v_table_name, 'p');
        elseif v_table_name in ('p_cpu_usage_bootstrap_rpt') then --month
            v_sql_cur := 'select distinct cpu_usage_ts_rounded_15_secs::date d from '|| 's' || ltrim(v_table_name, 'p');
        elseif v_table_name in ('plainlogs') then --day
            v_sql_cur := 'select distinct ts::date d from ' || 'ext_plainlogs';
        elseif v_table_name in ('p_http_requests', 'p_background_jobs', 'p_async_jobs') then --month
            v_sql_cur := 'select distinct created_at::date d from '|| ltrim(v_table_name, 'p_');
        elseif v_table_name in ('p_errorlogs') then --day
            v_sql_cur := 'select distinct ts::date d from ' || 's_errorlogs';
        elseif v_table_name in ('p_cpu_usage_hourly', 'p_background_jobs_hourly') then --month
            v_sql_cur := 'select distinct hour::date d from ' || 's' || ltrim(v_table_name, 'p');
        end if;
        
        open c for execute (v_sql_cur);
        loop
              fetch c into rec;
              exit when not found;
              
            -- In rare cases there is no data for an entire day from a specfic host
            -- We need to make sure that there is no hole between the days since 
            -- it can cause "no partition key error" if another host does have data for this day
            -- This has to be applied only for plainlogs
            
            select 
                coalesce(to_date(max(partitionname), 'yyyymmdd'), date'1001-01-01') as last_partition into v_last_partition
            from 
                pg_partitions
            where 1 = 1
                and schemaname = p_schema_name
                and tablename = 'plainlogs'
                and tablename = p_table_name
                and partitionlevel = 0;

            if v_last_partition = date'1001-01-01' then
                v_last_partition := rec.d - 1;
            end if;
            
            for i in 1 .. (rec.d - v_last_partition)
            loop
                
                v_sql := 'ALTER TABLE #schema_name#.#table_name# 
                             ADD PARTITION "#partition_name#" START (date''#start_date#'') INCLUSIVE END (date''#end_date#'') EXCLUSIVE WITH (appendonly=true, orientation=column, compresstype=quicklz)';

                v_sql := replace(v_sql, '#schema_name#', p_schema_name);
                v_sql := replace(v_sql, '#table_name#', v_table_name);
                
                if v_table_name in ('p_interactor_session', 'p_desktop_session') then --year
                    v_sql := replace(v_sql, '#partition_name#', to_char(rec.d, 'yyyy'));
                    v_sql := replace(v_sql, '#start_date#', to_char(rec.d, 'yyyy') || '-01-01');
                    v_sql := replace(v_sql, '#end_date#', to_char(rec.d + interval'1 year', 'yyyy') || '-01-01');
                elseif v_table_name in ('p_process_class_agg_report', 'p_cpu_usage_bootstrap_rpt', 'p_http_requests', 'p_background_jobs', 'p_async_jobs', 'p_cpu_usage_hourly', 'p_background_jobs_hourly') then --month
                    v_sql := replace(v_sql, '#partition_name#', to_char(rec.d, 'yyyymm'));
                    v_sql := replace(v_sql, '#start_date#', to_char(rec.d, 'yyyy-mm') || '-01');
                    v_sql := replace(v_sql, '#end_date#', to_char(rec.d + interval'1 month', 'yyyy-mm') || '-01');
                elseif v_table_name in ('plainlogs', 'p_errorlogs') then --day
                    v_sql := replace(v_sql, '#partition_name#', to_char(v_last_partition + i, 'yyyymmdd'));
                    v_sql := replace(v_sql, '#start_date#', to_char(v_last_partition + i, 'yyyy-mm-dd'));
                    v_sql := replace(v_sql, '#end_date#', to_char(v_last_partition + i + 1, 'yyyy-mm-dd'));
                end if;
                
                begin
                    if v_table_name in ('p_interactor_session', 'p_desktop_session') then --year
                        if (not does_part_exist(p_schema_name, v_table_name, to_char(rec.d, 'yyyy'))) then
                              execute v_sql;
                        end if;
                        --exception when duplicate_object
                        --    then null;
                    elseif v_table_name in ('p_process_class_agg_report', 'p_cpu_usage_bootstrap_rpt', 'p_http_requests', 'p_background_jobs', 'p_async_jobs', 'p_cpu_usage_hourly', 'p_background_jobs_hourly') then --month
                        if (not does_part_exist(p_schema_name, v_table_name, to_char(rec.d, 'yyyymm'))) then
                              execute v_sql;
                        end if;
                        --exception when duplicate_object
                        --    then null;
                    elseif v_table_name in ('plainlogs', 'p_errorlogs') then --day
                        if (not does_part_exist(p_schema_name, v_table_name, to_char(v_last_partition + i, 'yyyymmdd'))) then
                              execute v_sql;
                        end if;
                        --exception when duplicate_object
                        --    then null;
                    end if;
                end;
                
                raise notice 'I: %', v_sql;                                
                
            end loop;                
        end loop;
        close c;
    
    return 0;

END;
$$ LANGUAGE plpgsql;
