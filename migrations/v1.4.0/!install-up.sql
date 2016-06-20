\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

\i 001-up-alter_p_serverlogs.sql
\i 002-up-insert_p_serverlogs_from_s_serverlogs.sql
\i 003-up-alter_s_http_requests_with_workbooks.sql
\i 004-up-load_s_http_requests_with_workbooks.sql
\i 005-up-alter_s_cpu_usage.sql
\i 006-up-load_s_cpu_usage_dataserver.sql
\i 007-up-load_s_cpu_usage_rest.sql
\i 008-up-load_s_cpu_usage_tabproto.sql
\i 009-up-load_s_cpu_usage_vizql.sql
\i 010-up-alter_p_cpu_usage.sql
\i 011-up-alter_p_cpu_usage_report.sql
\i 012-up-alter_p_interactor_session.sql
\i 013-up-load_p_interactor_session.sql
\i 014-up-recreate_p_serverlogs_report.sql

select create_load_s_cpu_usage_report('palette');

insert into db_version_meta(version_number) values ('v1.4.0');
