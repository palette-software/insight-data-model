CREATE TABLE h_extracts
(
	p_id bigserial,
	p_filepath text,
	id integer,
	workbook_id integer,
	descriptor character varying(255),
	created_at timestamp without time zone,
	updated_at timestamp without time zone,
	datasource_id integer,
	p_cre_date timestamp without time zone default now(),
	p_active_flag CHARACTER VARYING(1),
	p_valid_from timestamp without time zone,
	p_valid_to timestamp without time zone
)
DISTRIBUTED BY (p_id);


