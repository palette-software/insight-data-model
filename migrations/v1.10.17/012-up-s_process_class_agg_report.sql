create table #schema_name#.s_process_class_agg_report 
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
as 
select * from #schema_name#.p_process_class_agg_report where 1 = 2
DISTRIBUTED BY (ts_rounded_15_secs);
;