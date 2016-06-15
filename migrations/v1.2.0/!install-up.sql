\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

alter table p_interactor_session_agg_cpu_usage rename to p_interactor_session;
drop function load_p_interactor_session_agg_cpu_usage(text);
\i 001-up-load_p_interactor_session.sql
\i 002-up-get_max_ts.sql
\i 003-up-get_max_ts_date.sql

drop index palette.p_serverlogs_process_name_serverlogs_id_idx;
drop index palette.serverlogs_p_id_idx;
drop function load_p_serverlogs_datasrv_tabproto(text);

\i 004-up-create_load_p_background_jobs.sql
\i 005-up-create_load_s_cpu_usage_report.sql
\i 006-up-delete_recent_records_from_p_serverlogs.sql
\i 007-up-insert_p_serverlogs_from_s_serverlogs.sql
\i 008-up-is_subpart_template_same.sql
\i 009-up-load_s_serverlogs_dataserver.sql
\i 010-up-load_s_serverlogs_rest.sql
\i 011-up-load_s_serverlogs_tabproto.sql
\i 012-up-load_s_serverlogs_tdeserver.sql
\i 013-up-load_s_serverlogs_vizql.sql


insert into db_version_meta(version_number) values ('v1.2.0');
