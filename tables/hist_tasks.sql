CREATE TABLE hist_tasks
(
    p_id bigserial,
    p_filepath text,
    id INTEGER,
    task_id INTEGER,
    type TEXT,
    priority INTEGER,
    p_cre_date timestamp without time zone default now()
)
    WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


