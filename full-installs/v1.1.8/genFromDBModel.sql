/*
Created: 2016.03.02.
Modified: 2016.03.31.
Project: Palette
Model: Palette insight
Version: v1.1.4
Database: Greenplum 4.2
*/



-- Create tables section -------------------------------------------------

-- Table p_cpu_usage

CREATE TABLE "p_cpu_usage"(
 "p_id" BigSerial NOT NULL,
 "p_threadinfo_id" Bigint NOT NULL,
 "ts" Timestamp,
 "ts_rounded_15_secs" Timestamp,
 "ts_date" Date,
 "ts_day_hour" Timestamp,
 "vizql_session" Text,
 "repository_url" Text,
 "user_ip" Text,
 "site_id" Bigint,
 "workbook_id" Bigint,
 "cpu_time_consumption_ticks" Bigint,
 "cpu_time_consumption_seconds" Double precision,
 "cpu_time_consumption_hours" Double precision,
 "ts_interval_ticks" Bigint,
 "cpu_core_consumption" Double precision,
 "memory_usage_bytes" Bigint,
 "process_name" Text,
 "process_owner" Text,
 "is_allocatable" Character varying(1),
 "process_level" Text,
 "is_thread_level" Character varying(1),
 "host_name" Text,
 "process_id" Bigint,
 "thread_id" Bigint,
 "start_ts" Timestamp,
 "end_ts" Timestamp,
 "username" Text,
 "h_workbooks_p_id" Bigint,
 "h_projects_p_id" Bigint,
 "publisher_h_users_p_id" Bigint,
 "publisher_h_system_users_p_id" Bigint,
 "h_sites_p_id" Bigint,
 "interactor_h_users_p_id" Bigint,
 "interactor_h_system_users_p_id" Bigint,
 "max_reporting_granuralty" Boolean,
 "dataserver_session" text
)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (p_id)
PARTITION BY RANGE (ts_rounded_15_secs)
SUBPARTITION BY LIST (host_name)
SUBPARTITION TEMPLATE (SUBPARTITION init VALUES ('init')
WITH (appendonly=true, orientation=column, compresstype=quicklz))
(PARTITION "10010101" START (date '1001-01-01') INCLUSIVE
	END (date '1001-01-02') EXCLUSIVE 
WITH (appendonly=true, orientation=column, compresstype=quicklz)	
)
;

COMMENT ON TABLE "p_cpu_usage" IS 'CPU usage by (host, process name, processid, thread id) with the tableua sessions.

E.g. in a specific millisecond for a specific thread the cpu time was X and one (or more) 

tableau session can be matched to that thread in that time.

If the session is a vizql session the p_http_requests_with_wokbook can give us more information regarding

users, workbooks, etc.



The granularity  for the vizsql processes(sessions) is thread level the rest processs'' level is pid level.



ETL:

tables: tableau_session_threads, p_threadinfo, p_http_requests_with_workbooks'
;
COMMENT ON COLUMN "p_cpu_usage"."p_threadinfo_id" IS '

ETL: p_threadinfo.p_id'
;
COMMENT ON COLUMN "p_cpu_usage"."ts" IS '

ETL: p_threadinfo.ts'
;
COMMENT ON COLUMN "p_cpu_usage"."ts_rounded_15_secs" IS '

ETL: p_threadinfo.ts_date'
;
COMMENT ON COLUMN "p_cpu_usage"."ts_date" IS '

ETL: p_threadinfo.ts_date'
;
COMMENT ON COLUMN "p_cpu_usage"."ts_day_hour" IS '

ETL: DATE_TRUNC(''hour'', p_threadinfo.ts)'
;
COMMENT ON COLUMN "p_cpu_usage"."vizql_session" IS '

ETL: serverlogs.sess if filename like vizqlserver'
;
COMMENT ON COLUMN "p_cpu_usage"."repository_url" IS '

ETL: p_http_requests.split_part(currentsheet,''/'', 1)'
;
COMMENT ON COLUMN "p_cpu_usage"."user_ip" IS '

ETL: p_http_requests.user_ip'
;
COMMENT ON COLUMN "p_cpu_usage"."site_id" IS '

ETL: p_http_requests.site_id'
;
COMMENT ON COLUMN "p_cpu_usage"."workbook_id" IS '

ETL: p_http_requests.workbook_id'
;
COMMENT ON COLUMN "p_cpu_usage"."cpu_time_consumption_ticks" IS '

ETL: p_threadinfo.cpu_time_delta_ticks'
;
COMMENT ON COLUMN "p_cpu_usage"."cpu_time_consumption_seconds" IS '

ETL: p_threadinfo.cpu_time_delta_ticks::numeric / 10000000'
;
COMMENT ON COLUMN "p_cpu_usage"."cpu_time_consumption_hours" IS '

ETL: p_threadinfo.cpu_time_delta_ticks::numeric / 10000000 / 60 / 60'
;
COMMENT ON COLUMN "p_cpu_usage"."ts_interval_ticks" IS '

