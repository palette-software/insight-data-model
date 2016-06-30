\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

\i 001-up-load_p_process_class_agg_report.sql

truncate table p_process_class_agg_report;
insert into p_process_class_agg_report
	    (
            ts_rounded_15_secs,
            process_name,
            host_name,
            cpu_usage_core_consumption,
            cpu_usage_cpu_time_consumption_seconds,
            cpu_usage_memory_usage_bytes,
            tableau_process
		)
        select
    	    cpu_usage_ts_rounded_15_secs,
            case
                when cpu_usage_process_name in ('vizqlserver', 'tdeserver64', 'backgrounder',
        'vizportal', 'zookeeper', 'tabprotosrv', 'tableau', 'clustercontroller',
        'tabspawn', 'redis-server', 'tabadminservice', 'tabsvc', 'postgres',
        'dataserver', 'filestore', 'tabadmsvc', 'tabadmwrk', 'tdeserver', 'wgserver',
		'tabadmin', 'tabcmd') then cpu_usage_process_name
                else 'Non-Tableau'
            end as process_name,
            cpu_usage_host_name,
            sum(cpu_usage_cpu_core_consumption) as cpu_usage_core_consumption,
            sum(cpu_usage_cpu_time_consumption_seconds) as cpu_usage_cpu_time_consumption_seconds,
            sum(cpu_usage_memory_usage_bytes) as cpu_usage_memory_usage_bytes,
            case
                when cpu_usage_process_name in ('vizqlserver', 'tdeserver64', 'backgrounder',
        'vizportal', 'zookeeper', 'tabprotosrv', 'tableau', 'clustercontroller',
        'tabspawn', 'redis-server', 'tabadminservice', 'tabsvc', 'postgres',
        'dataserver', 'filestore', 'tabadmsvc', 'tabadmwrk', 'tdeserver', 'wgserver',
		'tabadmin', 'tabcmd') then true
                else false
            end as tableau_process
        from
	        p_cpu_usage_report
		where
			cpu_usage_thread_id = -1
        group by
	        cpu_usage_ts_rounded_15_secs,
	        cpu_usage_host_name,
	        process_name,
            tableau_process
;

insert into db_version_meta(version_number) values ('v1.6.2');

COMMIT;