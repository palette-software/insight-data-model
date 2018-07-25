create table s_cpu_usage_hourly
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
as
select * from p_cpu_usage_hourly where 1 = 2
DISTRIBUTED BY (p_id);