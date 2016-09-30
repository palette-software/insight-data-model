\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

alter table p_interactor_session add column publisher_id int default null;
alter table p_interactor_session add column interactor_id int default null;
alter table p_interactor_session add column site_id int default null;
alter table p_interactor_session add column project_id int default null;
alter table p_interactor_session add column workbook_id int default null;

alter table s_interactor_session add column publisher_id int default null;
alter table s_interactor_session add column interactor_id int default null;
alter table s_interactor_session add column site_id int default null;
alter table s_interactor_session add column project_id int default null;
alter table s_interactor_session add column workbook_id int default null;


\i 001-up-load_s_interactor_session.sql

insert into db_version_meta(version_number) values ('v1.10.23');

COMMIT;