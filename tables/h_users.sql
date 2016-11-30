CREATE TABLE h_users
(
	p_id bigserial,
	p_filepath text,
	id integer,
	login_at timestamp without time zone,
	licensing_role_id integer,
	nonce character varying(32),
	row_limit integer,
	storage_limit integer,
	created_at timestamp without time zone,
	extracts_required boolean,
	updated_at timestamp without time zone,
	admin_level integer,
	publisher_tristate integer,
	raw_data_suppressor_tristate integer,
	site_id integer,
	system_user_id integer,
	system_admin_auto boolean,
	luid CHARACTER VARYING(166),
	lock_version integer,
	p_cre_date timestamp without time zone default now(),
	p_active_flag CHARACTER VARYING(1),
	p_valid_from timestamp without time zone,
	p_valid_to timestamp without time zone
)
DISTRIBUTED BY (p_id);


