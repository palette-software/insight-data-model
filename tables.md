# Palette Insight Tables
## Schema name: palette

### Tips and tricks

  * When using psql use ```set search_path = ‘palette’;```
  * Always filter the data. The amount of data can be huge depending on the table queried and the Tableau cluster size so always filter the data while developing a query. Most of the tables are partitioned daily so using date filters can significantly reduce the load on the DB. For all tables that have `ts_rounded_15_secs` that field is the partitioning key so use that (ie: ` where ts_rounded_15_secs > now()::date - interval'1 day'` ). For all other partitioned tables the `ts` field is the partitioning key.


| `p_process_class_agg_report` |  |
| :---: | --------- |
|  | Aggregated data for Palette Capacity. The table contains cpu and memory measurements for Tableau-related processes aggregated by host_name by process_name. If multiple instances of the same process are running on the same node, their values are summed up in here. The table content is continuously loaded by the scheduled job reporting_delta. The content of the table is kept indefinite and the p_id field can be used for incremental extract refreshes. |
| **Notable fields:** |
| `p_id` | Auto-increment ID field. Always bigger than the previous record. | 
| `ts_rounded_15_secs` | The timestamp the measurement took place rounded to a 15 seconds polling interval.
| `cpu_usage_core_consumption` | The actual cpu usage that happened for this record since the previous measurement (15 seconds). |
| `host_name` |The name of the machine the data is from. |
| `process_name` | The name of the process the data is referring to. (May be category like Non-Tableau or Palette for non-tableau processes)|

| `countersamples` |  |
| :---: | --------- |
|  | Contains machine level performance metrics for the possibility to cross-check Palette data. |
| **Notable fields:** |
| `timestamp ` | The timestamp the measurement took place. | 
| `name ` | Sample name, either ‘% Processor Time’ or ‘Total Memory’. |
| `value ` | The value of the current measurement. |
| `machine ` | The name of the machine the data is from. |

| `p_process_classification` |  |
| :---: | --------- |
|  | Contains configurations for the Palette Capacity dashboard. Two categories are predefined, Tableau and Palette. (The reason for having a Palette category is to distinguish that from all other non-tableau processes so that anyone using Palette could monitor that it is working fine with very low resource consumption.) |
| **Notable fields:** |
| `process_name ` | The name of the process. | 
| `process_class ` | Either Tableau or Palette. (All other processes are classified as Non-Tableau on the Palette Capacity dashboard). |

| `p_background_jobs` |  |
| :---: | --------- |
|  | A denormalized version of the built-in background_jobs repository table containing not just external IDs for user and site and such, but their corresponding names as well. This is generated during the reporting job and its purpose is making further reporting loads more effective. |

| `p_cpu_usage` | |
| :---: | --------- |
|  | This table is loaded based on p_serverlogs, p_threadinfo_delta and p_http_requests. In this table we have the user and workbook and all other details for every cpu usage record coming from p_threadinfo_delta. For a given p_threadinfo_delta record we try to match it to p_serverlog_records and as such we try to figure out who was doing what when that CPU consumption occured. |
| **Notable fields:** |
| `ts_rounded_15_secs` | The timestamp the measurement took place rounded to a 15 seconds polling interval. |
| `cpu_core_consumption` |The actual cpu usage that happened for this record since the previous measurement (15 seconds).|
| `process_id` | Exact ID of the process. This is unique for a given time for a given machine. |
| `thread_id` | ID of the thread if the current measurement is referring to a thread, `-1` otherwise. (`-1` means the current row refers to the whole process.) |
| `parent_vizql_session` | The Tableau VizQL Session Id that was matched to the current row. This field is the same for all CPU usage associated to this session throughout the Tableau cluster among all monitored processes. |


| `p_cpu_usage_bootstrap_rpt` ||
| :---: | --------- |
| | This table has the same data as p_cpu_usage_report but limited to records that happened before the Bootstrap action in Tableau has ended. This table is used for the Palette Performance workbook. (Bootstrap is that part of the session which starts when a user clicks on a view, and lasts until the spinner is spinning and ends when the contents of the view is first shown) |
| **Notable fields:** |
| `session_start_ts` | The UTC timestamp of the beginning of the session. |
| `session_duration` | How long the actual session lasted. |
| `currentsheet` | Which sheet of the workbook was originally opened. (During the bootstrap.) |
| `session_elapsed_seconds` | How long the session bootstrap has been taking in the time of this measurement. |

| `p_cpu_usage_report` ||
| :---: | --------- |
| | A denormalized version of p_cpu_usage. Based on ID records in p_cpu_usage the details are filled from Tableau repository tables so that Tableau reporting does not have to deal with joins. |

| `p_desktop_session` ||
| :---: | --------- |
| | *Not yet used by reporting.* |

| `p_http_requests` ||
| :---: | --------- |
| | This table is loaded based on http_request and the following historized Tableau repository tables: h_users, h_system_users, h_workbooks, h_projects, h_sites. This table has all user information detailed by parsing the workbook name from the currentsheet field of http_request and by the workbook name we are able to get all other information like project and site name. |

| `p_interactor_session` ||
| :---: | --------- |
| | Contains aggregated data from p_cpu_usage_report and has a single row of data for each vizql_session - process_type pairs in p_cpu_usage_report. For example if a session (12345) used vizqlserver and dataserver and tdeserver, it will have three records for the session (12345), one for each process. This table is the basis of the Palette Chargeback dashboard. |
| **Notable fields:** |
| `bootstrap_elapsed_secs` | The length of the bootstrap. |
| `num_fatals` | Number of fatal severity log lines during the session. |
| `num_errors` | Number of error severity log lines during the session. |
| `num_warnings` | Number of warning severity log lines during the session. |

