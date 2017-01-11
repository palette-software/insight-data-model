CREATE TABLE h_schedules
(
    p_id bigserial,
    p_filepath text,
    id integer,
    name character varying(255),
    active boolean,
    priority integer,
    schedule_type integer,
    day_of_week_mask integer,
    day_of_month_mask integer,
    start_at_minute integer,
    minute_interval integer,
    end_at_minute integer,
    end_schedule_at timestamp without time zone,
    run_next_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    hidden boolean,
    serial_collection_id integer,
    lock_version integer,
    scheduled_action integer,
    luid character varying(166),
    p_cre_date timestamp without time zone default now(),
    p_active_flag CHARACTER VARYING(1),
    p_valid_from timestamp without time zone,
    p_valid_to timestamp without time zone
)
DISTRIBUTED BY (p_id);


