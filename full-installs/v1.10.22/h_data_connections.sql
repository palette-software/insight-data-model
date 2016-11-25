CREATE TABLE h_data_connections
(
	p_id bigserial,
	p_filepath text,
	id integer,
	server text,
	dbclass character varying(128),
	port integer,
	username character varying(128),
	password boolean,
	name character varying(255),
	dbname character varying(255),
	tablename character varying(255),
	owner_type character varying(255),
	owner_id integer,
	created_at timestamp without time zone,
	updated_at timestamp without time zone,
	caption character varying(255),
	site_id integer,
	keychain text,
	luid character varying(166),
	has_extract boolean,
	datasource_id integer,
	db_subclass character varying(255),
	p_cre_date timestamp without time zone default now(),
	p_active_flag CHARACTER VARYING(1),
	p_valid_from timestamp without time zone,
	p_valid_to timestamp without time zone
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


