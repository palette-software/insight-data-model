CREATE TABLE h_customized_views
(
    p_id bigserial,
    p_filepath TEXT,
    id INTEGER,
    name CHARACTER VARYING(255),
    description TEXT,
    view_id INTEGER,
    repository_url CHARACTER VARYING(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_id INTEGER,
    public BOOLEAN,
    size INTEGER,
    site_id INTEGER,
    repository_data_id BIGINT,
    repository_thumbnail_data_id BIGINT,
    url_id CHARACTER VARYING(255),
    start_view_id INTEGER,
    luid CHARACTER VARYING(166),
    p_cre_date timestamp without time zone DEFAULT now(),
    p_active_flag CHARACTER VARYING(1),
    p_valid_from timestamp without time zone,
    p_valid_to timestamp without time zone
)
DISTRIBUTED BY (p_id);
