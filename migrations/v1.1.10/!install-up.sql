drop view p_serverlogs;
create table p_serverlogs...
drop table s_cpu_usage_serverlogs;
drop table s_serverlogs_tabproto;
drop table s_serverlogs_tabproto_compressed;
drop function load_s_serverlogs_tabproto(p_schema_name text);
drop table s_cpu_usage_serverlogs;
create table s_serverlogs_compressed()...
drop function load_s_cpu_usage_serverlogs(p_schema_name text);

alter table s_cpu_usage add column parent_vizql_session text default null;
alter table s_cpu_usage add column parent_dataserver_session text default null;
alter table s_cpu_usage add column spawned_by_parent_ts text default null;
alter table s_cpu_usage add column parent_vizql_destroy_sess_ts text default null;
alter table s_cpu_usage add column parent_process_type text default null;

alter table p_cpu_usage add column parent_vizql_session text default null;
alter table p_cpu_usage add column parent_dataserver_session text default null;
alter table p_cpu_usage add column spawned_by_parent_ts text default null;
alter table p_cpu_usage add column parent_vizql_destroy_sess_ts text default null;					
alter table p_cpu_usage add column parent_process_type text default null;