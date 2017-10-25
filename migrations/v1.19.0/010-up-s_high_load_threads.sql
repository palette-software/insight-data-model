create table s_high_load_threads
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
as 
select * from p_high_load_threads where 1 = 2
DISTRIBUTED BY (host_name, ts_rounded_15_secs);
;
