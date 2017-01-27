CREATE TABLE hist_data_connections
(
    p_id bigserial,
    p_filepath text,
    id INTEGER,
    data_connection_id INTEGER,
    server TEXT,
    name TEXT,
    dbname TEXT,
    table_name TEXT,
    p_cre_date timestamp without time zone default now()
)
    WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


