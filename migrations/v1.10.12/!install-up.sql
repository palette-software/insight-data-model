\set ON_ERROR_STOP on
set search_path = '#schema_name#';

\i 001-up-handle_privileges.sql

select handle_privileges('#schema_name#');

insert into db_version_meta(version_number) values ('v1.10.12');
