CREATE TABLE p_interactor_session
(
	p_id bigserial,
	vizql_session TEXT,
	process_name TEXT,
	host_name TEXT,
	cpu_time_consumption_seconds DOUBLE PRECISION,
	session_start_ts TIMESTAMP WITHOUT TIME ZONE,
	session_end_ts TIMESTAMP WITHOUT TIME ZONE,
	session_duration DOUBLE PRECISION,
    publisher_id BIGINT,
	publisher_friendly_name_id TEXT,
	publisher_user_name_id TEXT,
    interactor_id BIGINT,
	interactor_friendly_name_id TEXT,
	interactor_user_name_id TEXT,
    site_id BIGINT,
	site_name_id TEXT,
    project_id BIGINT,
	project_name_id TEXT,
    workbook_id BIGINT,
	workbook_name_id TEXT,
	workbook_revision TEXT,
	http_user_agent TEXT,
	num_fatals INTEGER,
	num_errors INTEGER,
	num_warnings INTEGER,
	init_show_bootstrap_normal BOOLEAN,
	show_count integer,
	bootstrap_count integer,
	show_elapsed_secs double precision,
	bootstrap_elapsed_secs double precision,
	show_bootstrap_delay_secs double precision,
	user_type TEXT,
	currentsheet varchar(255),
	http_referer varchar(255),
	http_request_uri text,
	remote_ip varchar(255),
	user_ip varchar(255),
	user_cookie varchar(255),
	status integer,
	first_show_created_at timestamp without time zone,
    view_id int
)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (vizql_session)
PARTITION BY RANGE (session_start_ts)
(PARTITION "1001" 
	START (date '1001-01-01') INCLUSIVE
	END (date '1002-01-01') EXCLUSIVE 	
WITH (appendonly=true, orientation=column, compresstype=quicklz)	
);