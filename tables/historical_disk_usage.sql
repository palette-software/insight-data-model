CREATE TABLE historical_disk_usage
(
    p_id bigserial,
    p_filepath text,
    id INTEGER,
    worker_id CHARACTER VARYING(255),
    resource_type INTEGER,
    path CHARACTER VARYING(255),
    total_space_bytes BIGINT,
    used_space_bytes BIGINT,
    state INTEGER,
    record_timestamp timestamp without time zone,
    p_cre_date timestamp without time zone default now()
)
    WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


