CREATE TABLE historical_events
(
    p_id bigserial,
    p_filepath text,
    id integer,
    historical_event_type_id integer,
    worker text,
    duration_in_ms integer,
    is_failure boolean,
    details text,
    created_at timestamp without time zone,
    hist_actor_user_id integer,
    hist_target_user_id integer,
    hist_actor_site_id integer,
    hist_target_site_id integer,
    hist_project_id integer,
    hist_workbook_id integer,
    hist_view_id integer,
    hist_datasource_id integer,
    hist_comment_id integer,
    hist_tag_id integer,
    hist_group_id integer,
    hist_licensing_role_id integer,
    hist_schedule_id integer,
    hist_task_id integer,
    hist_data_connection_id integer,
    hist_config_id integer,
    hist_capability_id integer,
    p_cre_date timestamp without time zone default now()
)
    WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


