CREATE or replace function copy_p_src_logs_bootstrap(p_schema_name text) returns int
AS $$
declare
    v_sql_cur text;
    c refcursor;
    rec record;
    v_sql text;
BEGIN

        truncate table s_serverlogs_bootstrap_rpt;
        
        insert into s_serverlogs_bootstrap_rpt(host_name, start_ts)
        select distinct host_name, start_ts::date
        from
            p_serverlogs_bootstrap_rpt_orig
        ;
        
        perform manage_partitions(p_schema_name, 'p_serverlogs_bootstrap_rpt');

        v_sql_cur := 'select distinct start_ts::date as load_day from p_serverlogs_bootstrap_rpt_orig order by 1';
         
        open c for execute (v_sql_cur);
        loop
              fetch c into rec;
              exit when not found;

              v_sql := 'insert into p_serverlogs_bootstrap_rpt
                        select *
                        from
                            p_serverlogs_bootstrap_rpt_orig
                        where 1 = 1
                            and start_ts >= date''#load_day#''
                            and start_ts < date''#load_day#'' + interval''1 day''
                        ';              
              v_sql := replace(v_sql, '#load_day#', to_char(rec.load_day, 'yyyy-mm-dd'));
              execute v_sql;  
        end loop;
        close c;

    return 0;

END;
$$ LANGUAGE plpgsql;