CREATE TABLE hist_sites
(
	p_id bigserial,
	p_filepath text,
	id INTEGER,
	site_id INTEGER,
	name TEXT,
	url_namespace TEXT,
	p_cre_date timestamp without time zone default now()
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


