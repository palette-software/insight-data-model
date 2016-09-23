CREATE TABLE s_plainlogs_session_map 
	(tid integer,
	sessid text,
	first_p_id bigint,
	last_p_id bigint,
	ts_start timestamp without time zone,
	ts_end timestamp without time zone,
	session_uid text,
	filename text,
	file_prefix_to_join text)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY 
	(file_prefix_to_join, 
	session_uid,
	ts_start,
	ts_end)
;