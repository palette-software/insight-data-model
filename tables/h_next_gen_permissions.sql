CREATE TABLE h_next_gen_permissions
(
    p_id bigserial,
    p_filepath text,
    id integer,
    authorizable_type character varying(64),
    authorizable_id integer,
    grantee_id integer,
    grantee_type character varying(255),
    capability_id integer,
    permission integer,
    p_cre_date timestamp without time zone default now(),
    p_active_flag CHARACTER VARYING(1),
    p_valid_from timestamp without time zone,
    p_valid_to timestamp without time zone
)
DISTRIBUTED BY (p_id);


