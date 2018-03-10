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

              v_sql := 'insert into p_serverlogs_bootstrap_rpt (
                            p_id
                           ,p_serverlogs_p_id
                           ,serverlogs_id
                           ,p_filepath
                           ,filename
                           ,process_name
                           ,host_name
                           ,ts
                           ,process_id
                           ,thread_id
                           ,sev
                           ,req
                           ,sess
                           ,site
                           ,username
                           ,username_without_domain
                           ,k
                           ,v
                           ,parent_vizql_session
                           ,parent_vizql_destroy_sess_ts
                           ,parent_dataserver_session
                           ,spawned_by_parent_ts
                           ,parent_process_type
                           ,parent_vizql_site
                           ,parent_vizql_username
                           ,parent_dataserver_site
                           ,parent_dataserver_username
                           ,p_serverlogs_p_cre_date
                           ,thread_name
                           ,elapsed_ms
                           ,start_ts
                           ,session_start_ts_utc
                           ,session_end_ts_utc
                           ,site_name_id
                           ,project_name_id
                           ,workbook_name_id
                           ,workbook_rev
                           ,publisher_username_id
                           ,user_type
                           ,session_duration
                           ,session_elapsed_seconds
                           ,currentsheet
                           ,p_cre_date
                           ,publisher_id
                           ,site_id
                           ,project_id
                           ,workbook_id
                           ,view_id
                           ,v_truncated
                     )                       
                    select
                        p_id
                       ,p_serverlogs_p_id
                       ,serverlogs_id
                       ,p_filepath
                       ,filename
                       ,process_name
                       ,host_name
                       ,ts
                       ,process_id
                       ,thread_id
                       ,sev
                       ,req
                       ,sess
                       ,site
                       ,username
                       ,username_without_domain
                       ,k
                       ,v
                       ,parent_vizql_session
                       ,parent_vizql_destroy_sess_ts
                       ,parent_dataserver_session
                       ,spawned_by_parent_ts
                       ,parent_process_type
                       ,parent_vizql_site
                       ,parent_vizql_username
                       ,parent_dataserver_site
                       ,parent_dataserver_username
                       ,p_serverlogs_p_cre_date
                       ,thread_name
                       ,elapsed_ms
                       ,start_ts
                       ,session_start_ts_utc
                       ,session_end_ts_utc
                       ,site_name_id
                       ,project_name_id
                       ,workbook_name_id
                       ,workbook_rev
                       ,publisher_username_id
                       ,user_type
                       ,session_duration
                       ,session_elapsed_seconds
                       ,currentsheet
                       ,p_cre_date
                       ,publisher_id
                       ,site_id
                       ,project_id
                       ,workbook_id
                       ,view_id
                       ,v_truncated                        
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