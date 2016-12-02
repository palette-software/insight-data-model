\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

drop view p_workbooks;
drop view p_datasources;

\i 001-up-create_create_view_p_workbooks.sql
select create_view_p_workbooks('#schema_name#');
\i 002-up-create_create_view_p_datasources.sql
select create_view_p_datasources('#schema_name#');

grant select on p_workbooks to palette_palette_looker;
grant select on p_datasources to palette_palette_looker;

insert into db_version_meta(version_number) values ('v1.13.0');

COMMIT;