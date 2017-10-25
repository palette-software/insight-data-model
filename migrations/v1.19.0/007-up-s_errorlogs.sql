create table s_errorlogs
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
as 
select * from p_errorlogs where 1 = 2
DISTRIBUTED BY (ts);
;
