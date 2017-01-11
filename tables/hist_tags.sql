CREATE TABLE hist_tags
(
    p_id bigserial,
    p_filepath text,
    id INTEGER,
    tag_id INTEGER,
    name TEXT,
    p_cre_date timestamp without time zone default now()
)
    WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