ETL: p_threadinfo.ts_interval_ticks'
;
COMMENT ON COLUMN "p_cpu_usage"."cpu_core_consumption" IS '

ETL: p_threadinfo.cpu_core_consumption'
;
COMMENT ON COLUMN "p_cpu_usage"."memory_usage_bytes" IS '

ETL: p_threadinfo.memory_usage_bytes'
;
COMMENT ON COLUMN "p_cpu_usage"."process_name" IS '

ETL: p_threadinfo.process_name'
;
COMMENT ON COLUMN "p_cpu_usage"."process_owner" IS '  case when process_name in (''backgrounder'',
							''clustercontroller'',
							''dataserver'',
							''filestore'',
							''httpd'',
							''postgres'',
							''searchserver'',
							''tabadminservice'',
							''tableau'',
							''tabprotosrv'',
							''tabrepo'',
							''tabsvc'',
							''tabsystray'',
							''tdeserver'',
							''vizportal'',
							''vizqlserver'',
							''wgserver'',
							''zookeeper'') then 
			''Tableau''
  else 
  			''Non-Tableau''
  end'
;
COMMENT ON COLUMN "p_cpu_usage"."is_allocatable" IS '
ETL:
 case when process_name in (''dataserver'',							
							  ''tabprotosrv'',
							  ''tdeserver'')
			then ''Y''
			
		when  process_name = ''vizqlserver'' and tst.session is not null
			then ''Y''
  else 
  	''N''
  end'
;
COMMENT ON COLUMN "p_cpu_usage"."process_level" IS 'Can be process or thread level. If the tid is not -1 then it is a thread level (we have thread information) otherwise it is a process level.

ETL: case when thread_id = -1 then ''''Process Level'''' else ''''Thread Level''''
'
;
COMMENT ON COLUMN "p_cpu_usage"."is_thread_level" IS '
ETL: p_threadinfo.is_thread_level'
;
COMMENT ON COLUMN "p_cpu_usage"."host_name" IS '

ETL: p_threadinfo.host_name'
;
COMMENT ON COLUMN "p_cpu_usage"."process_id" IS '

ETL: p_threadinfo.process_id'
;
COMMENT ON COLUMN "p_cpu_usage"."thread_id" IS '

ETL: p_threadinfo.thread_id'
;
COMMENT ON COLUMN "p_cpu_usage"."start_ts" IS '

ETL: min(serverlogs.ts)'
;
COMMENT ON COLUMN "p_cpu_usage"."end_ts" IS '

ETL: max(serverlogs.ts)'
;
COMMENT ON COLUMN "p_cpu_usage"."username" IS '

ETL: substring(serverlogs.username, position(''\\'' in username) + 1)'
;
COMMENT ON COLUMN "p_cpu_usage"."h_workbooks_p_id" IS '

ETL: p_http_requests.h_workbooks_p_id'
;
COMMENT ON COLUMN "p_cpu_usage"."h_projects_p_id" IS '

ETL: p_http_requests.h_projects_p_id'
;
COMMENT ON COLUMN "p_cpu_usage"."publisher_h_users_p_id" IS '

ETL: p_http_requests.publisher_h_users_p_id'
;
COMMENT ON COLUMN "p_cpu_usage"."publisher_h_system_users_p_id" IS '

ETL: p_http_requests.publisher_h_system_users_p_id'
;
COMMENT ON COLUMN "p_cpu_usage"."h_sites_p_id" IS '

ETL: p_http_requests.h_sites_p_id'
;
COMMENT ON COLUMN "p_cpu_usage"."interactor_h_users_p_id" IS '

ETL: p_http_requests.interactor_h_users_p_id'
;
COMMENT ON COLUMN "p_cpu_usage"."interactor_h_system_users_p_id" IS '

ETL: p_http_requests.interactor_h_system_users_p_id'
;
COMMENT ON COLUMN "p_cpu_usage"."dataserver_session" IS '

ETL: serverlogs.sess if filename like dataserver'
;


-- Table p_threadinfo

CREATE TABLE "p_threadinfo"(
 "p_id" BigSerial NOT NULL,
 "threadinfo_id" Bigint,
 "host_name" Character varying(255),
 "process_name" Character varying(255),
 "ts" Timestamp,
 "ts_rounded_15_secs" Timestamp,
 "ts_date" Date,
 "process_id" Bigint,
 "thread_id" Bigint,
 "start_ts" Timestamp,
 "cpu_time_ticks" Bigint,
 "cpu_time_delta_ticks" Bigint,
 "ts_interval_ticks" Bigint,
 "cpu_core_consumption" Double precision,
 "memory_usage_bytes" Bigint,
 "memory_usage_delta_bytes" Bigint,
 "is_thread_level" Character varying(1)
)
WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
DISTRIBUTED BY (host_name, process_id, thread_id)
PARTITION BY RANGE (ts_rounded_15_secs)
SUBPARTITION BY LIST (host_name)
SUBPARTITION TEMPLATE (SUBPARTITION init VALUES ('init')
WITH (appendonly=true, orientation=column, compresstype=quicklz))
(PARTITION "10010101" START (date '1001-01-01') INCLUSIVE
	END (date '1001-01-02') EXCLUSIVE 
WITH (appendonly=true, orientation=column, compresstype=quicklz)
)

