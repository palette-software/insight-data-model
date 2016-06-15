\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

\i 001-up-create_load_s_cpu_usage_report.sql

insert into db_version_meta(version_number) values ('v1.3.4');
