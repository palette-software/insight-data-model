create table p_background_jobs_hourly
(
    p_id bigserial
   ,hour timestamp without time zone
   ,time_consumption_seconds double precision
   ,started_at timestamp without time zone
   ,completed_at timestamp without time zone
   ,publisher_id bigint
   ,publisher_friendly_name_id text
   ,publisher_user_name_id text
   ,site_id bigint
   ,site_name text
   ,site_name_id text
   ,project_id bigint
   ,project_name text
   ,project_name_id text
   ,workbook_datasource_id bigint
   ,workbook_datasource_name text
   ,workbook_datasource_name_id text
   ,p_cre_date timestamp without time zone default now()
)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (p_id)
PARTITION BY RANGE (hour)
(PARTITION "100101" START (date '1001-01-01') INCLUSIVE
    END (date '1001-02-01') EXCLUSIVE
WITH (appendonly=true, orientation=column, compresstype=quicklz)
);