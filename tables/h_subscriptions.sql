CREATE TABLE h_subscriptions
(
	p_id bigserial,
	p_filepath text,
	id integer,
	subject character varying(256),
	user_id integer,
	schedule_id integer,
	last_sent timestamp without time zone,
	site_id integer,
	luid CHARACTER VARYING(166),
	creator_id integer,
	data_condition_type character varying(255),
	p_cre_date timestamp without time zone default now(),
	p_active_flag CHARACTER VARYING(1),
	p_valid_from timestamp without time zone,
	p_valid_to timestamp without time zone
)
DISTRIBUTED BY (p_id);


