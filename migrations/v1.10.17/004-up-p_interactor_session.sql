CREATE TABLE p_interactor_session
(
	vizql_session TEXT,
	process_name TEXT,
	host_name TEXT,
	cpu_time_consumption_seconds DOUBLE PRECISION,
	session_start_ts timestamp without time zone,
	session_end_ts timestamp without time zone,
	session_duration DOUBLE PRECISION,
	publisher_friendly_name_id TEXT,
	publisher_user_name_id TEXT,
	interactor_friendly_name_id TEXT,
	interactor_user_name_id TEXT,
	site_name_id TEXT,
	project_name_id TEXT,
	workbook_name_id TEXT,
	workbook_revision TEXT,
	http_user_agent TEXT,
	num_fatals INTEGER,
	num_errors INTEGER,
	num_warnings INTEGER,
	init_show_bootstrap_normal BOOLEAN,
	show_count INTEGER,
	bootstrap_count INTEGER,
	show_elapsed_secs DOUBLE PRECISION,
	bootstrap_elapsed_secs DOUBLE PRECISION,
	show_bootstrap_delay_secs DOUBLE PRECISION,
	user_type TEXT,
	p_id BIGINT NOT NULL DEFAULT nextval('p_interactor_session_p_id_seq'::regclass),
	currentsheet CHARACTER VARYING(255),
	http_referer CHARACTER VARYING(255),
	http_request_uri TEXT,
	remote_ip CHARACTER VARYING(255),
	user_ip CHARACTER VARYING(255),
	user_cookie CHARACTER VARYING(255),
	status INTEGER,
	first_show_created_at timestamp without time zone
)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (p_id)
PARTITION BY RANGE (session_start_ts)
(PARTITION "1001" 
	START (date '1001-01-01') INCLUSIVE
	END (date '1002-01-01') EXCLUSIVE 	
WITH (appendonly=true, orientation=column, compresstype=quicklz)	
);