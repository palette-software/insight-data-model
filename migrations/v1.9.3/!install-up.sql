\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-create-p_tdeserver_parent_vizsession_proctype_coverage.sql


grant select on p_tdeserver_parent_vizsession_proctype_coverage to palette_palette_looker;

insert into db_version_meta(version_number) values ('v1.9.3');

COMMIT;
