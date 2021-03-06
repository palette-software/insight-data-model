CREATE or replace function load_s_serverlogs_vizql_compressed(p_schema_name text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;
	v_max_ts_date_p_cpu_usage text;
	v_sql_cur text;
	
begin
			v_sql_cur := 'select to_char((select #schema_name#.get_max_ts_date(''#schema_name#'',''p_cpu_usage'')), ''yyyy-mm-dd'')';		
			v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);
		
			execute v_sql_cur into v_max_ts_date_p_cpu_usage;
			v_max_ts_date_p_cpu_usage := 'date''' || v_max_ts_date_p_cpu_usage || '''';

			v_sql := 
			'insert into #schema_name#.s_serverlogs_compressed (
				  process_name,
				  host_name,
				  process_id,
				  thread_id,	  
				  session,
				  ts_cluster,
				  session_start_ts,  
				  session_end_ts,
				  duration,
				  site,
				  username,
				  ts_destroy_sess,
				  parent_vizql_session,
				  whole_session_start_ts,
				  whole_session_end_ts,
				  whole_session_duration				  
			)

			with t_slogs as
			(
			select 
					host_name,
					site,
					username_without_domain,
					process_id,
					thread_id,
					sess,
					ts,					
					lag(sess) over (partition by host_name, process_id, thread_id order by ts) as lag_sess,
					ts_destroy_sess,
					parent_vizql_session,
					session_start_ts_utc,
					session_end_ts_utc
			from
				(select 	
					host_name,
					site,
					username_without_domain,
					process_id,
					thread_id,
					sess,
					ts,					
					row_number() over (partition by host_name,
													process_id,
													thread_id,																
													ts
										order by 
												case when sess not in (''-'', ''default'') then 1 else 0 end 
												desc, sess desc, site desc) as rn,
					ts_destroy_sess,
					parent_vizql_session,
					session_start_ts_utc,
					session_end_ts_utc
				from
						(select distinct 
									host_name,
									site,
									username_without_domain,
									process_id,
									thread_id,
									sess,
									ts,
									parent_vizql_destroy_sess_ts as ts_destroy_sess,
									parent_vizql_session,
									session_start_ts_utc,
									session_end_ts_utc
						from
								#schema_name#.p_serverlogs
						where
							 substr(filename, 1, 11) = ''vizqlserver'' and
							 ts >= #v_max_ts_date_p_cpu_usage# - interval''60 minutes''				 				 
						 ) slogs
				) a
			where
				 rn = 1
			)
				  
			select	
					''vizqlserver'' as process_name,
					host_name,		
					process_id,
					thread_id,
					sess,					
					ts_claster,
					min(ts) as session_start_ts,
					max(ts) as session_end_ts,
					max(ts) - min(ts) as duration,
					site,
					username_without_domain,
					ts_destroy_sess,
					parent_vizql_session,
					--todo: this whole_session name is missleading
					whole_session_start_ts,
					whole_session_end_ts,
					whole_session_end_ts - whole_session_start_ts as whole_session_duration
			from
			(
				select
						host_name,
						site,
						username_without_domain,
						process_id,
						thread_id,
						sess,
						ts,						
						ts_claster,
						ts_destroy_sess,
						session_start_ts_utc as whole_session_start_ts,
						session_end_ts_utc as whole_session_end_ts,
						parent_vizql_session
				from
					(
					select 
							host_name,
							site,
							username_without_domain,
							process_id,
							thread_id,
							sess,
							ts,							
							sum(case when sess = lag_sess
									then 
										0
									else 
										1
								end	
								) over (PARTITION BY host_name, process_id, thread_id, sess order by ts ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as ts_claster,
							ts_destroy_sess,
							parent_vizql_session,
							session_start_ts_utc,
							session_end_ts_utc
					from
						t_slogs
					) a	
				) g
			group by
					host_name,
					site,
					username_without_domain,
					process_id,
					thread_id,
					sess,
					ts_claster,
					ts_destroy_sess,
					whole_session_start_ts,
					whole_session_end_ts,
					parent_vizql_session
			';
		
		v_sql := replace(v_sql, '#schema_name#', p_schema_name);
		v_sql := replace(v_sql, '#v_max_ts_date_p_cpu_usage#', v_max_ts_date_p_cpu_usage);
		
		raise notice 'I: %', v_sql;

		execute v_sql;		
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;			
		return v_num_inserted;
END;
$$ LANGUAGE plpgsql;