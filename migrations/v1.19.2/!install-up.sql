\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

alter table p_serverlogs_bootstrap_rpt rename to p_serverlogs_bootstrap_rpt_orig;

\i 001-up-create_p_serverlogs_bootstrap_rpt.sql
select create_p_serverlogs_bootstrap_rpt('#schema_name#');

alter table p_serverlogs_bootstrap_rpt alter column p_id set default nextval('p_serverlogs_bootstrap_rpt_p_id_seq');
alter sequence p_serverlogs_bootstrap_rpt_p_id_seq owned by p_serverlogs_bootstrap_rpt.p_id;

\i 002-up-load_s_serverlogs_bootstrap_rpt.sql
\i 003-up-manage_multi_range_partitions.sql
\i 004-up-manage_single_range_partitions.sql
\i 005-up-manage_partitions.sql

\i 006-up-copy_p_src_logs_bootstrap.sql;

select copy_p_src_logs_bootstrap('#schema_name#');
drop function copy_p_src_logs_bootstrap(p_schema_name text);
drop table p_serverlogs_bootstrap_rpt_orig;

grant select on p_serverlogs_bootstrap_rpt to palette_palette_looker;

insert into db_version_meta(version_number) values ('v1.19.2');

COMMIT;