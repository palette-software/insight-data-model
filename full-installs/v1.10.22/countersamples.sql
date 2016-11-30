CREATE TABLE countersamples
(
	p_id bigserial,
	p_filepath CHARACTER VARYING(500),
	timestamp timestamp without time zone,
	machine TEXT,
	category TEXT,
	instance TEXT,
	name TEXT,
	value DOUBLE PRECISION,
	p_cre_date timestamp without time zone default now()
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);