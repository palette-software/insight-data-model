CREATE TABLE palette.threadinfo
(
	p_id BIGINT NOT NULL DEFAULT nextval('threadinfo_p_id_seq'::regclass),
	p_filepath CHARACTER VARYING(500),
	host_name TEXT,
	process TEXT,
	ts timestamp without time zone,
	pid BIGINT,
	tid BIGINT,
	cpu_time BIGINT,
	poll_cycle_ts timestamp without time zone,
	start_ts timestamp without time zone,
	thread_count INTEGER,
	working_set BIGINT,
	thread_level BOOLEAN,
	p_cre_date timestamp without time zone
)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (p_id)
PARTITION BY RANGE (ts)
SUBPARTITION BY LIST (host_name)
SUBPARTITION TEMPLATE (SUBPARTITION init VALUES ('init')
WITH (appendonly=true, orientation=column, compresstype=quicklz))
(PARTITION "10010101" START (date '1001-01-01') INCLUSIVE
        END (date '1001-01-02') EXCLUSIVE
WITH (appendonly=true, orientation=column, compresstype=quicklz)
);