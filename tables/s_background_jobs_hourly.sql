create table s_background_jobs_hourly
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
as
select * from p_background_jobs_hourly where 1 = 2
DISTRIBUTED BY (p_id);