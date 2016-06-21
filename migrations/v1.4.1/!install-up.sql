\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

\i 001-up-create_index_p_serverlogs_p_id_idx.sql

insert into db_version_meta(version_number) values ('v1.4.1');
