CREATE TABLE h_capabilities
(
    p_id bigserial,
    p_filepath text,
    id integer,
    name character varying(80),
    display_name character varying(255),
    display_order integer,
    p_cre_date timestamp without time zone default now(),
    p_active_flag CHARACTER VARYING(1),
    p_valid_from timestamp without time zone,
    p_valid_to timestamp without time zone
)
DISTRIBUTED BY (p_id);


