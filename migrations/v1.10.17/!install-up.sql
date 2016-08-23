\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-refill_p_serverlogs_bootstrap_rpt.sql
\i 002-up-refill_p_cpu_usage_agg_report.sql
\i 003-up-refill_p_cpu_usage_bootstrap_report.sql
\i 004-up-refill_p_interactor_session.sql
\i 005-up-refill_p_process_class_agg_report.sql

CREATE INDEX p_serverlogs_bootstrap_rpt_parent_vizql_session_idx
		ON palette.p_serverlogs_bootstrap_rpt
		USING btree (parent_vizql_session);
CREATE INDEX p_cpu_usage_bootstrap_rpt_parent_vizql_session_idx
		ON palette.p_cpu_usage_bootstrap_rpt
		USING btree (cpu_usage_parent_vizql_session);


drop function load_p_serverlogs_bootstrap_rpt(p_schema_name text);
drop function load_p_cpu_usage_agg_report(p_schema_name text);


insert into db_version_meta(version_number) values ('v1.10.17');

COMMIT;