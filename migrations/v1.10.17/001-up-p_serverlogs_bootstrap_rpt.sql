CREATE TABLE palette.p_serverlogs_bootstrap_rpt
(
	p_id BIGINT NOT NULL DEFAULT nextval('p_serverlogs_bootstrap_rpt_p_id_seq1'::regclass),
	p_serverlogs_p_id BIGINT,
	serverlogs_id BIGINT,
	p_filepath CHARACTER VARYING(500),
	filename TEXT,
	process_name TEXT,
	host_name TEXT,
	ts timestamp without time zone,
	process_id BIGINT,
	thread_id BIGINT,
	sev TEXT,
	req TEXT,
	sess TEXT,
	site TEXT,
	username TEXT,
	username_without_domain TEXT,
	k TEXT,
	v TEXT,
	parent_vizql_session CHARACTER VARYING(100),
	parent_vizql_destroy_sess_ts timestamp without time zone,
	parent_dataserver_session TEXT,
	spawned_by_parent_ts timestamp without time zone,
	parent_process_type TEXT,
	parent_vizql_site TEXT,
	parent_vizql_username TEXT,
	parent_dataserver_site TEXT,
	parent_dataserver_username TEXT,
	p_serverlogs_p_cre_date timestamp without time zone,
	thread_name TEXT,
	elapsed_ms BIGINT,
	start_ts timestamp without time zone,
	session_start_ts_utc timestamp without time zone,
	session_end_ts_utc timestamp without time zone,
	site_name_id TEXT,
	project_name_id TEXT,
	workbook_name_id TEXT,
	workbook_rev TEXT,
	publisher_username_id TEXT,
	user_type TEXT,
	session_duration DOUBLE PRECISION,
	session_elapsed_seconds DOUBLE PRECISION,
	p_cre_date timestamp without time zone DEFAULT now(),
	currentsheet CHARACTER VARYING(255)
)
	WITH (appendonly=true, orientation=column, compresstype=quicklz)
DISTRIBUTED BY (p_id)
PARTITION BY RANGE (start_ts)
(PARTITION "10010101" 
	START (date '1001-01-01') INCLUSIVE
	END (date '1001-01-02') EXCLUSIVE 	
WITH (appendonly=true, orientation=column, compresstype=quicklz)	
);