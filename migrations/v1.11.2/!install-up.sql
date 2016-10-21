\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-create_create_view_p_datasources.sql

drop view p_datasources;
select create_view_p_datasources('#schema_name#');
grant select on p_datasources to palette_palette_looker;

insert into db_version_meta(version_number) values ('v1.11.2');

COMMIT;