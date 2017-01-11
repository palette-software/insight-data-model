CREATE TABLE serverlogs
(
    p_id bigserial,
    p_filepath text,
    filename TEXT,
    host_name TEXT,
    ts timestamp without time zone,
    pid INTEGER,
    tid INTEGER,
    sev TEXT,
    req TEXT,
    sess TEXT,
    site TEXT,
    user TEXT,
    k TEXT,
    v TEXT,
    elapsed_ms INTEGER,
    start_ts timestamp without time zone,
    p_cre_date timestamp without time zone default now()
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
