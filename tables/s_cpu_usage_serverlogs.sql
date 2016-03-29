create table s_cpu_usage_serverlogs
(
	  host_name text,
	  pid bigint,
	  tid bigint,
	  session text,
	  ts_cluster bigint,
	  session_start_ts timestamp,  
	  session_end_ts timestamp,
	  duration interval,
	  site text,
	  username text,
	  ts_destroy_sess timestamp
)
WITH (appendonly=true, orientation=column, compresstype=quicklz)
DISTRIBUTED BY (host_name, pid, tid);