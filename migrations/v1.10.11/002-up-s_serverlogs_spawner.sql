CREATE TABLE s_serverlogs_spawner 
	(spawner_host_name text,
	parent_vizql_site text,														
	process_name text,
	spawner_session text,							
	parent_vizql_username text,														
	parent_vizql_destroy_sess_ts timestamp without time zone,																					
	spawner_ts_destroy_sess timestamp without time zone,
	parent_ds_vizql_session text)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY 
	(spawner_session)
;