create table s_cpu_usage_bootstrap_rpt 
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
as 
select * from p_cpu_usage_bootstrap_rpt where 1 = 2
DISTRIBUTED BY (p_cpu_usage_report_p_id);
;