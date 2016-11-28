CREATE OR REPLACE FUNCTION insert_p_serverlogs_from_s_serverlogs(p_schema_name text, p_load_date date)
RETURNS bigint AS
$BODY$
declare
	v_sql text;
    v_sql_exec text;
	v_num_inserted bigint := 0;
    v_num_inserted_all bigint := 0;
    v_load_date_txt text := to_char(p_load_date, 'yyyy-mm-dd');
begin							
		
	execute 'set local search_path = ' || p_schema_name;
    
    v_sql := 'insert into p_serverlogs
            (
		        serverlogs_id
		       , p_filepath
		       , filename
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
		       , p_cre_date
		       , parent_vizql_site
		       , parent_vizql_username
		       , parent_dataserver_site
		       , parent_dataserver_username
		       , process_name
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
                  s.serverlogs_id
                , s.p_filepath
                , s.filename
                , s.host_name
                , s.ts
                , s.process_id
                , s.thread_id
                , s.sev
                , s.req 
                , s.sess
                , s.site
                , s.username
                , s.username_without_domain
                , s.k
                , s.v
                , s.parent_vizql_session
                , s.parent_vizql_destroy_sess_ts
                , s.parent_dataserver_session
                , s.spawned_by_parent_ts
                , s.parent_process_type
                , s.p_cre_date
                , s.parent_vizql_site
                , s.parent_vizql_username
                , s.parent_dataserver_site
                , s.parent_dataserver_username
                , s.process_name
                , s.thread_name
                , s.elapsed_ms
                , s.start_ts
                , s.session_start_ts_utc
                , s.session_end_ts_utc
                , s.site_id
                , s.site_name_id
                , s.project_id
                , s.project_name_id
                , s.workbook_id
                , s.workbook_name_id
                , s.workbook_rev
                , s.publisher_id
                , s.publisher_username_id
                , s.user_type
                , s.session_duration
                , s.session_elapsed_seconds
                , s.v_truncated
            from
                s_serverlogs_plus_2_hours s
            #filters#
            ';
            
    -- Load the whole day without the cross utc sessions and 
    -- without the cross utc sessions fragments from the previous day
    v_sql_exec := replace(v_sql, '#filters#',
                            ' 
                            -- plainlogs and serverlogs table have different sequences that is why we need the process_name too
                            left outer join (select
                                                process_name,
                                                serverlogs_id
                                            from
                                                p_serverlogs
                                            where 1 = 1
                                                and ts >= date''#v_load_date_txt#''
                                                and ts <= date''#v_load_date_txt#'' + interval''2 hours''
                                            ) ps on (ps.process_name = s.process_name and ps.serverlogs_id = s.serverlogs_id)
                            where 1 = 1
                                and s.ts >= date''#v_load_date_txt#''
                                and s.ts < date''#v_load_date_txt#'' + interval ''1 day''
                                and coalesce(s.parent_vizql_session, ''?'') not in (select distinct session from cross_utc_midnight_sessions where parent_process_name = ''vizqlserver'')
                                and coalesce(s.parent_dataserver_session, ''?'') not in (select distinct session from cross_utc_midnight_sessions where parent_process_name = ''dataserver'')                                    
                                and ps.serverlogs_id is null
                                ');
    
    v_sql_exec := replace(v_sql_exec, '#v_load_date_txt#', v_load_date_txt);    
	raise notice 'I: %', v_sql_exec;
    
	execute v_sql_exec;
    GET DIAGNOSTICS v_num_inserted = ROW_COUNT;            
    v_num_inserted_all := v_num_inserted_all + v_num_inserted;
        
     -- Load only the cross utc sessions
    v_sql_exec := replace(v_sql, '#filters#',
                            ' where 1 = 1
                                    and s.ts >= date''#v_load_date_txt#'' + interval ''24 hours''
                                    and s.ts <= date''#v_load_date_txt#'' + interval ''26 hours''
                                    and (s.parent_vizql_session in (select distinct session from cross_utc_midnight_sessions where parent_process_name = ''vizqlserver'')
                                        or
                                        s.parent_dataserver_session in (select distinct session from cross_utc_midnight_sessions where parent_process_name = ''dataserver''))
                            '
    );
    v_sql_exec := replace(v_sql_exec, '#v_load_date_txt#', v_load_date_txt);    
	raise notice 'I: %', v_sql_exec;
	execute v_sql_exec;				               
    GET DIAGNOSTICS v_num_inserted = ROW_COUNT;            
    v_num_inserted_all := v_num_inserted_all + v_num_inserted;
            
    
	return v_num_inserted_all;
	
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY INVOKER;