CREATE TABLE p_process_class_agg_report
(
  p_id                         BIGSERIAL,
  ts_rounded_15_secs           TIMESTAMP,
  process_name                 TEXT,
  host_name                    TEXT,
  cpu_usage_core_consumption   DOUBLE PRECISION,
  cpu_usage_cpu_time_consumption_seconds DOUBLE PRECISION,
  cpu_usage_memory_usage_bytes BIGINT,
  tableau_process              BOOLEAN
)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (p_id)
PARTITION BY RANGE (ts_rounded_15_secs)
(PARTITION "100101" START (date '1001-01-01') INCLUSIVE
	END (date '1001-02-01') EXCLUSIVE
WITH (appendonly=true, orientation=column, compresstype=quicklz)	
);