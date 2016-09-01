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

\i 001-up-create_plainlogs_part.sql
\i 002-up-manage_single_range_partitions.sql
\i 003-up-manage_partitions.sql

select create_plainlogs_part('#schema_name#', 'plainlogs');

alter sequence plainlogs_p_id_seq owned by plainlogs.p_id;

insert into plainlogs (
         p_filepath
       , filename
       , host_name
       , ts
       , pid
       , line
       , elapsed_ms
       , start_ts
       , p_cre_date)        
SELECT  p_filepath
       , filename
       , host_name
       , ts
       , pid
       , line
       , elapsed_ms
       , start_ts       
       , p_cre_date
FROM plainlogs_old;

drop table plainlogs_old;
drop function create_plainlogs_part(p_schema_name text, p_table_name text);


insert into db_version_meta(version_number) values ('v1.10.20');

COMMIT;