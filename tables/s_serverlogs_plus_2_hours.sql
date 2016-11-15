create table s_serverlogs_plus_2_hours
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
as 
select * from p_serverlogs where 1 = 2
DISTRIBUTED BY (serverlogs_id);
;