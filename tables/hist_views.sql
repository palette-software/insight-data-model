CREATE TABLE hist_views
(
	p_id bigserial,
	p_filepath text,
	id INTEGER,
	view_id INTEGER,
	name TEXT,
	repository_url TEXT,
	revision TEXT,
	p_cre_date timestamp without time zone default now()
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


