CREATE OR REPLACE FUNCTION handle_utc_midnight_interactor_sess(p_schema_name text)
RETURNS bigint AS
$BODY$
declare
	v_sql text;
	v_num_inserted bigint;	
	v_from text;
	v_to text;
	v_sql_cur text;
BEGIN	

		execute 'set local search_path = ' || p_schema_name;
	
		v_sql_cur := 'select to_char(coalesce(min(session_start_ts)::date, date''1001-01-01''), ''yyyy-mm-dd'') from s_interactor_session';	
		execute v_sql_cur into v_from;
		v_from := 'date''' || v_from || '''';		
				
		v_sql_cur := 'select 
							to_char(coalesce(max(session_start_ts), date''1001-01-01''), ''yyyy-mm-dd hh24:mi:ss.ms'')
					  from
					  		s_interactor_session';
					
		execute v_sql_cur into v_to;
		v_to := 'timestamp''' || v_to || '''';
        
       
		-- Eliminate dupplications because of utc midnight (update then delete)
		v_sql := 
		'update p_interactor_session t
		set 
			session_start_ts = s.session_start_ts,
		 	session_end_ts = s.session_end_ts,
			session_duration = extract(''epoch'' from (s.session_end_ts - s.session_start_ts)),
			cpu_time_consumption_seconds = s.cpu_time_consumption_seconds
		from
			(select
				parent_vizql_session,
				process_name,
				min(session_start_ts) as session_start_ts,
				max(session_end_ts) as session_end_ts,
				sum(cpu_time_consumption_seconds) as cpu_time_consumption_seconds
			from
				p_cpu_usage
			where
				ts_rounded_15_secs >= #v_from# - interval ''2 day'' and
				ts_rounded_15_secs <= #v_to#
			group by
				parent_vizql_session,
				process_name
			) s
		where
			t.session_start_ts >= #v_from# - interval ''2 day'' and
			t.session_start_ts <= #v_to# and
			t.vizql_session = s.parent_vizql_session and
			t.process_name = s.process_name
		';
		
		v_sql := replace(v_sql, '#v_from#', v_from);
		v_sql := replace(v_sql, '#v_to#', v_to);
		
		raise notice 'I: %', v_sql;
		execute v_sql;
		
		v_sql := 
		'delete from p_interactor_session t
		 using (select 
					vizql_session, 
					process_name,
					min(p_id) as p_id,
					count(1) as cnt
				from
					p_interactor_session
			    where
					session_start_ts >= #v_from# - interval ''2 day'' and
					session_start_ts <= #v_to#
			    group by
			  		vizql_session, process_name
				having count(1) = 2
			  ) s
		where
			session_start_ts >= #v_from# - interval ''2 day'' and
			session_start_ts <= #v_to# and
			t.p_id = s.p_id
		'
		;
		
		v_sql := replace(v_sql, '#v_from#', v_from);
		v_sql := replace(v_sql, '#v_to#', v_to);
		
		raise notice 'I: %', v_sql;
		execute v_sql;
												
		return v_num_inserted;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY INVOKER;