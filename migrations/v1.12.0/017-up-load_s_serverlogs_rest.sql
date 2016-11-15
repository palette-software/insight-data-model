CREATE or replace function load_s_serverlogs_rest(p_schema_name text, p_load_date date) returns bigint
AS $$
declare
	v_sql text;	
	v_num_inserted bigint;
    v_load_date_txt text := to_char(p_load_date, 'yyyy-mm-dd');
begin				

    execute 'set local search_path = ' || p_schema_name;
    
    perform check_if_load_date_already_in_table(p_schema_name, 'p_serverlogs', p_load_date, true);
    
	v_sql := 
	'insert into s_serverlogs (
			serverlogs_id,
			p_filepath,
			filename,
			process_name,
			host_name,
			ts,
			process_id,
			thread_id,
			sev,
			req,
			sess,
			site,
			username,
			username_without_domain,
			k,
			v,					
			parent_vizql_session,
			parent_vizql_destroy_sess_ts,
			parent_dataserver_session,
			spawned_by_parent_ts,
			parent_process_type,
			parent_vizql_site,
			parent_vizql_username,
			parent_dataserver_site,
			parent_dataserver_username,
			elapsed_ms,
			start_ts
	)			
	
	select 
			p_id,
			sl.p_filepath,
			sl.filename,
			replace(case when position(''_'' in sl.filename) > 0 then substr(sl.filename, 1, position(''_'' in sl.filename) -1) else sl.filename end, ''.txt'', '''') as process_name,
			sl.host_name,
			sl.ts,
			sl.pid,
			sl.tid,
			sl.sev,
			sl.req,
			sl.sess,
			sl.site,
			sl.user,
			substr(sl.user, position(''\\\\'' in sl.user) + 1) as username_without_domain,
			sl.k,
			sl.v,
			null as parent_vizql_session,
			null as parent_vizql_destroy_sess_ts,
			null as parent_dataserver_session,
			null as spawned_by_parent_ts,
			null as parent_process_type,
			null as parent_vizql_site,
			null as parent_vizql_username,
			null as parent_dataserver_site,
			null as parent_dataserver_username,
			sl.elapsed_ms,
			sl.start_ts			
	from
			serverlogs sl
	where
		substr(sl.filename, 1, 11) <> ''tabprotosrv'' and
		substr(sl.filename, 1, 10) <> ''dataserver'' and
		substr(sl.filename, 1, 11) <> ''vizqlserver'' and
		sl.ts >= date''#v_load_date_txt#'' and
		sl.ts < date''#v_load_date_txt#'' + interval''1 day''
	';				
		
	v_sql := replace(v_sql, '#v_load_date_txt#', v_load_date_txt);
	
	raise notice 'I: %', v_sql;

	execute v_sql;		
	GET DIAGNOSTICS v_num_inserted = ROW_COUNT;			

	return v_num_inserted;
END;
$$ LANGUAGE plpgsql;