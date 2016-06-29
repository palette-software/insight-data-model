\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

grant select on p_process_class_agg_report to palette_palette_looker;

insert into db_version_meta(version_number) values ('v1.5.2');