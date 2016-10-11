CREATE TABLE h_sites
(
	p_id bigserial,
	p_filepath text,
	id integer,
	name character varying(255),
	url_namespace character varying(255),
	status character varying(255),
	created_at timestamp without time zone,
	updated_at timestamp without time zone,
	user_quota integer,
	content_admin_mode integer,
	storage_quota bigint,
	metrics_level smallint,
	status_reason character varying(255),
	subscriptions_enabled boolean,
	custom_subscription_footer text,
	custom_subscription_email text,
	luid CHARACTER VARYING(166),
	query_limit integer,
	authoring_disabled boolean,
	sheet_image_enabled boolean,
	livedb_connections_whitelist_enabled boolean,
	refresh_token_setting integer,
	version_history_enabled boolean,
	notification_enabled boolean,
	content_version_limit integer,
	subscribe_others_enabled boolean,
	lock_version integer,
	p_cre_date timestamp without time zone default now(),
	p_active_flag CHARACTER VARYING(1),
	p_valid_from timestamp without time zone,
	p_valid_to timestamp without time zone
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


