create table p_high_load_threads
(
	p_id bigserial,
    tho_p_id bigint,
	threadinfo_id bigint,
	host_name varchar(255),
	process_name varchar(255),
	ts timestamp,
	ts_rounded_15_secs timestamp,
	ts_date date,
	process_id bigint,
	thread_id bigint,
	start_ts timestamp,
	cpu_time_ticks bigint,
	cpu_time_delta_ticks bigint,
	ts_interval_ticks bigint,
	cpu_core_consumption float,
	memory_usage_bytes bigint,
	memory_usage_delta_bytes bigint,
	is_thread_level varchar(1),
	p_cre_date timestamp default now(),
	write_operation_count bigint,
	other_operation_count bigint,
	read_operation_count bigint,
	read_transfer_count bigint,
	write_transfer_count bigint,
	other_transfer_count bigint,
	read_operation_count_delta bigint,
	write_operation_count_delta bigint,
	other_operation_count_delta bigint,
	read_transfer_count_delta bigint,
	write_transfer_count_delta bigint,
	other_transfer_count_delta bigint
)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (host_name, process_id, thread_id)
PARTITION BY RANGE (ts_rounded_15_secs)
SUBPARTITION BY LIST (host_name)
SUBPARTITION TEMPLATE (SUBPARTITION init VALUES ('init')
    WITH (appendonly=true, orientation=column, compresstype=quicklz))
(PARTITION "10010101" START (date '1001-01-01') INCLUSIVE
    END (date '1001-01-02') EXCLUSIVE
    WITH (appendonly=true, orientation=column, compresstype=quicklz)
);
