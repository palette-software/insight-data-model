-- Creates a view that gives us the coverage of tdeserver CPU consumption:
-- it returns the ratio of (rows vizql_sessions / total rows) for p_cpu_report
-- entries that have cpu usage, are from the 'tdeserver64' process.

-- Example from USF:

-- host  ts_hour   count_tdeserver_entries   tdeserver_fill_ratio
-- [...]
-- dataviz	2016-07-06 14:00:00.000000	1680	0
-- dataviz	2016-07-06 20:00:00.000000	1584	19.76010101010101
-- dataviz	2016-07-06 22:00:00.000000	1944	49.48559670781893
-- dataviz	2016-07-06 23:00:00.000000	1886	37.75185577942736
-- dataviz	2016-07-07 04:00:00.000000	1200	0
-- [...]



create or replace view p_tdeserver_cpu_coverage as
  select
    host_name,
    date_trunc('hour', ts_rounded_15_secs) as ts_hour,
    count(1) as count_tdeserver_entries_with_cpu_consumption,
    ((sum(case when vizql_session is not null then 1 else 0 end)::double precision /  count(1)::double precision) * 100.0) as tdeserver_fill_ratio
    from palette.p_cpu_usage
  where process_name in ('tdeserver64', 'tdeserver')
     and ts_rounded_15_secs between  ((now() - '48 hours'::interval) at time zone 'utc') and ((now() at time zone 'utc'))
  group by host_name, date_trunc('hour', ts_rounded_15_secs)
  order by ts_hour asc;

