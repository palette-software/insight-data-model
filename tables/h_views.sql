CREATE TABLE h_views
(
	p_id bigserial,
	p_filepath text,
	id integer,
	name character varying(255),
	repository_url text,
	description text,
	created_at timestamp without time zone,
	locked boolean,
	published boolean,
	read_count integer,
	edit_count integer,
	datasource_id integer,
	workbook_id integer,
	index integer,
	updated_at timestamp without time zone,
	owner_id integer,
	fields text,
	title text,
	caption text,
	sheet_id character varying(255),
	state character varying(32),
	sheettype character varying(255),
	site_id integer,
	repository_data_id bigint,
	first_published_at timestamp without time zone,
	revision character varying(255),
	for_cache_updated_at timestamp without time zone,
	luid CHARACTER VARYING(166),
	p_cre_date timestamp without time zone default now(),
	p_active_flag CHARACTER VARYING(1),
	p_valid_from timestamp without time zone,
	p_valid_to timestamp without time zone
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


