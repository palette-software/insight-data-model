CREATE TABLE async_jobs
(
	p_id bigserial,
	p_filepath text,
	id	integer,
	job_type character varying(255),
	success boolean,
	worker character varying(255),
	user_id integer,
	site_id integer,
	notes text,
	progress integer,
	created_at timestamp without time zone,
	updated_at timestamp without time zone,
	completed_at timestamp without time zone,
	detailed_status text,
	luid character varying(166),
	p_cre_date timestamp without time zone default now()
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);