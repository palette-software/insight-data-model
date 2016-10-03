\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

alter table p_serverlogs add column publisher_id int default null;
alter table p_serverlogs add column site_id int default null;
alter table p_serverlogs add column project_id int default null;
alter table p_serverlogs add column workbook_id int default null;

alter table p_serverlogs_bootstrap_rpt add column publisher_id int default null;
alter table p_serverlogs_bootstrap_rpt add column site_id int default null;
alter table p_serverlogs_bootstrap_rpt add column project_id int default null;
alter table p_serverlogs_bootstrap_rpt add column workbook_id int default null;

alter table s_serverlogs_bootstrap_rpt add column publisher_id int default null;
alter table s_serverlogs_bootstrap_rpt add column site_id int default null;
alter table s_serverlogs_bootstrap_rpt add column project_id int default null;
alter table s_serverlogs_bootstrap_rpt add column workbook_id int default null;


\i 001-up-insert_p_serverlogs_from_s_serverlogs.sql
\i 002-up-load_s_serverlogs_bootstrap_rpt.sql

insert into db_version_meta(version_number) values ('v1.10.24');

COMMIT;