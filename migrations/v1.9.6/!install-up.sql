\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-load_s_cpu_usage_tdeserver.sql

create table palette.tmp_memory_upd as	
	select
		cpu.p_id,
		ti.memory_usage_bytes,
		count(1) over (partition by cpu.p_threadinfo_id) as session_count,
		ti.memory_usage_bytes / count(1) over (partition by cpu.p_threadinfo_id) as new_memory_usage_bytes
	from
		palette.p_cpu_usage cpu,
		palette.p_threadinfo ti
	where
		cpu.process_name like 'tdeserver%' and
		cpu.p_threadinfo_id = ti.p_id and
		cpu.ts_rounded_15_secs >= date'2016-07-13' and		
		ti.ts_rounded_15_secs >= date'2016-07-13'
;

update palette.p_cpu_usage t
set
	memory_usage_bytes = s.new_memory_usage_bytes
from
	palette.tmp_memory_upd s	
where
	t.process_name like 'tdeserver%' and
	t.ts_rounded_15_secs >= date'2016-07-13' and
	t.p_id = s.p_id	
;

update palette.p_cpu_usage_report t
set
	cpu_usage_memory_usage_bytes = s.new_memory_usage_bytes
from
	palette.tmp_memory_upd s	
where
	t.cpu_usage_process_name like 'tdeserver%' and
	t.cpu_usage_ts_rounded_15_secs >= date'2016-07-13' and
	t.cpu_usage_p_id = s.p_id
;

drop table palette.tmp_memory_upd;


insert into db_version_meta(version_number) values ('v1.9.6');

COMMIT;
