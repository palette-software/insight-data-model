CREATE TABLE h_system_users
(
	p_id bigserial,
	p_filepath text,
	id integer,
	name character varying(255),
	email character varying(255),
	hashed_password character varying(255),
	salt character varying(255),
	sys boolean,
	keychain text,
	domain_id integer,
	friendly_name character varying(255),
	custom_display_name boolean,
	activation_code character varying(255),
	activated_at timestamp without time zone,
	state character varying(255),
	admin_level integer,
	created_at timestamp without time zone,
	updated_at timestamp without time zone,
	deleted_at timestamp without time zone,
	auth_user_id character varying(255),
	asset_key_id integer,
	lock_version integer,
	p_cre_date timestamp without time zone default now(),
	p_active_flag CHARACTER VARYING(1),
	p_valid_from timestamp without time zone,
	p_valid_to timestamp without time zone
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


