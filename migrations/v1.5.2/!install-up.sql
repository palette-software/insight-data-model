\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

grant select on p_process_class_agg_report to palette_palette_looker;