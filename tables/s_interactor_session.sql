create table s_interactor_session 
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
as 
select * from p_interactor_session where 1 = 2
DISTRIBUTED BY (session_start_ts);
;
