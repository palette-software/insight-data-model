\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-manage_multi_range_partitions.sql
\i 002-up-manage_single_range_partitions.sql

insert into db_version_meta(version_number) values ('v1.18.1');

COMMIT;
