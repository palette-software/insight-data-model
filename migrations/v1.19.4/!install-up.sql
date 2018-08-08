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


\i 001-up-load_s_cpu_usage_tdeserver.sql


insert into db_version_meta(version_number) values ('v1.19.4');

COMMIT;