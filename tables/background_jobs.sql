CREATE TABLE background_jobs
(
	p_id bigserial,
	p_filepath CHARACTER VARYING(500),
	id nteger,
	job_type haracter varying(255),
	progress nteger,
	args ext,
	notes ext,
	updated_at imestamp without time zone,
	created_at imestamp without time zone,
	completed_at imestamp without time zone,
	started_at imestamp without time zone,
	job_name haracter varying(255),
	finish_code nteger,
	priority nteger,
	title haracter varying(255),
	created_on_worker haracter varying(255),
	processed_on_worker haracter varying(255),
	link ext,
	lock_version nteger,
	backgrounder_id haracter varying(255),
	serial_collection_id nteger,
	site_id nteger,
	subtitle haracter varying(255),
	language haracter varying(255),
	locale haracter varying(255),
	correlation_id nteger,
	attempts_remaining nteger,
	p_cre_date timestamp without time zone default now()
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);