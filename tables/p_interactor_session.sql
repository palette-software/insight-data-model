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
	show_count integer,
	bootstrap_count integer,
	show_elapsed_secs double,
	bootstrap_elapsed_secs double,
	show_bootstrap_delay_secs double,
	user_type TEXT
)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (vizql_session);
