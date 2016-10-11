CREATE TABLE hist_capabilities
(
	p_id bigserial,
	p_filepath text,
	id integer,
	capability_id integer,
	name text,
	allow boolean,
	p_cre_date timestamp without time zone default now()
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


