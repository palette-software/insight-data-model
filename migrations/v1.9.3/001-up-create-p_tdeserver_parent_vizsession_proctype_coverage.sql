CREATE OR REPLACE VIEW p_tdeserver_parent_vizsession_proctype_coverage AS
SELECT 
	pslogs.host_name, 
	date_trunc('hour', pslogs.ts) AS ts_hour, 
	count(1) AS count_tdeserver_entries_last_48_hours,
	sum(CASE WHEN pslogs.parent_vizql_session IS NOT NULL THEN 1
        ELSE 0
        END)::double precision / count(1)::double precision * 100.0 AS parent_vizql_session_fill_ratio,
	sum(CASE WHEN pslogs.parent_process_type IS NOT NULL THEN 1
        ELSE 0
        END)::double precision / count(1)::double precision * 100.0 AS parent_process_type_fill_ratio,
	sum(CASE WHEN pslogs.parent_process_type IS NOT NULL AND pslogs.parent_vizql_session IS NOT NULL THEN 1
        ELSE 0
        END) / count(1)::double precision * 100.0 AS parent_vizsession_and_proctype_fill_ratio
FROM p_serverlogs pslogs
WHERE 
	pslogs.process_name LIKE 'tdeserver%'
	and pslogs.ts >= timezone('utc', now() - '48 hours'::interval) AND pslogs.ts <= timezone('utc', now())
GROUP BY 
	pslogs.host_name,
	date_trunc('hour', pslogs.ts)
ORDER BY ts_hour asc;
