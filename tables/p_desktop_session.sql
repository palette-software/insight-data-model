CREATE TABLE p_desktop_session
(
	p_id bigserial,
	dataserver_session TEXT,
	process_name TEXT,
	host_name TEXT,
	cpu_time_consumption_seconds DOUBLE PRECISION,
	session_start_ts TIMESTAMP WITHOUT TIME ZONE,
	session_end_ts TIMESTAMP WITHOUT TIME ZONE,
	session_duration DOUBLE PRECISION,
    interactor_id BIGINT,    
	interactor_friendly_name_id TEXT,
	interactor_user_name_id TEXT,    
    publisher_id BIGINT,    
	publisher_friendly_name_id TEXT,
	publisher_user_name_id TEXT,
    site_id BIGINT,
	site_name_id TEXT,
    project_id BIGINT,
	project_name_id TEXT,
	num_fatals INTEGER,
	num_errors INTEGER,
	num_warnings INTEGER,
	user_type TEXT,    
    datasource_id int,
    datasource_name TEXT,    
    p_cre_date timestamp default now()
)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (dataserver_session)
PARTITION BY RANGE (session_start_ts)
(PARTITION "1001" 
	START (date '1001-01-01') INCLUSIVE
	END (date '1002-01-01') EXCLUSIVE 	
WITH (appendonly=true, orientation=column, compresstype=quicklz)	
);