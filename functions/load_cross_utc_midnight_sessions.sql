CREATE OR REPLACE FUNCTION load_cross_utc_midnight_sessions(p_schema_name text, p_load_date date)
RETURNS bigint AS
$BODY$
declare	
    v_num_inserted bigint := 0;    
begin							
		
	execute 'set local search_path = ' || p_schema_name;

    perform check_if_load_date_already_in_table(p_schema_name, 'p_serverlogs', p_load_date, true);

    -- Determine "cross utc midnight" sessions
    truncate table cross_utc_midnight_sessions;
    
    insert into cross_utc_midnight_sessions(
                                            parent_process_name,
                                            session
                                            )
        
    select 
        'vizqlserver' as parent_process_name,
        parent_vizql_session as session
    from 
        s_serverlogs
    where
        1 = 1
        and ts >= p_load_date
        and ts <= p_load_date + interval'26 hours'
        and parent_vizql_session is not null
        and parent_vizql_session not in ('-', 'default')
    group by         
        parent_vizql_session
    having 
        min(ts::date) <> max(ts::date)
        
    union all    
    
    select 
        'dataserver' as parent_process_name,
        parent_dataserver_session
    from 
        s_serverlogs
    where
        1 = 1
        and ts >= p_load_date
        and ts <= p_load_date + interval'26 hours'
        and parent_vizql_session is null        
        and parent_dataserver_session is not null
        and parent_dataserver_session not in ('-', 'default')
    group by         
        parent_dataserver_session
    having 
        min(ts::date) <> max(ts::date);
        
    analyze cross_utc_midnight_sessions;
                                
    GET DIAGNOSTICS v_num_inserted = ROW_COUNT; 
    
	return v_num_inserted;
	
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY INVOKER;