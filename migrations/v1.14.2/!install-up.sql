\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

grant select on p_desktop_session to palette_palette_looker;

insert into db_version_meta(version_number) values ('v1.14.2');

COMMIT;