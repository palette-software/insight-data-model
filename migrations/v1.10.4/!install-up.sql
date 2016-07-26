\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

alter table p_serverlogs add column session_duration double precision default 0;
alter table p_serverlogs add column session_elapsed_seconds double precision default 0;

alter table p_serverlogs_bootstrap_rpt rename column elapsed_seconds_to_bootstrap to session_elapsed_seconds;
alter table p_serverlogs_bootstrap_rpt add column session_duration double precision default 0;
alter table p_serverlogs_bootstrap_rpt ALTER COLUMN session_elapsed_seconds TYPE double precision;



drop view p_interactor_session_normal;
alter table p_interactor_session ALTER COLUMN session_duration TYPE double precision using extract('epoch' from session_duration);

\i 001-up-insert_p_serverlogs_from_s_serverlogs.sql
\i 002-up-p_interactor_session_normal.sql

grant select on p_interactor_session_normal to palette_palette_looker;

insert into db_version_meta(version_number) values ('v1.10.4');

COMMIT;
