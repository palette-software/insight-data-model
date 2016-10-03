CREATE or replace function load_s_serverlogs_bootstrap_rpt(p_schema_name text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;
	v_from text;
	v_to text;
	v_sql_cur text;	
begin		

	execute 'set local search_path = ' || p_schema_name;
	
	v_sql_cur := '
	    select
		    to_char(coalesce(
			    max(ts),
				date''1001-01-01''), ''yyyy-mm-dd'')
		from p_serverlogs_bootstrap_rpt';
		
	raise notice 'I: %', v_sql_cur;
	execute v_sql_cur into v_from;
		
	v_sql_cur := 
		'select
			to_char(coalesce(min(slogs.ts), date''#v_from#'' + 1), ''yyyy-mm-dd hh24:mi:ss.ms'')
		from
			p_serverlogs slogs		
		left outer join p_interactor_session s on (
		                                    s.session_start_ts >= date''#v_from#'' and		                                    
		                                    s.vizql_session = slogs.parent_vizql_session and
		                                    s.process_name = ''vizqlserver'')
		where        
		 	slogs.parent_vizql_session is not null and
			slogs.parent_vizql_session not in (''Non-Interactor Vizql'', ''-'') and
		 	slogs.ts >= date''#v_from#'' + 1 and
			ts <= s.session_start_ts +
										(interval''1 second'' * coalesce(s.bootstrap_elapsed_secs, 0)) +
										(interval''1 second'' * coalesce(s.show_elapsed_secs,0)) +
										(interval''1 second'' * coalesce(s.show_bootstrap_delay_secs,0))										
								+ interval ''1 second''
		';
	
	v_sql_cur := replace(v_sql_cur, '#v_from#', v_from);	
	raise notice 'I: %', v_sql_cur;
	execute v_sql_cur into v_to;
			
	v_sql := 'insert into s_serverlogs_bootstrap_rpt
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
		   , currentsheet
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
		   , s.currentsheet
		from
		    p_serverlogs srvlog
		left outer join p_interactor_session s on (
		                                    s.session_start_ts >= date''#v_from#'' and
		                                    s.session_start_ts <= timestamp''#v_to#'' + interval''1 hour'' and
		                                    s.vizql_session = srvlog.parent_vizql_session and
		                                    s.process_name = ''vizqlserver'')
		where
			srvlog.ts >= date''#v_from#'' and	
			srvlog.ts <= timestamp''#v_to#'' and	
			parent_vizql_session is not null and
		    parent_vizql_session not in (''Non-Interactor Vizql'', ''-'')  and
		                      srvlog.ts <= s.session_start_ts +
												(interval''1 second'' * coalesce(s.bootstrap_elapsed_secs, 0)) +
												(interval''1 second'' * coalesce(s.show_elapsed_secs,0)) +
												(interval''1 second'' * coalesce(s.show_bootstrap_delay_secs,0))										
										+ interval ''1 second''
		';			
			
		v_sql := replace(v_sql, '#v_from#', v_from);
		v_sql := replace(v_sql, '#v_to#', v_to);		
		
		raise notice 'I: %', v_sql;
		execute v_sql;

		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
		return v_num_inserted;

END;
$$ LANGUAGE plpgsql;