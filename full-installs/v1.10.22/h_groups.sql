CREATE TABLE h_groups
(
	p_id bigserial,
	p_filepath text,
	id integer,
	name character varying(255),
	created_at timestamp without time zone,
	updated_at timestamp without time zone,
	system boolean,
	owner_id integer,
	domain_id integer,
	site_id integer,
	luid character varying(166),
	minimum_site_role character varying(255),
	last_synchronized timestamp without time zone,
	p_cre_date timestamp without time zone default now(),
	p_active_flag CHARACTER VARYING(1),
	p_valid_from timestamp without time zone,
	p_valid_to timestamp without time zone
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


