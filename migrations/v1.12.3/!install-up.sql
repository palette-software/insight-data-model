\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;


\i 001-up-get_max_ts.sql
\i 002-up-manage_partitions.sql
\i 003-up-manage_single_range_partitions.sql

drop table p_http_requests;
\i 004-up-create_p_http_requests.sql
select create_p_http_requests('#schema_name#');
\i 005-up-create_load_p_http_requests.sql
select create_load_p_http_requests('#schema_name#');

drop function load_s_http_requests_with_workbooks(text);
\i 006-up-load_s_http_requests_with_workbooks.sql
\i 007-up-load_s_interactor_session.sql
\i 008-up-load_s_serverlogs_plus_2_hours.sql

------------------

drop table p_background_jobs;
\i 009-up-create_p_background_jobs.sql
select create_p_background_jobs('#schema_name#');

\i 010-up-create_load_p_background_jobs.sql
select create_load_p_background_jobs('#schema_name#');

insert into db_version_meta(version_number) values ('v1.12.3');

COMMIT;