CREATE TABLE hist_licensing_roles
(
    p_id bigserial,
    p_filepath text,
    id INTEGER,
    licensing_role_id INTEGER,
    name TEXT,
    p_cre_date timestamp without time zone default now()
)
    WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


