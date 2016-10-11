CREATE TABLE h_monitoring_postgresql
(
	p_id bigserial,
	p_filepath text,
	primary_ip character varying(255),
	secondary_ip character varying(255),
	updated_at timestamp without time zone,
	primary_port integer,
	secondary_port integer,
	updated_by character varying(255),
	pk integer,
	p_cre_date timestamp without time zone default now(),
	p_active_flag CHARACTER VARYING(1),
	p_valid_from timestamp without time zone,
	p_valid_to timestamp without time zone
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


