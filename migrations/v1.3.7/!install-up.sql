\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;


insert into db_version_meta(version_number) values ('v1.3.7');
