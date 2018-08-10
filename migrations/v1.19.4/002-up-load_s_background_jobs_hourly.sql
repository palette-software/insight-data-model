CREATE OR REPLACE FUNCTION load_s_background_jobs_hourly(p_schema_name text, p_load_date date)
 RETURNS bigint AS
 $BODY$
 declare
     v_sql text;
     v_num_inserted bigint := 0;
    v_load_date_txt text := to_char(p_load_date, 'yyyy-mm-dd');
 BEGIN

    execute 'set local search_path = ' || p_schema_name;

    perform check_if_load_date_already_in_table(p_schema_name, 'p_background_jobs_hourly', p_load_date, false);
    v_sql := '
        insert into s_background_jobs_hourly
        (
            hour
           ,time_consumption_seconds
           ,started_at
           ,completed_at
           ,publisher_id
           ,publisher_friendly_name_id
           ,publisher_user_name_id
           ,site_id
           ,site_name
           ,site_name_id
           ,project_id
           ,project_name
           ,project_name_id
           ,workbook_datasource_id
           ,workbook_datasource_name
           ,workbook_datasource_name_id
           ,wd_type
        )
              
        with t_base
        as
        (
        select
             p_id
            ,date_part(''hour'', date_trunc(''hour'', completed_at) - date_trunc(''hour'', started_at))::int + 1 as num_of_range
            ,started_at
            ,completed_at
            ,publisher_id
            ,publisher_friendlyname
            ,publisher_name
            ,site_id
            ,site_name
            ,project_id
            ,project_name
            ,workbooks_datasources_id
            ,workbooks_datasources_name
            ,wd_type
        from
            p_background_jobs
        where 1 = 1
            and workbooks_datasources_id is not null
            and created_at >= date''#v_load_date_txt#''
            and created_at < date''#v_load_date_txt#'' + interval ''1 day''
        )

        select
             date_trunc(''hour'', started_at + interval''1 hour'' * (step -1)) as hour
            ,extract(''epoch'' from    
                    case
                        when num_of_range = 1 then completed_at - started_at
                        when step = 1 then interval''1 hour'' - (started_at - date_trunc(''hour'', started_at))
                        when step = num_of_range then completed_at - date_trunc(''hour'', completed_at)
                        else interval''1 hour''
                     end)
             as time_consuption_sec
            ,started_at
            ,completed_at
            ,publisher_id
            ,publisher_friendlyname || '' ('' || publisher_id || '')'' as publisher_friendly_name_id
            ,publisher_name || '' ('' || publisher_id || '')'' as publisher_user_name_id
            ,site_id
            ,site_name
            ,site_name || '' ('' || site_id || '')'' as site_name_id    
            ,project_id
            ,project_name
            ,project_name || '' ('' || project_id || '')'' as project_name_id
            ,workbooks_datasources_id
            ,workbooks_datasources_name
            ,workbooks_datasources_name || '' ('' || workbooks_datasources_id || '')'' as workbook_datasource_name_id
            ,wd_type
        from
            t_base b
            inner join (
                        select
                             p_id
                            ,generate_series(1, t.num_of_range) as step
                        from
                            t_base t
                        ) a on (b.p_id = a.p_id)
        ';

     v_sql := replace(v_sql, '#v_load_date_txt#', v_load_date_txt);
     raise notice 'I: %', v_sql;
     execute v_sql;

     GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
     return v_num_inserted;
 END;
 $BODY$
 LANGUAGE plpgsql VOLATILE SECURITY INVOKER;