\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;


alter sequence p_background_jobs_p_id_seq cache 500;
alter sequence p_cpu_usage_bootstrap_rpt_p_id_seq cache 500;
alter sequence p_cpu_usage_p_id_seq cache 500;
alter sequence p_cpu_usage_report_p_id_seq cache 500;
alter sequence p_desktop_session_p_id_seq cache 500;
alter sequence p_http_requests_p_id_seq cache 500;
alter sequence p_interactor_session_p_id_seq cache 500;
alter sequence p_serverlogs_bootstrap_rpt_p_id_seq cache 500;
alter sequence p_serverlogs_p_id_seq cache 500;
alter sequence s_serverlogs_p_id_seq cache 500;
alter sequence p_process_class_agg_report_p_id_seq cache 500;
alter sequence p_threadinfo_delta_p_id_seq cache 500;
alter sequence threadinfo_p_id_seq cache 500;
alter sequence serverlogs_p_id_seq cache 500;
alter sequence async_jobs_p_id_seq cache 500;
alter sequence background_jobs_p_id_seq cache 500;
alter sequence countersamples_p_id_seq cache 500;
alter sequence cross_utc_midnight_sessions_id_seq cache 500;
alter sequence http_requests_p_id_seq cache 500;
alter sequence p_high_load_threads_p_id_seq cache 500;
alter sequence p_threadinfo_p_id_seq cache 500;
alter sequence plainlogs_p_id_seq cache 500;


\i 001-up-load_s_cpu_usage_tdeserver.sql

alter table s_background_jobs_hourly add column wd_type character varying(255) default null;
alter table p_background_jobs_hourly add column wd_type character varying(255) default null;

\i 002-up-load_s_background_jobs_hourly.sql

insert into db_version_meta(version_number) values ('v1.19.4');

COMMIT;