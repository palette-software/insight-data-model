CREATE or replace function load_p_threadinfo(p_schema_name text, p_load_type text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;
BEGIN	

			if (upper(p_load_type) not in ('FULL', 'DELTA'))
			then
				raise EXCEPTION 'p_load_type has to be either FULL or DELTA';
			end if;
			
			
			v_sql := 
			'insert into #schema_name#.p_threadinfo
			(	
				threadinfo_id,
				host_name,
				process_name,
				ts,
				ts_date,
				ts_rounded_15_secs,
				process_id,
				thread_id,
				start_ts,
				cpu_time_ticks,
				cpu_time_delta_ticks,
				ts_interval_ticks,
				cpu_core_consumption,
				memory_usage_bytes,
				memory_usage_delta_bytes,
				is_thread_level
			)
			SELECT   
			   	  p_id as threadinfo_id,
			      host_name,
			      process,
			      ts,
				  ts::date,
				  poll_cycle_ts as ts_rounded_15_secs,	  
			      pid,
			      tid,
				  start_ts,
			      cpu_time,
			      cpu_time_delta,
			      ts_interval,
				  case when ts_interval::float = 0 then 0 else cpu_time_delta::float / ts_interval::float end 
				  		* (ts_interval::float / 150000000) as cpu_core_consumption,
				  working_set,
				  working_set_delta,
				  case when thread_level
				  	then ''Y'' 
				  else
				  		''N''
				  end as is_thread_level
			  from
			  (
			    SELECT       
			      p_id,
			      host_name,
			      process,
			      ts,
				  ts::date as ts_date,
			      pid,
			      tid,
				  start_ts,
			      cpu_time,
			      CASE 
				  	WHEN (lag_ts_int IS NULL OR start_ts_int > lag_ts_int) and tid <> -1 
						then cpu_time
			        WHEN cpu_time-lag_cpu_time>=0
			          THEN cpu_time-lag_cpu_time       
			        ELSE NULL -- looks like a new thread	
			      END cpu_time_delta,	  
			      CASE 
				    WHEN (lag_ts_int IS NULL OR start_ts_int > lag_ts_int) and tid <> -1 and (ts_int - start_ts_int) <= 160000000
						 -- new thread 
						 -- if lag_ts_int is null then we never see this pid and tid combination during the execution
						 -- if thread start ts is more recent than the previous records timestamp then it is also a new record
						 --
						 -- as a sanity check we make sure that this new interval is smaller than a standard 15secs
						 -- sampling interval
						 -- If it is ok, then simply take current measurement timestamp minus thread start timestamp
						THEN ts_int - start_ts_int			 
			        WHEN (lag_ts_int IS NULL OR (ts_int - lag_ts_int) > 160000000)
			           -- Thread / process with issues (most probably caused by agent restart or failure)
					   -- Simply omit the record and analyze later, exclude from reporting
			           THEN NULL
					   
					   
					WHEN cpu_time-lag_cpu_time>0 AND (ts_int-lag_ts_int) < (cpu_time-lag_cpu_time) AND tid <> -1
			          THEN NULL -- we have previous value but it''s bigger than the interval (like 20 secs consumption in 15 secs)
			                    -- NULL means we omit this record -- we should have some automation to catch them   		   
			        WHEN cpu_time-lag_cpu_time>=0 AND ts_int-lag_ts_int > 0
			           -- this looks a normal record
			           THEN ts_int-lag_ts_int 
					WHEN cpu_time-lag_cpu_time>=0 AND ts_int-lag_ts_int = 0
			           -- ts interval cannot be null, this might be some data duplication error
			           THEN NULL
			       ELSE NULL -- what else? I don''t know, but lets mark it as bad.
			      END ts_interval,	  	  
				  working_set,
				  case WHEN lag_working_set IS NULL 
				  	then working_set
				  else
				  	working_set - lag_working_set 
				  end as working_set_delta,
				  thread_level,
				  poll_cycle_ts
			    FROM
			    (
			      SELECT
			        p_id,
			        host_name,
			        process,
			        ts,
			        pid,
			        tid,
					start_ts,
			        cpu_time,
			        LAG(cpu_time) OVER 
			        (
			          PARTITION BY host_name,pid,process,tid,start_ts
			          ORDER BY ts ASC
			        ) lag_cpu_time,
			        (10000000*EXTRACT(EPOCH FROM ts))::bigint ts_int,
			        LAG((10000000*EXTRACT(EPOCH FROM ts))::bigint) OVER 
			        (
			          PARTITION BY host_name,pid,process,tid,start_ts
			          ORDER BY ts ASC
			        ) lag_ts_int,		
					working_set,
					LAG(working_set)  OVER 
			        (
			          PARTITION BY host_name,pid,process,tid,start_ts
			          ORDER BY ts ASC
			        ) as lag_working_set,			
					(10000000*EXTRACT(EPOCH FROM start_ts))::bigint start_ts_int,
					thread_level,
					poll_cycle_ts
			      FROM (select 
				  				p_id
							   , p_filepath
						       , host_name
						       , process
						       , ts
						       , pid
						       , tid
						       , cpu_time
						       , poll_cycle_ts
						       , start_ts
						       , thread_count
						       , working_set
						       , thread_level
						       , p_cre_date						       
				  		from
				  			#schema_name#.threadinfo curr_ti						
						#DELTA#	
						) ti	  
			      ) threadinfo
				  where
				  	p_id is not null
			) ext_threadinfo';
									
			
			if (upper(p_load_type) = 'FULL') then
				v_sql := replace(v_sql, '#DELTA#', '');
			else
				v_sql := replace(v_sql, '#DELTA#', 
							'where 
								p_id > coalesce((select max(a.threadinfo_id) from #schema_name#.p_threadinfo a), 0)
								
							union all
							
							SELECT  null as p_id
							       , null as p_filepath
							       , host_name
							       , process_name
							       , ts
							       , process_id
							       , thread_id
							       , cpu_time_ticks
							       , null as poll_cycle_ts
							       , start_ts
							       , null as thread_count
							       , memory_usage_bytes
							       , case when is_thread_level = ''Y'' then true else false end as is_thread_level
							       , null as p_cre_date			 
							from
								(
								select last_ti.*,
									   row_number() over (PARTITION BY host_name,process_id,process_name,thread_id,start_ts ORDER BY ts DESC) rn
								from
									#schema_name#.p_threadinfo last_ti
								where
									last_ti.ts_rounded_15_secs >= (select max(ts_date) max_date from #schema_name#.p_threadinfo) - 1
								) a 
							where rn = 1');														
			end if;
			
			v_sql := replace(v_sql, '#schema_name#', p_schema_name);			
			
			execute v_sql;
			
			GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
			
			return v_num_inserted;
END;
$$ LANGUAGE plpgsql;