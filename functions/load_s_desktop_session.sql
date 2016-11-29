select * from h_projects;select * from s_desktop_session;
select * from p_desktop_session;

select load_s_desktop_session('palette', date'2016-11-27');

select max(session_start_ts) from p_desktop_session;


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
			user_type
		)
        select
            datasrv_sess.dataserver_session,
            datasrv_sess.process_name,
            datasrv_sess.host_name,
            datasrv_sess.cpu_time_consumption_seconds,
            min(case when datasrv_sess.process_name = ''dataserver'' then slogs.session_start_ts end) over (partition by datasrv_sess.host_name, datasrv_sess.dataserver_session) as session_start_ts,
            min(case when datasrv_sess.process_name = ''dataserver'' then slogs.session_end_ts end) over (partition by datasrv_sess.host_name, datasrv_sess.dataserver_session) as session_end_ts,
            min(case when datasrv_sess.process_name = ''dataserver'' then extract(''epoch'' from (slogs.session_end_ts - slogs.session_start_ts)) end) over (partition by datasrv_sess.host_name, datasrv_sess.dataserver_session) as session_duration,
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
            ''Desktop'' as user_type
        from (
    		SELECT  
    		    host_name as host_name,
                parent_dataserver_session AS dataserver_session,
                process_name AS process_name,            
                SUM(cpu_time_consumption_seconds) AS cpu_time_consumption_seconds
    		FROM        		       
                p_cpu_usage            		       
    		WHERE 
                session_start_ts >= date''#v_load_date_txt#'' and
                session_start_ts < date''#v_load_date_txt#'' + interval''1 day'' and
                ts_rounded_15_secs >= date''#v_load_date_txt#'' and
                ts_rounded_15_secs <= date''#v_load_date_txt#'' + interval''26 hours'' and
                parent_vizql_session IS NULL and
                parent_dataserver_session IS NOT NULL and
                parent_dataserver_session not in (''default'', ''-'')
    		GROUP BY
                host_name,
                parent_dataserver_session, 
                process_name
            ) datasrv_sess
            left outer join (
    		                SELECT  
                                parent_dataserver_session AS dataserver_session,
                                process_name, 
                                SUM(CASE WHEN sev = ''fatal'' THEN 1 ELSE 0 END) num_fatal,
                                SUM(CASE WHEN sev = ''error'' THEN 1 ELSE 0 END) num_error,
                                SUM(CASE WHEN sev = ''warn'' THEN 1 ELSE 0 END) num_warn,
                                min(ts) as session_start_ts,
                                max(ts) as session_end_ts,
                                max(username) as username,
                                max(site) as sitename,
                                min(substring(v FROM ''.*named-connection name=''''(.*?)''''.*'')) AS data_connection_name
    		                FROM 
    		                    p_serverlogs
    		                WHERE 
                                1 = 1
                                and parent_vizql_session is null
    							and ts >= date''#v_load_date_txt#'' - interval''2 hours''
    							and ts <= date''#v_load_date_txt#'' + interval''26 hours''
    		                GROUP BY 
                                    parent_dataserver_session, 
                                    process_name
    		        ) slogs ON (datasrv_sess.dataserver_session = slogs.dataserver_session
                                AND datasrv_sess.process_name = slogs.process_name)
            left outer join h_sites sites on (sites.name = slogs.sitename 
                                            and slogs.session_start_ts between sites.p_valid_from and sites.p_valid_to)
            
            left outer join h_system_users su on (su.name = slogs.username
        						                 and slogs.session_start_ts between su.p_valid_from and su.p_valid_to
        						  				 )
            left outer join h_data_connections dc on (1 = 1
                                                    and dc.owner_type = ''Datasource''
                                                    and dc.name = slogs.data_connection_name
                                                    and slogs.session_start_ts between dc.p_valid_from and dc.p_valid_to)
            left outer join h_datasources ds on (1 = 1
                                                 and ds.id = dc.datasource_id                                            
                                                 and slogs.session_start_ts between ds.p_valid_from and ds.p_valid_to)
            left outer join h_projects p on (1 = 1
                                            and p.id = ds.project_id
                                            and slogs.session_start_ts between p.p_valid_from and p.p_valid_to)                                                 
		';
			
		v_sql := replace(v_sql, '#v_load_date_txt#', v_load_date_txt);		
		
		raise notice 'I: %', v_sql;
		execute v_sql;
		
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
		return v_num_inserted;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY INVOKER;