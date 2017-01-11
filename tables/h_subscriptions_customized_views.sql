CREATE TABLE h_subscriptions_customized_views
(
    p_id bigserial,
    p_filepath text,
    id integer,
    subscription_id integer,
    customized_view_id integer,
    p_cre_date timestamp without time zone default now(),
    p_active_flag CHARACTER VARYING(1),
    p_valid_from timestamp without time zone,
    p_valid_to timestamp without time zone
)
DISTRIBUTED BY (p_id);


