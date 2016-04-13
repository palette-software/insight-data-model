CREATE or replace function load_s_serverlogs_tabproto_compressed(p_schema_name text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;	
	v_sql_cur text;	
begin	
			
			v_sql := 
			'insert into #schema_name#.s_serverlogs_tabproto_compressed (
				  spawner_process_type,
				  host_name,
				  process_id,
				  thread_id,	  
				  session,
				  ts_cluster,
				  session_start_ts,  
				  session_end_ts,
				  duration,
				  site,
				  username
			)

			with t_slogs as
			(
			select 
					spawner_process_type,
					host_name,
					site,
					username,
					process_id,
					thread_id,
					sess,
					ts,					
					lag(sess) over (partition by spawner_process_type, host_name, process_id, thread_id order by ts) as lag_sess
			from
				(select
					spawner_process_type,
					host_name,
					site,
					username,
					process_id,
					thread_id,
					sess,
					ts,					
					row_number() over (partition by spawner_process_type,
													host_name,
													process_id,
													thread_id,																
													ts
										order by 
												case when sess not in (''-'', ''default'') then 1 else 0 end 
												desc, sess desc, site desc) as rn
				from
						(select distinct 
									spawner_process_type,
									host_name,
									site,
									username,
									process_id,
									-1 as thread_id,
									spawner_session as sess,
									ts
						from
								#schema_name#.s_serverlogs_tabproto						
						 ) slogs
				) a
			where
				 rn = 1
			)
				  
			select	
					spawner_process_type,
					host_name,		
					process_id,
					thread_id,
					sess,					
					ts_claster,
					min(ts) as session_start_ts,
					max(ts) as session_end_ts,
					max(ts) - min(ts) as duration,
					site,
					username
			from
			(
				select	
						spawner_process_type,
						host_name,
						site,
						username,
						process_id,
						thread_id,
						sess,
						ts,						
						ts_claster
				from
					(
					select 
							spawner_process_type,
							host_name,
							site,
							username,
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
								) over (PARTITION BY spawner_process_type, host_name, process_id, thread_id, sess order by ts ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as ts_claster
					from
						t_slogs
					) a	
				) g
			group by
					spawner_process_type,
					host_name,
					site,
					username,
					process_id,
					thread_id,
					sess,
					ts_claster
			';

		
		v_sql := replace(v_sql, '#schema_name#', p_schema_name);
				
		raise notice 'I: %', v_sql;

		execute v_sql;		
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;			
		return v_num_inserted;
END;
$$ LANGUAGE plpgsql;