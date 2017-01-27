create table p_load_dates
(
    p_id bigserial,
    load_date date,
    p_cre_date timestamp without time zone default now()
)
WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);
