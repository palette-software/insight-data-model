\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

alter table plainlogs rename to plainlogs_old;

CREATE TABLE plainlogs (LIKE plainlogs_old INCLUDING DEFAULTS)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (p_id)
PARTITION BY RANGE (ts)
(PARTITION "10010101" 
    START (date '1001-01-01') INCLUSIVE
	END (date '1001-01-02') EXCLUSIVE 	
WITH (appendonly=true, orientation=column, compresstype=quicklz)	
);


-- todo: select manage_partitions('#schema_name#', 'plainlogs'); new function then drop...

alter sequence plainlogs_p_id_seq owned by plainlogs.p_id;

-- todo: maintenance

insert into plainlogs (
         p_filepath
       , filename
       , host_name
       , ts
       , pid
       , line
       , elapsed_ms
       , start_ts)        
SELECT  p_filepath
       , filename
       , host_name
       , ts
       , pid
       , line
       , elapsed_ms
       , start_ts       
FROM plainlogs_old;


insert into db_version_meta(version_number) values ('v1.10.20');

--drop table plainlogs_old;

COMMIT;