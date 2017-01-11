CREATE TABLE historical_event_types
(
    p_id bigserial,
    p_filepath text,
    type_id INTEGER,
    name TEXT,
    action_type TEXT,
    p_cre_date timestamp without time zone default now()
)
    WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