| `p_load_dates` ||
| :---: | --------- |
| | *Technical table about Palette internals* |

| `p_serverlogs` ||
| :---: | --------- |
| | Loaded from the serverlogs table. This table contains process relationship information. (parent_vizqlsession, parent_dataserver_session etc) and some smaller data cleanup like domain is removed from username and such.|
| **Notable fields:** |
| `filename` | The original filename of the log file from which the given line is |
| `sev` | Severity of the current log line |
| `k` | Key (or category) of the current log line |
| `v` | Actual content of the current log line |
| `elapsed_ms` | Parsed duration of the event described in this log line |

| `p_serverlogs_bootstrap_rpt` ||
| :---: | --------- |
| | Has the same data as p_serverlogs but limited to records that happened before the Bootstrap action in Tableau has ended.|
| **Notable fields:** |
| `session_start_ts` | The UTC timestamp of the beginning of the session. |
| `session_duration` | How long the actual session lasted. |
| `currentsheet` | Which sheet of the workbook was originally opened. (During the bootstrap.) |
| `session_elapsed_seconds` | How long the session bootstrap has been taking in the time of this measurement. |

| `p_threadinfo` ||
| :---: | --------- |
| | *Currently not used* |

| `p_threadinfo_delta` ||
| :---: | --------- |
| | Based on threadinfo raw table. Contains the CPU consumption between two measures in threadinfo for the same process / thread. For the same process / thread there is always exactly 15 seconds time difference between two measures. |
| **Notable fields:** |
| `process_id ` | Exact ID of the process. This is unique for a given time for a given machine. |
| `thread_id` | ID of the thread if the current measurement is referring to a thread, `-1` otherwise. (`-1` means the current row refers to the whole process.) |
| `cpu_core_consumption` | The actual cpu usage that happened for this record since the previous measurement (15 seconds). |
| `memory_usage_bytes` | The actual memory usage in bytes for this record. |
| `ts_rounded_15_secs` | The timestamp the measurement took place rounded to a 15 seconds polling interval. |

| `plainlogs` ||
| :---: | --------- |
| | There are two kind of Tableau Server log files. One set of the Tableau Server processes log JSON format and an other set of them just plain text files. This table contains the raw log lines from plain text log files. |

| `serverlogs` ||
| :---: | --------- |
| | There are two kind of Tableau Server log files. One set of the Tableau Server processes log JSON format and an other set of them just plain text files. This table contains the raw log lines from JSON log files. |

| `threadinfo` ||
| :---: | --------- |
| | Contains raw cpu and memory metric values received from the Tableau Server nodes. |



| Non-historized repository tables | |
| :---: | --- |
|| These tables are polled from the Tableau server node that has the Repository on it. The content of these tables are streamed, which means that only changed or newly created records are polled. |
| **Tables:** |
|| `async_jobs` |
|| `background_jobs` |
|| `hist_capabilities` |
|| `hist_comments` |
|| `hist_configs` |
|| `hist_data_connections` |
|| `hist_datasources` |
|| `hist_groups` |
|| `hist_licensing_roles` |
|| `hist_projects` |
|| `hist_schedules` |
|| `hist_sites` |
|| `hist_tags` |
|| `hist_tasks` |
|| `hist_users` |
|| `hist_views` |
|| `hist_workbooks` |
|| `historical_disk_usage` |
|| `historical_event_types` |
|| `historical_events` |
|| `http_requests` |


| Historized repository tables | |
| :---: | --- |
|| These tables are polled from the Tableau repository tables with similar names (without the `h_` prefix. The difference is that Palette reporting takes notes on which values were active at a certain point of time (with an algorithm called SCD. )  |
| **Tables:** |
|| `h_capabilities` |
|| `h_capability_roles` |
|| `h_core_licenses` |
|| `h_customized_views` |
|| `h_data_connections` |
|| `h_datasources` |
|| `h_extracts` |
|| `h_group_users` |
|| `h_groups` |
|| `h_monitoring_dataengine` |
|| `h_monitoring_postgresql` |
|| `h_next_gen_permissions` |
|| `h_permission_reasons` |
|| `h_projects` |
|| `h_schedules` |
|| `h_sites` |
|| `h_subscriptions` |
|| `h_subscriptions_customized_views` |
|| `h_subscriptions_views` |
|| `h_subscriptions_workbooks` |
|| `h_system_users` |
|| `h_tasks` |
|| `h_user_default_customized_views` |
|| `h_users` |
|| `h_views` |
|| `h_workbooks` |

| Internally used "technical" tables | |
| :---: | --- |
|| These tables are needed for variouos technical reasons. |
| **Tables:** |
| `cross_utc_midnight_sessions` | This is needed to handle Tableau sessions running around UTC midnight. As our reporting uses UTC midnight as a separator, this is needed to handle sessions that overlap two days. |
| `ext_*` | External tables. These tables are used to import data from the csv files sent by the Palette Insight Agents to the database. |
| `_prt_*` | Partitions. Palette Insight utilizes the partitioning feature of Pivotal Greenplum Database and these tables are the actual tables of the partitions. |
| `s_*` | Stage tables. These are loaded during the reporting and after their content is filled that is moved to the matching `p_` table and the `s_` counterpart is truncated. |
