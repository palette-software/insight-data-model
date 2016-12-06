\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

alter table p_desktop_session add column datasource_name TEXT default null;
alter table p_desktop_session add column publisher_id BIGINT default null;
alter table p_desktop_session add column publisher_friendly_name_id TEXT default null;
alter table p_desktop_session add column publisher_user_name_id TEXT default null;

alter table s_desktop_session add column datasource_name TEXT default null;
alter table s_desktop_session add column publisher_id BIGINT default null;
alter table s_desktop_session add column publisher_friendly_name_id TEXT default null;
alter table s_desktop_session add column publisher_user_name_id TEXT default null;

\i 001-up-load_s_desktop_session.sql

insert into db_version_meta(version_number) values ('v1.16.0');

COMMIT;
