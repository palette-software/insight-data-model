\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

alter table p_serverlogs add column v_truncated varchar(300) default null;
alter table p_serverlogs_bootstrap_rpt add column v_truncated varchar(300) default null;
alter table s_serverlogs_bootstrap_rpt add column v_truncated varchar(300) default null;

\i 001-up-insert_p_serverlogs_from_s_serverlogs.sql
\i 002-up-load_s_serverlogs_bootstrap_rpt.sql

drop view p_serverlogs_report;
\i 003-up-p_serverlogs_report.sql

grant select on p_serverlogs_report to palette_palette_looker;

update p_serverlogs set v_truncated = substr(v, 1, 300);
update p_serverlogs_bootstrap_rpt set v_truncated = substr(v, 1, 300);

insert into db_version_meta(version_number) values ('v1.10.26');

COMMIT;