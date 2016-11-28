\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

alter table p_background_jobs add column project_id int default null;
alter table p_background_jobs add column publisher_id int default null;
alter table p_background_jobs add column p_cre_date timestamp default now();

drop function load_p_background_jobs(text);
\i create_load_p_background_jobs.sql
select create_load_p_background_jobs('#schema_name#');

insert into db_version_meta(version_number) values ('v1.12.4');

COMMIT;