;

COMMENT ON TABLE "p_threadinfo" IS 'Detailed CPU usage information by thread.

Basically:

How much time the CPU spent on the specific (host, process, process id (id), thread id (tid)).

This is a "sample-time based" table. E.g. if the sample time is 15 second then the this table contains 

records for a specific  (host, process, pid, tid) in every 15 seconds.



ETL:

Tabes: threadinfo'
;
COMMENT ON COLUMN "p_threadinfo"."threadinfo_id" IS '

ETL: threadinfo.id'
;
COMMENT ON COLUMN "p_threadinfo"."host_name" IS '

ETL: threadinfo.host_name'
;
COMMENT ON COLUMN "p_threadinfo"."process_name" IS '

ETL: threadinfo.process'
;
COMMENT ON COLUMN "p_threadinfo"."ts" IS 'ETL: threadinfo.ts'
;
COMMENT ON COLUMN "p_threadinfo"."ts_rounded_15_secs" IS 'The ts column rounded to 15 seconds.



ETL:

date_trunc(''minutes'', ts) +  (15 * (floor(date_part(''seconds'', ts))::int / 15)) * interval ''1 second''

'
;
COMMENT ON COLUMN "p_threadinfo"."ts_date" IS 'Technical column for partition definition.

ETL: ts::date'
;
COMMENT ON COLUMN "p_threadinfo"."process_id" IS 'ETL: threadinfo.pid'
;
COMMENT ON COLUMN "p_threadinfo"."thread_id" IS 'ETL: threadinfo.tid'
;
COMMENT ON COLUMN "p_threadinfo"."start_ts" IS 'ETL: threadinfo.start_ts'
;
COMMENT ON COLUMN "p_threadinfo"."cpu_time_ticks" IS 'ETL: threadinfo.cpu_time'
;
COMMENT ON COLUMN "p_threadinfo"."cpu_time_delta_ticks" IS '

ETL:

CASE 
WHEN (lag_ts_int IS NULL OR start_ts_int > lag_ts_int) and tid <> -1 
	then cpu_time
WHEN cpu_time-lag_cpu_time>=0
  THEN cpu_time-lag_cpu_time       
ELSE NULL -- looks like a new thread	'
;
COMMENT ON COLUMN "p_threadinfo"."ts_interval_ticks" IS '
ETL:
  CASE 
	WHEN (lag_ts_int IS NULL OR start_ts_int > lag_ts_int) and tid <> -1 and (ts_int - start_ts_int) <= 160000000
		 -- new thread 
		 -- if lag_ts_int is null then we never see this pid and tid combination during the execution
		 -- if thread start ts is more recent than the previous records timestamp then it is also a new record
		 --
		 -- as a sanity check we make sure that this new interval is smaller than a standard 15secs
		 -- sampling interval
		 -- If it is ok, then simply take current measurement timestamp minus thread start timestamp
		THEN ts_int - start_ts_int			 
	WHEN (lag_ts_int IS NULL OR (ts_int - lag_ts_int) > 160000000)
	   -- Thread / process with issues (most probably caused by agent restart or failure)
	   -- Simply omit the record and analyze later, exclude from reporting
	   THEN NULL
	   
	   
	WHEN cpu_time-lag_cpu_time>0 AND (ts_int-lag_ts_int) < (cpu_time-lag_cpu_time) AND tid <> -1
	  THEN NULL -- we have previous value but it''''s bigger than the interval (like 20 secs consumption in 15 secs)
				-- NULL means we omit this record -- we should have some automation to catch them   		   
	WHEN cpu_time-lag_cpu_time>=0 AND ts_int-lag_ts_int > 0
	   -- this looks a normal record
	   THEN ts_int-lag_ts_int 
	WHEN cpu_time-lag_cpu_time>=0 AND ts_int-lag_ts_int = 0
	   -- ts interval cannot be null, this might be some data duplication error
	   THEN NULL
   ELSE NULL -- what else? I don''''t know, but lets mark it as bad.'
;
COMMENT ON COLUMN "p_threadinfo"."cpu_core_consumption" IS '

ETL:

cpu_time_delta_ticks::float / ts_interval_ticks::float '
;
COMMENT ON COLUMN "p_threadinfo"."memory_usage_bytes" IS 'ETL: threadinfo.working_set'
;
COMMENT ON COLUMN "p_threadinfo"."memory_usage_delta_bytes" IS 'ETL:
  case WHEN lag_working_set IS NULL 
	  	then working_set
	  else
	  	working_set - lag_working_set 
	  end'
;
COMMENT ON COLUMN "p_threadinfo"."is_thread_level" IS 'ETL:
case when thread_level 
	  	then ''Y'' 
	  else
	  		''N''
	  end'
;


-- Grant permissions section -------------------------------------------------




