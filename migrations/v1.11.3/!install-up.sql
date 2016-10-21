\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

create role readonly_capacity with login password 'onlyreadcap';
ALTER ROLE readonly_capacity RESOURCE QUEUE reporting;
alter role readonly_capacity set random_page_cost=20;
alter role readonly_capacity set optimizer=on;

grant usage on schema #schema_name# to readonly_capacity;
grant select on p_threadinfo_delta to readonly_capacity;
grant select on p_process_class_agg_report to readonly_capacity;


insert into db_version_meta(version_number) values ('v1.11.3');

COMMIT;