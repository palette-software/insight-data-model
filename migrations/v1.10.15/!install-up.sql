\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

alter table p_interactor_session add column max_ts_rounded_15_secs timestamp without time zone default NULL;
update p_interactor_session set max_ts_rounded_15_secs = session_start_ts;
drop view p_interactor_session_normal;

\i 001-up-p_interactor_session_normal.sql

grant select on p_interactor_session_normal to palette_palette_looker;

insert into db_version_meta(version_number) values ('v1.10.15');

COMMIT;
