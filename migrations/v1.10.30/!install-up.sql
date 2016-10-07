\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

select drop_child_indexes('p_cpu_usage_bootstrap_rpt_parent_vizql_session_idx');
select drop_child_indexes('p_cpu_usage_report_cpu_usage_parent_vizql_session_idx');
select drop_child_indexes('p_serverlogs_p_id_idx');
select drop_child_indexes('p_serverlogs_parent_vizql_session_idx');
select drop_child_indexes('p_serverlogs_bootstrap_rpt_parent_vizql_session_idx');

drop index p_cpu_usage_bootstrap_rpt_parent_vizql_session_idx;
drop index p_cpu_usage_report_cpu_usage_parent_vizql_session_idx;
drop index p_serverlogs_p_id_idx;
drop index p_serverlogs_parent_vizql_session_idx;
drop index p_serverlogs_bootstrap_rpt_parent_vizql_session_idx;


insert into db_version_meta(version_number) values ('v1.10.30');

COMMIT;