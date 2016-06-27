\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

\i 001-up-p_process_class_agg_report.sql
\i 002-up-load_p_process_class_agg_report.sql

insert into db_version_meta(version_number) values ('v1.4.7');
