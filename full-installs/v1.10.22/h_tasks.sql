CREATE TABLE h_tasks
(
	p_id bigserial,
	p_filepath text,
	id integer,
	schedule_id integer,
	type character varying(255),
	priority integer,
	obj_id integer,
	created_at timestamp without time zone,
	updated_at timestamp without time zone,
	site_id integer,
	obj_type character varying(255),
	luid character varying(166),
	consecutive_failure_count integer,
	active boolean,
	p_cre_date timestamp without time zone default now(),
	p_active_flag CHARACTER VARYING(1),
	p_valid_from timestamp without time zone,
	p_valid_to timestamp without time zone
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


