CREATE TABLE p_serverlogs
(
	p_id bigserial,
	serverlogs_id bigint,	
	p_filepath CHARACTER VARYING(500),
	filename TEXT,
	process_name TEXT,
	host_name TEXT,
	ts timestamp without time zone,
	process_id bigint,
	thread_id bigint,	
	sev TEXT,
	req TEXT,
	sess TEXT, 
	site TEXT,
	username TEXT,
	username_without_domain TEXT,
	k TEXT,
	v TEXT,
	parent_vizql_session varchar(100),
	parent_vizql_destroy_sess_ts timestamp without time zone,
	parent_dataserver_session text,
	spawned_by_parent_ts timestamp without time zone,
	parent_process_type text,
	parent_vizql_site text,
	parent_vizql_username text,
	parent_dataserver_site text,
	parent_dataserver_username text,	
	p_cre_date timestamp without time zone default now(),
	thread_name text,
	elapsed_ms bigint,
	start_ts timestamp without time zone,
	session_start_ts_utc timestamp without time zone,
    session_end_ts_utc timestamp without time zone,
   	site_name_id text,
    project_name_id text,
    workbook_name_id text,
    workbook_rev text,
    publisher_username_id text,
    user_type text
)
DISTRIBUTED BY (host_name, process_id, thread_id)
PARTITION BY RANGE (ts)
SUBPARTITION BY LIST (host_name)
SUBPARTITION TEMPLATE (SUBPARTITION init VALUES ('init')
WITH (appendonly=true, orientation=column, compresstype=quicklz))
(PARTITION "10010101" START (date '1001-01-01') INCLUSIVE
	END (date '1001-01-02') EXCLUSIVE 
WITH (appendonly=true, orientation=column, compresstype=quicklz)
);

create index p_serverlogs_parent_vizql_session_idx on p_serverlogs(parent_vizql_session);
  