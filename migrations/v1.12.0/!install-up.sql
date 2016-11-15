\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;


drop function delete_recent_records_from_p_serverlogs(text);
drop function handle_utc_midnight_interactor_sess(text);
drop function load_from_stage_to_dwh(text, text);
drop function load_from_stage_to_dwh_multi_range_part(text, text);
drop function load_from_stage_to_dwh_single_range_part(text, text);

\i 001-up-cross_utc_midnight_sessions.sql
\i 002-up-check_if_load_date_already_in_table.sql

drop function load_s_cpu_usage_bootstrap_rpt(text);
\i 003-up-create_load_s_cpu_usage_bootstrap_rpt.sql
select create_load_s_cpu_usage_bootstrap_rpt('#schema_name#');

drop function load_s_cpu_usage_report(text);
\i 004-up-create_load_s_cpu_usage_report.sql
select create_load_s_cpu_usage_report('#schema_name#');

\i 005-up-get_max_ts.sql

drop function insert_p_serverlogs_from_s_serverlogs(text);
\i 006-up-insert_p_serverlogs_from_s_serverlogs.sql

drop function load_s_cpu_usage_agg_report(text);
\i 007-up-load_s_cpu_usage_agg_report.sql

drop function load_s_cpu_usage_dataserver(text);
\i 008-up-load_s_cpu_usage_dataserver.sql

drop function load_s_cpu_usage_rest(text);
\i 009-up-load_s_cpu_usage_rest.sql

drop function load_s_cpu_usage_tabproto(text);
\i 010-up-load_s_cpu_usage_tabproto.sql

drop function load_s_cpu_usage_tdeserver(text);
\i 011-up-load_s_cpu_usage_tdeserver.sql

drop function load_s_cpu_usage_vizql(text);
\i 012-up-load_s_cpu_usage_vizql.sql

drop function load_s_interactor_session(text);
\i 013-up-load_s_interactor_session.sql

drop function load_s_serverlogs_bootstrap_rpt(text);
\i 014-up-load_s_serverlogs_bootstrap_rpt.sql

drop function load_s_serverlogs_dataserver(text);
\i 015-up-load_s_serverlogs_dataserver.sql

drop function load_s_serverlogs_dataserver_compressed(text);
\i 016-up-load_s_serverlogs_dataserver_compressed.sql

drop function load_s_serverlogs_rest(text);
\i 017-up-load_s_serverlogs_rest.sql

drop function load_s_serverlogs_tabproto(text);
\i 018-up-load_s_serverlogs_tabproto.sql

drop function load_s_serverlogs_tabproto_compressed(text);
\i 019-up-load_s_serverlogs_tabproto_compressed.sql

drop function load_s_serverlogs_tdeserver(text);
\i 020-up-load_s_serverlogs_tdeserver.sql

drop function load_s_serverlogs_vizql(text);
\i 021-up-load_s_serverlogs_vizql.sql

drop function load_s_serverlogs_vizql_compressed(text);
\i 022-up-load_s_serverlogs_vizql_compressed.sql

\i 023-up-load_p_threadinfo_delta.sql
\i 024-up-s_serverlogs_plus_2_hours.sql
\i 025-up-load_s_serverlogs_plus_2_hours.sql


insert into db_version_meta(version_number) values ('v1.12.0');

COMMIT;