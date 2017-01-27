CREATE TABLE hist_groups
(
    p_id bigserial,
    p_filepath text,
    id INTEGER,
    group_id INTEGER,
    name TEXT,
    domain_name TEXT,
    p_cre_date timestamp without time zone default now()
)
    WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


