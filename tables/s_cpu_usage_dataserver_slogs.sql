CREATE TABLE s_cpu_usage_dataserver_slogs WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ) AS 
select * from s_serverlogs_compressed
where 1 = 2
DISTRIBUTED BY (session)
;