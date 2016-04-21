CREATE TABLE p_serverlogs
(
	p_id bigserial,
	p_filepath CHARACTER VARYING(500),
	filename TEXT,
	host_name TEXT,
	ts timestamp without time zone,
	pid bigint,
	tid bigint,
	sev TEXT,
	req TEXT,
	sess TEXT,
	site TEXT,
	user TEXT,
	k TEXT,
	v TEXT,
	parent_vizql_session text,
	parent_dataserver_session text,
	p_cre_date timestamp without time zone default now()
)
DISTRIBUTED BY (host_name, process_id, thread_id)
PARTITION BY RANGE (ts_rounded_15_secs)
SUBPARTITION BY LIST (host_name)
SUBPARTITION TEMPLATE (SUBPARTITION init VALUES ('init')
WITH (appendonly=true, orientation=column, compresstype=quicklz))
(PARTITION "10010101" START (date '1001-01-01') INCLUSIVE
	END (date '1001-01-02') EXCLUSIVE 
WITH (appendonly=true, orientation=column, compresstype=quicklz)
);