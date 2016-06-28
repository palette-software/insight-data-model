\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

begin;

alter table p_interactor_session add p_id bigserial;

delete from p_interactor_session
using
(
with t_base as 
(		select 	
			vizql_session, 
			process_name,
			sum(cpu_time_consumption_seconds) sum_cpu_time_cons,
			count(1) cnt 
		from p_interactor_session
		group by 
			vizql_session, 
			process_name
		having count(1) > 1
)
select
	p_id
from
	(select 
		row_number() over (partition by vizql_session, process_name order by cpu_time_consumption_seconds desc) rn,
		t.p_id
	from
		p_interactor_session t
	where
		vizql_session in (select vizql_session from t_base)
	) a
where
	rn > 1
) s
where 
	p_interactor_session.p_id = s.p_id
;

insert into db_version_meta(version_number) values ('v1.4.7');

commit;
