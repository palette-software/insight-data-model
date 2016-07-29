\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

CREATE INDEX p_cpu_usage_bootstrap_rpt_parent_vizql_session_idx ON p_cpu_usage_bootstrap_rpt (cpu_usage_parent_vizql_session);
CREATE INDEX p_serverlogs_bootstrap_rpt_parent_vizql_session_idx ON p_serverlogs_bootstrap_rpt (parent_vizql_session);

insert into db_version_meta(version_number) values ('v1.10.6');

COMMIT;