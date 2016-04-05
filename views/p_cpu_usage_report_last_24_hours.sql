create or replace view p_cpu_usage_report_last_24_hours as
select * from p_cpu_usage_report
where
	cpu_usage_ts_rounded_15_secs >= (now() - (interval'1 hour' * 24))::timestamp
;