create table s_serverlogs_bootstrap_rpt 
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
as 
select * from p_serverlogs_bootstrap_rpt where 1 = 2
DISTRIBUTED BY (p_serverlogs_p_id);
;