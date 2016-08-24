create table #schema_name#.s_interactor_session 
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
as 
select * from #schema_name#.p_interactor_session where 1 = 2
DISTRIBUTED BY (session_start_ts);
;