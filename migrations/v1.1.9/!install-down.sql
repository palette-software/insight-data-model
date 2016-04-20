\set ON_ERROR_STOP on
set search_path = '#schema_name#';
insert into db_version_meta(version_number) values ('v1.1.8');

alter table threadinfo rename to threadinfo_old;

CREATE TABLE threadinfo
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
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);

alter sequence threadinfo_p_id_seq owned by threadinfo.p_id;

\i 001-down-manage_partitions.sql

insert into threadinfo select * from threadinfo_old;
drop table threadinfo_old;