create table s_cpu_usage_agg_report 
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
as 
select * from p_cpu_usage_agg_report where 1 = 2
DISTRIBUTED BY (timestamp_utc);
;