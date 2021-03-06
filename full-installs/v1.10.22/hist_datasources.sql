CREATE TABLE hist_datasources
(
	p_id bigserial,
	p_filepath text,
	id INTEGER,
	datasource_id INTEGER,
	name TEXT,
	repository_url TEXT,
	size BIGINT,
	revision TEXT,
	p_cre_date timestamp without time zone default  now()
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


