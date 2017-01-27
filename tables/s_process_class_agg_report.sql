create table s_process_class_agg_report 
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
as 
select * from p_process_class_agg_report where 1 = 2
DISTRIBUTED BY (ts_rounded_15_secs);
;
