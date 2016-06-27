\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;
BEGIN;

\i 001-up-p_process_class_agg_report.sql
\i 002-up-load_p_process_class_agg_report.sql

insert into p_process_class_agg_report
	    (
            ts_rounded_15_secs,
            process_name,
            host_name,
            cpu_usage_core_consumption
		)
	    select
    	    cpu_usage_ts_rounded_15_secs,
        case
            when cpu_usage_process_name in ('vizqlserver', 'tdeserver64', 'backgrounder',
                'vizportal', 'zookeeper', 'tabprotosrv', 'tableau', 'clustercontroller',
                'tabspawn', 'redis-server', 'tabadminservice', 'tabsvc', 'postgres') then cpu_usage_process_name
            else 'other'
            end as process_name,
            cpu_usage_host_name,
            sum(cpu_usage_cpu_core_consumption) as total_consumption
        from
	        p_cpu_usage_report
        where
			cpu_usage_ts_rounded_15_secs >= now()::date - interval'14 days'
        group by
	        cpu_usage_ts_rounded_15_secs,
	        cpu_usage_host_name,
	        process_name
;




insert into db_version_meta(version_number) values ('v1.5.0');

COMMIT;
