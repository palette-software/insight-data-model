CREATE or replace function load_s_serverlogs_vizql_compressed(p_schema_name text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;
	v_max_ts_date text;
	v_sql_cur text;
	
begin
			v_sql_cur := 'select to_char(coalesce((select max(ts_date) from #schema_name#.p_cpu_usage), date''1001-01-01''), ''yyyy-mm-dd'')';
			v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);
		
			execute v_sql_cur into v_max_ts_date;
			v_max_ts_date := 'date''' || v_max_ts_date || '''';

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
				  ts_destroy_sess				  
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
					ts_destroy_sess
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
					ts_destroy_sess
				from
						(select distinct 
									host_name,
									site,
									username_without_domain,
									process_id,
									thread_id,
									sess,
									ts,
									max(case when k = ''destroy-session'' then ts end) over (partition by host_name, sess) ts_destroy_sess
						from
								#schema_name#.p_serverlogs
						where
							 substr(filename, 1, 11) = ''vizqlserver'' and
							 ts >= #v_max_ts_date# - interval''60 minutes''				 				 
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
					ts_destroy_sess					
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
						ts_destroy_sess
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
							ts_destroy_sess							
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
					ts_destroy_sess
			';
		
		v_sql := replace(v_sql, '#schema_name#', p_schema_name);
		v_sql := replace(v_sql, '#v_max_ts_date#', v_max_ts_date);
		
		raise notice 'I: %', v_sql;

		execute v_sql;		
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;			
		return v_num_inserted;
END;
$$ LANGUAGE plpgsql;