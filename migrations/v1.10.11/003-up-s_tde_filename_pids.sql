CREATE TABLE s_tde_filename_pids 
	(host_name text,
	file_prefix text,
	pid bigint,
	ts_from timestamp without time zone,
	ts_to timestamp without time zone)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY 
	(host_name,
	file_prefix,
	ts_from, 
	ts_to)
;