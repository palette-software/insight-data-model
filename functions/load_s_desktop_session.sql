CREATE OR REPLACE FUNCTION load_s_desktop_session(p_schema_name text, p_load_date date)
RETURNS bigint AS
$BODY$
declare
	v_sql text;
	v_num_inserted bigint := 0;		
    v_load_date_txt text := to_char(p_load_date, 'yyyy-mm-dd');
BEGIN	

		execute 'set local search_path = ' || p_schema_name;			
        
        perform check_if_load_date_already_in_table(p_schema_name, 'p_desktop_session', p_load_date, false);
        
		v_sql := 'INSERT INTO s_desktop_session
		(
			dataserver_session, 
			process_name,
			host_name,
			cpu_time_consumption_seconds,
			session_start_ts,
			session_end_ts,
			session_duration,
            interactor_id,
			interactor_friendly_name_id,
			interactor_user_name_id,
            site_id,
			site_name_id,
            project_id,
	        project_name_id,
			num_fatals,
			num_errors,
			num_warnings,
			user_type,
            datasource_id
		)
        with t_base as 
        (select     
            parent_dataserver_session
        FROM        		       
            p_cpu_usage t
            left outer join (select distinct
                                dataserver_session
                            from
                                p_desktop_session
                            where 1 = 1
                                and session_start_ts >= date''#v_load_date_txt#'' - interval''1 day''
                                and session_start_ts < date''#v_load_date_txt#''
                            ) ds on (ds.dataserver_session = t.parent_dataserver_session)
        WHERE 1 = 1
            and ts_rounded_15_secs >= date''#v_load_date_txt#''
            and ts_rounded_15_secs <= date''#v_load_date_txt#'' + interval''26 hours''
            and parent_dataserver_session IS NOT NULL
            and parent_dataserver_session not in (''default'', ''-'')
            and ds.dataserver_session is null
        GROUP BY                
            parent_dataserver_session
        HAVING max(parent_vizql_session) is null
        )

        select
            datasrv_sess.dataserver_session,
            datasrv_sess.process_name,
            datasrv_sess.host_name,
            datasrv_sess.cpu_time_consumption_seconds,
            slogs.session_start_ts,
            slogs.session_end_ts,
            extract(''epoch'' from (slogs.session_end_ts - slogs.session_start_ts)) as session_duration,
            min(case when datasrv_sess.process_name = ''dataserver'' then su.id end) over (partition by datasrv_sess.host_name, datasrv_sess.dataserver_session) as interactor_id,
            min(case when datasrv_sess.process_name = ''dataserver'' then su.friendly_name || '' ('' || su.id || '')'' end) over (partition by datasrv_sess.host_name, datasrv_sess.dataserver_session) as interactor_friendly_name_id, 
            min(case when datasrv_sess.process_name = ''dataserver'' then slogs.username  || '' ('' || coalesce(su.id, -1) || '')'' end) over (partition by datasrv_sess.host_name, datasrv_sess.dataserver_session) as interactor_user_name_id,
            min(case when datasrv_sess.process_name = ''dataserver'' then sites.id end) over (partition by datasrv_sess.host_name, datasrv_sess.dataserver_session) as site_id,
            min(case when datasrv_sess.process_name = ''dataserver'' then slogs.sitename || '' ('' || coalesce(sites.id, -1) || '')'' end) over (partition by datasrv_sess.host_name, datasrv_sess.dataserver_session) AS site_name_id,
            min(case when datasrv_sess.process_name = ''dataserver'' then p.id end) over (partition by datasrv_sess.host_name, datasrv_sess.dataserver_session) as project_id,
            min(case when datasrv_sess.process_name = ''dataserver'' then p.name || '' ('' || coalesce(p.id, -1) || '')'' end) over (partition by datasrv_sess.host_name, datasrv_sess.dataserver_session) AS project_name_id,
            slogs.num_fatal,            
            slogs.num_error,
            slogs.num_warn,
            ''Desktop'' as user_type,
            coalesce(e.id, dc.datasource_id) as datasource_id                        
        from        
            t_base b
            inner join   
                    (SELECT  
                	    host_name as host_name,
                        parent_dataserver_session AS dataserver_session,
                        process_name AS process_name,            
                        SUM(cpu_time_consumption_seconds) AS cpu_time_consumption_seconds
                	FROM        		       
                        p_cpu_usage            		       
                	WHERE 
                        ts_rounded_15_secs >= date''#v_load_date_txt#'' and
                        ts_rounded_15_secs <= date''#v_load_date_txt#'' + interval''26 hours''
                	GROUP BY
                        host_name,  
                        parent_dataserver_session, 
                        process_name
                    ) datasrv_sess on (b.parent_dataserver_session = datasrv_sess.dataserver_session)
            left outer join (
        	                SELECT  
                                t.parent_dataserver_session AS dataserver_session,
                                t.process_name, 
                                SUM(CASE WHEN t.sev = ''fatal'' THEN 1 ELSE 0 END) num_fatal,
                                SUM(CASE WHEN t.sev = ''error'' THEN 1 ELSE 0 END) num_error,
                                SUM(CASE WHEN t.sev = ''warn'' THEN 1 ELSE 0 END) num_warn,
                                min(f.session_start_ts) as session_start_ts,
                                min(f.session_end_ts) as session_end_ts,
                                max(t.username) as username,
                                max(t.site) as sitename,
                                min(data_connection_name) AS data_connection_name,
                                max(f.server_viewerid) as server_viewerid,
                                min(f.descriptor) as descriptor
        	                FROM 
        	                    p_serverlogs t
                                inner join (select parent_dataserver_session,
                                                   min(ts) as session_start_ts,
                                                   max(ts) as session_end_ts,
                                                   max(case when k = ''ds-connect-data-connection'' then substring(v FROM ''.*named-connection name=''''(.*?)''''.*'') end) AS data_connection_name,
                                                   max(case when k = ''construct-protocol'' then substring(v from ''"server-viewerid":"(.*?)","'') end) as server_viewerid,
                                                   max(case when k = ''ds-connect-data-connection'' then substring(v from E''dbname.*\\\\\\\\\\\\\\\\(.*?)\\\\\\\\\\\\\\\\.*?\.tde'') end) as descriptor
                                            from
                                                p_serverlogs
                                             where  1 = 1
                                                and ts >= date''#v_load_date_txt#''
        						                and ts <= date''#v_load_date_txt#'' + interval''26 hours''
                                            group by
                                                    parent_dataserver_session 
                                            ) f on (t.parent_dataserver_session = f.parent_dataserver_session)
        	                WHERE 
                                1 = 1
                                and t.parent_vizql_session is null
        						and t.ts >= date''#v_load_date_txt#''
        						and t.ts <= date''#v_load_date_txt#'' + interval''26 hours''
        	                GROUP BY 
                                    t.parent_dataserver_session, 
                                    t.process_name
        	        ) slogs ON (datasrv_sess.dataserver_session = slogs.dataserver_session
                                AND datasrv_sess.process_name = slogs.process_name)
            left outer join h_sites sites on (sites.name = slogs.sitename 
                                            and slogs.session_start_ts between sites.p_valid_from and sites.p_valid_to)
            
            left outer join h_system_users su on (su.name = slogs.username
        						                 and slogs.session_start_ts between su.p_valid_from and su.p_valid_to
        						  				 )
            left outer join h_extracts e on (1 = 1
                                            and e.descriptor = slogs.descriptor
                                            and slogs.session_start_ts between e.p_valid_from and e.p_valid_to
                                            )
            left outer join h_datasources ds on (1 = 1
                                        and ds.site_id = sites.id
                                        and ds.id = e.datasource_id
                                        and slogs.session_start_ts between ds.p_valid_from and ds.p_valid_to)                                            
            left outer join h_data_connections dc on (1 = 1    
                                                and dc.owner_type = ''Datasource''
                                                and dc.name = slogs.data_connection_name
                                                and slogs.session_start_ts between dc.p_valid_from and dc.p_valid_to)            
            left outer join h_datasources dc_ds on (1 = 1
                                            and dc_ds.site_id = sites.id
                                            and dc_ds.id = dc.datasource_id                                                                                
                                            and slogs.session_start_ts between dc_ds.p_valid_from and dc_ds.p_valid_to)                                                
            left outer join h_projects p on (1 = 1
                                            and p.site_id = sites.id
                                            and p.id = coalesce(ds.project_id, dc_ds.project_id)
                                            and slogs.session_start_ts between p.p_valid_from and p.p_valid_to)
        where 1 = 1
            and slogs.session_start_ts >= date''#v_load_date_txt#''
            and slogs.session_start_ts < date''#v_load_date_txt#'' + interval''1 day''
            and coalesce(slogs.server_viewerid, '''') = ''''
		';
			
		v_sql := replace(v_sql, '#v_load_date_txt#', v_load_date_txt);
        
		raise notice 'I: %', v_sql;
		execute v_sql;
		
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
		return v_num_inserted;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY INVOKER;