create view p_interactor_cpu_usage_report
as
select * from p_cpu_usage_report
where cpu_usage_process_name in ('vizqlserver', 'dataserver', 'tabprotosrv', 'tdeserver');
