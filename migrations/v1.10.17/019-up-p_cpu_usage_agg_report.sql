CREATE TABLE p_cpu_usage_agg_report
(
	p_id bigserial,	
	cpu_usage_host_name TEXT,
	cpu_usage_process_name TEXT,
	timestamp_utc timestamp without time zone,
	workbook_name text,
	interactor_s_user_id INTEGER,
	interactor_s_user_name text,
	interactor_s_user_name_id TEXT,
	interactor_s_user_friendly_name text,
	interactor_s_user_friendly_name_id TEXT,
	interactor_s_user_email text,
	publisher_s_user_email text,
	publisher_s_user_id INTEGER,
	publisher_s_user_name text,
	publisher_s_user_friendly_name text,
	publisher_s_user_name_id TEXT,
	publisher_s_user_friendly_name_id TEXT,
	publisher_user_site_id INTEGER,
	workbook_id INTEGER,
	workbook_name_id TEXT,
	workbook_revision text,
	workbook_name_id_revision TEXT,
	site_name text,
	site_id INTEGER,
	project_name text,
	project_id INTEGER,
	project_name_id TEXT,
	site_name_id TEXT,
	site_project TEXT,
	cpu_usage_cpu_time_consumption_seconds DOUBLE PRECISION,
	cpu_usage_cpu_time_consumption_minutes DOUBLE PRECISION,
	cpu_usage_cpu_time_consumption_hours DOUBLE PRECISION,
	vizql_session_count int,
	p_cre_date timestamp without time zone default now()
)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (p_id)
PARTITION BY RANGE (timestamp_utc)
(PARTITION "1001" 
	START (date '1001-01-01') INCLUSIVE
	END (date '1002-01-01') EXCLUSIVE 	
WITH (appendonly=true, orientation=column, compresstype=quicklz)	
);