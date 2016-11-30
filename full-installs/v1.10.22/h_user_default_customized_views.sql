CREATE TABLE h_user_default_customized_views
(
	p_id bigserial,
	p_filepath text,
	id integer,
	user_id integer,
	view_id integer,
	customized_view_id integer,
	created_at timestamp without time zone,
	updated_at timestamp without time zone,
	p_cre_date timestamp without time zone default now(),
	p_active_flag CHARACTER VARYING(1),
	p_valid_from timestamp without time zone,
	p_valid_to timestamp without time zone
)
DISTRIBUTED BY (p_id);


