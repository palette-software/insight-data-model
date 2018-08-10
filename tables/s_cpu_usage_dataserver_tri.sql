CREATE TABLE s_cpu_usage_dataserver_tri WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ) AS 
select
    p_id
   ,threadinfo_id
   ,host_name
   ,process_name
   ,ts
   ,ts_rounded_15_secs
   ,process_id
   ,thread_id
   ,cpu_time_ticks
   ,cpu_time_delta_ticks
   ,ts_interval_ticks
   ,cpu_core_consumption
   ,memory_usage_delta_bytes
   ,memory_usage_bytes
   ,cast(null as text) as process_level
   ,is_thread_level
   ,cast(null as boolean) as max_reporting_granularity
   ,start_ts                                   
from
    p_threadinfo_delta
where 1 = 2
DISTRIBUTED BY (p_id)
;