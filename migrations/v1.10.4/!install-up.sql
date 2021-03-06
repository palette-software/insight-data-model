\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

alter table p_serverlogs add column session_duration double precision default 0;
alter table p_serverlogs add column session_elapsed_seconds double precision default 0;

alter table p_serverlogs_bootstrap_rpt rename column elapsed_seconds_to_bootstrap to session_elapsed_seconds;
alter table p_serverlogs_bootstrap_rpt add column session_duration double precision default 0;
alter table p_serverlogs_bootstrap_rpt ALTER COLUMN session_elapsed_seconds TYPE double precision;

alter table p_cpu_usage_bootstrap_rpt rename column elapsed_seconds_to_bootstrap to session_elapsed_seconds;
alter table p_cpu_usage_bootstrap_rpt ALTER COLUMN session_elapsed_seconds TYPE double precision;
alter table p_cpu_usage_bootstrap_rpt ALTER column session_duration TYPE double precision using extract('epoch' from session_duration);

alter table p_cpu_usage rename column start_ts to session_start_ts;
alter table p_cpu_usage rename column end_ts to session_end_ts;
alter table p_cpu_usage add column session_duration double precision default 0;

alter table s_cpu_usage rename column start_ts to session_start_ts;
alter table s_cpu_usage rename column end_ts to session_end_ts;
alter table s_cpu_usage add column session_duration double precision default 0;

drop view p_interactor_session_normal;
alter table p_interactor_session ALTER COLUMN session_duration TYPE double precision using extract('epoch' from session_duration);
alter table p_cpu_usage_report ALTER COLUMN session_duration TYPE double precision using extract('epoch' from session_duration);
alter table s_cpu_usage_report ALTER COLUMN session_duration TYPE double precision using extract('epoch' from session_duration);

\i 001-up-insert_p_serverlogs_from_s_serverlogs.sql
\i 002-up-p_interactor_session_normal.sql
\i 003-up-load_s_cpu_usage_dataserver.sql
\i 004-up-load_s_cpu_usage_rest.sql
\i 005-up-load_s_cpu_usage_tabproto.sql
\i 006-up-load_s_cpu_usage_tdeserver.sql
\i 007-up-load_s_cpu_usage_vizql.sql
\i 008-up-load_p_interactor_session.sql
\i 009-up-create_load_p_cpu_usage_bootstrap_rpt.sql
\i 010-up-create_load_s_cpu_usage_report.sql
\i 011-up-create_p_serverlogs_bootstrap_rpt.sql
\i 012-up-load_p_interactor_session.sql
\i 013-up-load_p_serverlogs_bootstrap_rpt.sql
select create_load_s_cpu_usage_report('#schema_name#');
select create_load_p_cpu_usage_bootstrap_rpt('#schema_name#');

grant select on p_interactor_session_normal to palette_palette_looker;

insert into db_version_meta(version_number) values ('v1.10.4');

COMMIT;
