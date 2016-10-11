CREATE TABLE background_jobs
(
	p_id bigserial,
	p_filepath CHARACTER VARYING(500),
	id iinteger,
	job_type ccharacter varying(255),
	progress iinteger,
	args text,
	notes text,
	updated_at timestamp without time zone,
	created_at timestamp without time zone,
	completed_at timestamp without time zone,
	started_at timestamp without time zone,
	job_name character varying(255),
	finish_code iinteger,
	priority integer,
	title character varying(255),
	created_on_worker character varying(255),
	processed_on_worker character varying(255),
	link ext,
	lock_version integer,
	backgrounder_id character varying(255),
	serial_collection_id integer,
	site_id integer,
	subtitle character varying(255),
	language character varying(255),
	locale character varying(255),
	correlation_id integer,
	attempts_remaining integer,
	p_cre_date timestamp without time zone default now()
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);