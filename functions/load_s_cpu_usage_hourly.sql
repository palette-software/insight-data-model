CREATE OR REPLACE FUNCTION load_s_cpu_usage_hourly(p_schema_name text, p_load_date date)
 RETURNS bigint AS
 $BODY$
 declare
     v_sql text;
     v_num_inserted bigint := 0;
    v_load_date_txt text := to_char(p_load_date, 'yyyy-mm-dd');
 BEGIN

    execute 'set local search_path = ' || p_schema_name;

    perform check_if_load_date_already_in_table(p_schema_name, 'p_cpu_usage_hourly', p_load_date, false);
    v_sql := '
        insert into s_cpu_usage_hourly
        (
             host_name
            ,hour
            ,process_name
            ,parent_vizql_session
            ,cpu_time_consumption_seconds
            ,session_start_ts
            ,session_end_ts
            ,session_duration
            ,publisher_id
            ,publisher_friendly_name_id
            ,publisher_user_name_id
            ,interactor_id
            ,interactor_friendly_name_id
            ,interactor_user_name_id
            ,site_id
            ,site_name_id
            ,project_id
            ,project_name_id
            ,workbook_id
            ,workbook_name_id
            ,process_category)

        with t_cpu as
        (
        select
             cpu.cpu_usage_host_name as host_name
            ,date_trunc(''hour'', cpu.cpu_usage_ts_rounded_15_secs) as hour
            ,cpu_usage_process_name as process_name
            ,cpu_usage_parent_vizql_session as parent_vizql_session
            ,SUM(cpu.cpu_usage_cpu_time_consumption_seconds) AS cpu_time_consumption_seconds
            ,MIN(cpu.session_start_ts) AS session_start_ts
            ,MIN(cpu.session_end_ts) AS session_end_ts
            ,MIN(cpu.session_duration) as session_duration
            ,MIN(cpu.publisher_s_user_id) as publisher_id
            ,MIN(cpu.publisher_s_user_friendly_name) || '' ('' || MIN(cpu.publisher_s_user_id) || '')'' AS publisher_friendly_name_id
            ,MIN(cpu.publisher_s_user_name) || '' ('' || MIN(cpu.publisher_s_user_id) || '')'' AS publisher_user_name_id
            ,MIN(cpu.interactor_s_user_id) as interactor_id
            ,MIN(cpu.interactor_s_user_friendly_name) || '' ('' || MIN(cpu.interactor_s_user_id) || '')'' AS interactor_friendly_name_id
            ,MIN(cpu.interactor_s_user_name) || '' ('' || MIN(cpu.interactor_s_user_id) || '')'' AS interactor_user_name_id
            ,MIN(cpu.site_id) as site_id
            ,MIN(cpu.site_name_id) AS site_name_id
            ,MIN(cpu.project_id) as project_id
            ,MIN(cpu.project_name_id) AS project_name_id
            ,MIN(cpu.workbook_id) as workbook_id
            ,MIN(cpu.workbook_name_id) AS workbook_name_id
        from
            p_cpu_usage_report cpu
        where 1 = 1
            and cpu.cpu_usage_ts_rounded_15_secs >= date''#v_load_date_txt#''
            and cpu.cpu_usage_ts_rounded_15_secs < date''#v_load_date_txt#'' + interval''1 day''
            and cpu.cpu_usage_max_reporting_granularity = true
        group by
             cpu.cpu_usage_host_name
            ,date_trunc(''hour'', cpu.cpu_usage_ts_rounded_15_secs)
            ,cpu.cpu_usage_process_name
            ,cpu.cpu_usage_parent_vizql_session
        )

        select
             cpu.host_name
            ,cpu.hour
            ,cpu.process_name
            ,cpu.parent_vizql_session
            ,cpu.cpu_time_consumption_seconds
            ,cpu.session_start_ts
            ,cpu.session_end_ts
            ,cpu.session_duration
            ,cpu.publisher_id
            ,cpu.publisher_friendly_name_id
            ,cpu.publisher_user_name_id
            ,cpu.interactor_id
            ,cpu.interactor_friendly_name_id
            ,cpu.interactor_user_name_id
            ,cpu.site_id
            ,cpu.site_name_id
            ,cpu.project_id
            ,cpu.project_name_id
            ,cpu.workbook_id
            ,cpu.workbook_name_id
            ,case
                when coalesce(cpu.parent_vizql_session, ''-'') not in (''default'', ''-'')
                then
                    ''INTERACTION''
                when cpu.process_name in (''tdeserver'', ''tdeserver64'', ''backgrounder'', ''hyperd'')
                then
                    ''EXTRACTION''
                when pclass.process_class = ''Tableau''
                then
                    ''OTHER-TABLEAU''
                when pclass.p_id is null or pclass.process_class = ''Palette''
                then
                    ''OTHER-NON-TABLEAU''
             end as process_category
        from
            t_cpu cpu
            left outer join p_process_classification pclass on (pclass.process_name = cpu.process_name)
        ';

     v_sql := replace(v_sql, '#v_load_date_txt#', v_load_date_txt);
     raise notice 'I: %', v_sql;
     execute v_sql;

     GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
     return v_num_inserted;
 END;
 $BODY$
 LANGUAGE plpgsql VOLATILE SECURITY INVOKER;