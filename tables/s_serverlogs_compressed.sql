create table s_serverlogs_compressed
(
      process_name text,
      host_name text,
      process_id bigint,
      thread_id bigint,
      session text,
      ts_cluster bigint,
      session_start_ts timestamp,  
      session_end_ts timestamp,
      duration interval,
      site text,
      username text,
      ts_destroy_sess timestamp,      
      parent_vizql_session text,
      parent_vizql_destroy_sess_ts timestamp without time zone,
      parent_dataserver_session text,
      spawned_by_parent_ts timestamp without time zone,
      parent_process_type text,
      parent_vizql_site text,
      parent_vizql_username text,
      parent_dataserver_site text,
      parent_dataserver_username text,
      whole_session_start_ts timestamp,
      whole_session_end_ts timestamp,
      whole_session_duration interval,
      p_cre_date timestamp without time zone default now()
)
WITH (appendonly=true, orientation=column, compresstype=quicklz)
DISTRIBUTED BY (host_name, process_id, thread_id);
