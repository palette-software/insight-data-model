CREATE TABLE h_projects
(
    p_id bigserial,
    p_filepath text,
    id integer,
    name character varying(255),
    owner_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    state character varying(32),
    description text,
    site_id integer,
    special integer,
    luid character varying(166),
    controlled_permissions_enabled boolean,
    p_cre_date timestamp without time zone default now(),
    p_active_flag CHARACTER VARYING(1),
    p_valid_from timestamp without time zone,
    p_valid_to timestamp without time zone
)
DISTRIBUTED BY (p_id);


