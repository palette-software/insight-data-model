CREATE or replace function load_s_errorlogs(p_schema_name text, p_load_date date) returns bigint
AS $$
declare
    v_sql text;
    v_num_inserted bigint;
    v_load_date_txt text := to_char(p_load_date, 'yyyy-mm-dd');
begin        

    execute 'set local search_path = ' || p_schema_name;
    
    perform check_if_load_date_already_in_table(p_schema_name, 'p_errorlogs', p_load_date, false);
    
    v_sql := 'insert into s_errorlogs
        (            
            p_serverlogs_p_id
           , serverlogs_id
           , p_filepath
           , filename
           , process_name
           , host_name
           , ts
           , process_id
           , thread_id
           , sev
           , req
           , sess
           , site
           , username
           , username_without_domain
           , k
           , v
           , parent_vizql_session
           , parent_vizql_destroy_sess_ts
           , parent_dataserver_session
           , spawned_by_parent_ts
           , parent_process_type
           , parent_vizql_site
           , parent_vizql_username
           , parent_dataserver_site
           , parent_dataserver_username
           , p_serverlogs_p_cre_date
           , thread_name
           , elapsed_ms
           , start_ts
           , session_start_ts_utc
           , session_end_ts_utc
           , site_id
           , site_name_id
           , project_id
           , project_name_id
           , workbook_id
           , workbook_name_id
           , workbook_rev
           , publisher_id
           , publisher_username_id
           , user_type
           , session_duration
           , session_elapsed_seconds
           , v_truncated
        )
        select     
            srvlog.p_id           
           , srvlog.serverlogs_id
           , srvlog.p_filepath
           , srvlog.filename
           , srvlog.process_name
           , srvlog.host_name
           , srvlog.ts
           , srvlog.process_id
           , srvlog.thread_id
           , srvlog.sev
           , srvlog.req
           , srvlog.sess
           , srvlog.site
           , srvlog.username
           , srvlog.username_without_domain
           , srvlog.k
           , srvlog.v
           , srvlog.parent_vizql_session
           , srvlog.parent_vizql_destroy_sess_ts
           , srvlog.parent_dataserver_session
           , srvlog.spawned_by_parent_ts
           , srvlog.parent_process_type
           , srvlog.parent_vizql_site
           , srvlog.parent_vizql_username
           , srvlog.parent_dataserver_site
           , srvlog.parent_dataserver_username
           , srvlog.p_cre_date
           , srvlog.thread_name
           , srvlog.elapsed_ms
           , srvlog.start_ts
           , srvlog.session_start_ts_utc
           , srvlog.session_end_ts_utc
           , srvlog.site_id
           , srvlog.site_name_id
           , srvlog.project_id
           , srvlog.project_name_id
           , srvlog.workbook_id
           , srvlog.workbook_name_id
           , srvlog.workbook_rev
           , srvlog.publisher_id
           , srvlog.publisher_username_id
           , srvlog.user_type
           , srvlog.session_duration
           , srvlog.session_elapsed_seconds
           , srvlog.v_truncated
        from
            p_serverlogs srvlog
        where
            1 = 1
            and srvlog.ts >= date''#v_load_date_txt#''
            and srvlog.ts < date''#v_load_date_txt#'' + interval''1 day''
            and srvlog.sev in (''error'', ''fatal'')
        ';            
            
        v_sql := replace(v_sql, '#v_load_date_txt#', v_load_date_txt);        
        
        raise notice 'I: %', v_sql;
        execute v_sql;

        GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
        return v_num_inserted;

END;
$$ LANGUAGE plpgsql;
