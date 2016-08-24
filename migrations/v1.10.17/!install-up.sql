\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

--drop function create_p_serverlogs_bootstrap_rpt

\i 001-up-refill_p_serverlogs_bootstrap_rpt.sql
select ins_from_stage_to_dwh('#schema_name#','p_serverlogs_bootstrap_rpt');

\i 002-up-refill_p_cpu_usage_agg_report.sql
select ins_from_stage_to_dwh('#schema_name#','p_cpu_usage_agg_report');

alter table p_cpu_usage_bootstrap_rpt rename to p_cpu_usage_bootstrap_rpt_old;
\i 003-up-create_p_cpu_usage_bootstrap_report.sql
select create_p_cpu_usage_bootstrap_report('#schema_name#')
\i 003-up-s_cpu_usage_bootstrap_report.sql
insert into s_cpu_usage_bootstrap_rpt select * from p_cpu_usage_bootstrap_rpt_old;
select manage_partitions('palette', 'p_cpu_usage_bootstrap_rpt');
drop table p_cpu_usage_bootstrap_rpt_old;
select ins_from_stage_to_dwh('#schema_name#','p_cpu_usage_bootstrap_rpt');

\i 004-up-refill_p_interactor_session.sql
select ins_from_stage_to_dwh('#schema_name#','p_interactor_session');

\i 005-up-refill_p_process_class_agg_report.sql
select ins_from_stage_to_dwh('#schema_name#','p_process_class_agg_report');

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