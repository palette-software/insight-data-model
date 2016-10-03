\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

alter table p_http_requests add column view_id int default null;

alter table p_serverlogs_bootstrap_rpt add column view_id int default null;
alter table p_cpu_usage_bootstrap_rpt add column view_id int default null;
alter table p_interactor_session add column view_id int default null;

alter table s_serverlogs_bootstrap_rpt add column view_id int default null;
alter table s_cpu_usage_bootstrap_rpt add column view_id int default null;
alter table s_interactor_session add column view_id int default null;

\i 001-up-create_load_p_http_requests.sql
select create_load_p_http_requests('#schema_name#');
\i 002-up-load_s_interactor_session.sql
\i 003-up-load_s_serverlogs_bootstrap_rpt.sql
\i 004-up-create_load_s_cpu_usage_bootstrap_rpt.sql
select create_load_s_cpu_usage_bootstrap_rpt('#schema_name#');

insert into db_version_meta(version_number) values ('v1.10.25');

COMMIT;