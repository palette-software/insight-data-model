CREATE TABLE hist_configs
(
	p_id bigserial,
	p_filepath text,
	id INTEGER,
	key TEXT,
	value TEXT,
	p_cre_date timestamp without time zone default now()
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


