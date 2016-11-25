CREATE TABLE h_core_licenses
(
	p_id bigserial,
	p_filepath text,
	machine_ip character varying(255),
	machine_cores integer,
	allocated_cores integer,
	update_ts timestamp without time zone,
	p_cre_date timestamp without time zone default now(),
	p_active_flag CHARACTER VARYING(1),
	p_valid_from timestamp without time zone,
	p_valid_to timestamp without time zone
)
DISTRIBUTED BY (p_id);


