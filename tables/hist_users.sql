CREATE TABLE hist_users
(
	p_id bigserial,
	p_filepath text,
	id INTEGER,
	user_id INTEGER,
	name TEXT,
	domain_name TEXT,
	email TEXT,
	system_user_id INTEGER,
	system_admin_level INTEGER,
	hist_licensing_role_id INTEGER,
	site_admin_level INTEGER,
	publisher_tristate INTEGER,
	p_cre_date timestamp without time zone default now()
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


