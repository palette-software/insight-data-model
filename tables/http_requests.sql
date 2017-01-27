CREATE TABLE http_requests
(
    p_id bigserial,
    p_filepath text,
    id integer,
    controller character varying(255),
    action character varying(255),
    http_referer character varying(255),
    http_user_agent character varying(255),
    http_request_uri text,
    remote_ip character varying(255),
    created_at timestamp without time zone,
    session_id character varying(255),
    completed_at timestamp without time zone,
    port integer,
    user_id integer,
    worker character varying(255),
    status integer,
    user_cookie character varying(255),
    user_ip character varying(255),
    vizql_session text,
    site_id integer,
    currentsheet character varying(255),
    p_cre_date timestamp without time zone default now()
)
    WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


