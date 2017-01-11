CREATE TABLE t_tde_filename_pids (
    p_id bigserial,
    host_name text,
    file_prefix text,
    pid bigint,
    ts_from timestamp without time zone,
    ts_to timestamp without time zone,
    p_cre_date timestamp default now()
    )
DISTRIBUTED BY 
    (host_name,
    file_prefix,
    ts_from)
;
