create table p_cpu_usage_hourly
(
    p_id bigserial
   ,host_name text
   ,hour timestamp without time zone
   ,process_name text
   ,parent_vizql_session text
   ,cpu_time_consumption_seconds double precision
   ,session_start_ts timestamp without time zone
   ,session_end_ts timestamp without time zone
   ,session_duration double precision
   ,publisher_id bigint
   ,publisher_friendly_name_id text
   ,publisher_user_name_id text
   ,interactor_id bigint
   ,interactor_friendly_name_id text
   ,interactor_user_name_id text
   ,site_id bigint
   ,site_name_id text
   ,project_id bigint
   ,project_name_id text
   ,workbook_id bigint
   ,workbook_name_id text
   ,process_category text
   ,p_cre_date timestamp without time zone default now()
)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (p_id)
PARTITION BY RANGE (hour)
(PARTITION "100101" START (date '1001-01-01') INCLUSIVE
    END (date '1001-02-01') EXCLUSIVE
WITH (appendonly=true, orientation=column, compresstype=quicklz)
);
