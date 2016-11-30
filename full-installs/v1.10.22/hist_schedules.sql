CREATE TABLE hist_schedules
(
	p_id bigserial,
	p_filepath text,
	id integer,
	schedule_id integer,
	name text,
	schedule_type integer,
	priority integer,
	scheduled_action integer,
	is_serial boolean,
	day_of_week_mask integer,
	day_of_month_mask integer,
	start_at_minute integer,
	minute_interval integer,
	end_at_minute integer,
	end_schedule_at timestamp without time zone,
	p_cre_date timestamp without time zone default now()
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


