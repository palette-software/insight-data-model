CREATE TABLE s_serverlogs_tabproto
(
	spawner_process_type text,
	spawner_session text,
	spawned_tabproto_process_id_ts timestamp without time zone,
	spawner_ts_destroy_sess timestamp without time zone,
	start_ts timestamp without time zone,
	p_id bigint,	
	filename TEXT,
	host_name TEXT,
	ts timestamp without time zone,
	process_id INTEGER,
	thread_id INTEGER,
	sev TEXT,
	req TEXT,
	sess TEXT,
	site TEXT,
	username TEXT,
	k TEXT,
	v TEXT,	
	p_cre_date timestamp without time zone default now()
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);