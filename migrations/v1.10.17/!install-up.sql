\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role #schema_name#_#schema_name#_updater;

BEGIN;

\i ins_stage_to_dwh.sql
\i load_from_stage_to_dwh.sql
\i load_from_stage_to_dwh_multi_range_part.sql
\i load_from_stage_to_dwh_single_range_part.sql
\i manage_multi_range_partitions.sql
\i manage_partitions.sql
\i manage_single_range_partitions.sql
\i -up-s_cpu_usage_agg_report.sql
\i -up-s_interactor_session.sql
\i -up-s_process_class_agg_report.sql
\i -up-s_serverlogs_bootstrap_rpt.sql
\i -up-s_cpu_usage_bootstrap_report.sql

drop function load_p_serverlogs_bootstrap_rpt(p_schema_name text);
drop function load_p_cpu_usage_agg_report(p_schema_name text);
drop function load_p_interactor_session(p_schema_name text);
drop function load_p_process_class_agg_report(p_schema_name text);
drop function create_load_p_cpu_usage_bootstrap_rpt(p_schema_name text);
drop function load_p_cpu_usage_bootstrap_rpt(p_schema_name text);

\i -up-load_s_serverlogs_bootstrap_rpt.sql
\i -up-load_s_cpu_usage_agg_report.sql
\i -up-load_s_interactor_session.sql
\i -up-load_s_process_class_agg_report.sql
\i -up-create_load_s_cpu_usage_bootstrap_rpt.sql
select create_load_s_cpu_usage_bootstrap_rpt('#schema_name#')

alter table p_cpu_usage_agg_report rename to p_cpu_usage_agg_report_old;
alter table p_interactor_session rename to p_interactor_session_old;
alter table p_process_class_agg_report rename to p_process_class_agg_report_old;
alter table p_serverlogs_bootstrap_rpt rename to p_serverlogs_bootstrap_rpt_old;
alter table p_cpu_usage_bootstrap_rpt rename to p_cpu_usage_bootstrap_rpt_old;

\i -up-p_cpu_usage_agg_report.sql
\i -up-p_interactor_session.sql
\i -up-p_process_class_agg_report.sql
\i -up-create_p_serverlogs_bootstrap_rpt.sql
select create_p_serverlogs_bootstrap_report('#p_schema_name#');
\i -up-create_p_cpu_usage_bootstrap_report.sql
select create_p_cpu_usage_bootstrap_report('#p_schema_name#');

insert into s_cpu_usage_agg_report select * from p_cpu_usage_agg_report_old;
insert into s_interactor_session select * from p_interactor_session_old;
insert into s_process_class_agg_report select * from p_process_class_agg_report_old;
insert into s_serverlogs_bootstrap_rpt select * from p_serverlogs_bootstrap_rpt_old;
insert into s_cpu_usage_bootstrap_rpt select * from p_cpu_usage_bootstrap_rpt_old;

select manage_partitions('#schema_name#', 'p_cpu_usage_agg_report');
select manage_partitions('#schema_name#', 'p_interactor_session');
select manage_partitions('#schema_name#', 'p_process_class_agg_report');
select manage_partitions('#schema_name#', 'p_serverlogs_bootstrap_rpt');
select manage_partitions('#schema_name#', 'p_cpu_usage_bootstrap_rpt');

select ins_from_stage_to_dwh('#schema_name#','p_serverlogs_bootstrap_rpt');
select ins_from_stage_to_dwh('#schema_name#','p_cpu_usage_agg_report');
select ins_from_stage_to_dwh('#schema_name#','p_cpu_usage_bootstrap_rpt');
select ins_from_stage_to_dwh('#schema_name#','p_interactor_session');
select ins_from_stage_to_dwh('#schema_name#','p_process_class_agg_report');

--drop table p_cpu_usage_agg_report_old;
--drop table p_process_class_agg_report_old;
--drop table p_serverlogs_bootstrap_rpt_old;
--drop table p_interactor_session_old;
--drop table p_cpu_usage_bootstrap_rpt_old;

CREATE INDEX p_serverlogs_bootstrap_rpt_parent_vizql_session_idx
		ON #schema_name#.p_serverlogs_bootstrap_rpt
		USING btree (parent_vizql_session);
CREATE INDEX p_cpu_usage_bootstrap_rpt_parent_vizql_session_idx
		ON #schema_name#.p_cpu_usage_bootstrap_rpt
		USING btree (cpu_usage_parent_vizql_session);



insert into db_version_meta(version_number) values ('v1.10.17');

COMMIT;