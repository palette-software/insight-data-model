\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

alter table p_interactor_session add column currentsheet varchar(255) default null;
alter table p_interactor_session add column http_referer varchar(255) default null;
alter table p_interactor_session add column http_request_uri text default null;
alter table p_interactor_session add column remote_ip varchar(255) default null;
alter table p_interactor_session add column user_ip varchar(255) default null;
alter table p_interactor_session add column user_cookie varchar(255) default null;
alter table p_interactor_session add column status integer default null;
alter table p_interactor_session add column first_show_created_at timestamp without time zone default null;

alter table p_serverlogs_bootstrap_rpt add column currentsheet varchar(255) default null;
alter table p_cpu_usage_bootstrap_rpt add column currentsheet varchar(255) default null;

\i 001-up-load_p_interactor_session.sql
\i 002-up-create_load_p_cpu_usage_bootstrap_rpt.sql
\i 003-up-load_p_serverlogs_bootstrap_rpt.sql

select create_load_p_cpu_usage_bootstrap_rpt('#schema_name#');

insert into db_version_meta(version_number) values ('v1.10.9');

COMMIT;