CREATE TABLE p_process_class_agg_report
(
  p_id                         BIGSERIAL,
  ts_rounded_15_secs           TIMESTAMP,
  process_name                 TEXT,
  host_name                    TEXT,
  cpu_usage_core_consumption   DOUBLE PRECISION
)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (p_id)
PARTITION BY RANGE (ts_rounded_15_secs)
(START (date '2016-01-01') INCLUSIVE
	END (date '2019-01-01') EXCLUSIVE
	every(interval '1 month')
WITH (appendonly=true, orientation=column, compresstype=quicklz)	
);
