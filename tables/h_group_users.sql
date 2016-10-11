CREATE TABLE h_group_users
(
	p_id bigserial,
	p_filepath text,
	id integer,
	group_id integer,
	user_id integer,
	p_cre_date timestamp without time zone default now(),
	p_active_flag CHARACTER VARYING(1),
	p_valid_from timestamp without time zone,
	p_valid_to timestamp without time zone
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


