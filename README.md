[![Build Status](https://travis-ci.com/palette-software/insight-data-model.svg?token=qWG5FJDvsjLrsJpXgxSJ&branch=master)](https://travis-ci.com/palette-software/insight-data-model)

## What is insight-data-model?

Insight Datamodel is a set of Greenplum DB table, view and function definitions that are used during the processing of Tableau performance data. This process is called reporting.


### Terminology

**Stage table**: For certain tables we use stage tables for loading. They always start the load process truncated (and as such empty) and after their load is finished their content is appended to their p_ counterpart. The name of the stage tables always start with s_ and they always have a p_ counterpart with the same name except for the first character.

**Daily load**: As we load data daily but we need data from different sources like Tableau server logs and Tableau repository data but we cannot be sure when is the time we have all data needed to completely understand a session we decided to load everything until UTC midnight plus two hours of data that has any relationship to session started before UTC midnight. This makes the load process a bit more complicated than it is explained later but for easier understanding we just miss some details in the docs. This logic also means that the sessions that last more than two hours will not be processed correctly.

### Reporting flow

Reporting has two separate jobs:

#### Incremental load of aggregated process level performance info

  1. p_threadinfo_delta is loaded based on threadinfo raw table. (load_p_threadinfo_delta): p_threadinfo_delta contains the CPU consumption between two measures in threadinfo for the same process / thread. For the same process / thread there is always exactly 15 seconds time difference between two measures.

  2. s_process_class_agg_report is loaded base on p_threadinfo_delta (load_s_process_class_agg_report)

  3. p_process_class_agg_report is filled with the whole content of s_process_class_agg_report (ins_stage_to_dwh): This table contains process level aggregated info for each 15 seconds of measures. So for example if three vizqlserver processes were running at the point of measure they will be aggregated to a single row in this table.

#### Daily load of detailed performance information

  1. p_serverlogs is loaded based on the serverlogs table. This is done in several steps the order of which is important and mustn't be changed. This table contains process relationship information. (parent_vizqlsession, parent_dataserver_session etc) and some smaller data cleanup like domain is removed from username and such.
    1. load_s_serverlogs_rest
    2. load_s_serverlogs_vizql
    3. load_s_serverlogs_dataserver
    4. load_s_serverlogs_tabproto
    5. load_s_serverlogs_tdeserver
    6. insert_p_serverlogs_from_s_serverlogs

  2. p_http_request is loaded based on http_request and the following historized Tableau repository tables: h_users, h_system_users, h_workbooks, h_projects, h_sites. This table has all user inforamtion detailed by parsing the workbook name from the currentsheet field of http_request and by the workbook name we are able to get all other information like project and site name.

  3. p_cpu_usage is loaded based on p_serverlogs, p_threadinfo_delta and p_http_requests. In this table we have the user and workbook and all other details for every cpu usage record coming from p_threadinfo_delta. For a given p_threadinfo_delta record we try to match it to p_serverlog_records and as such we try to figure out who was doing what when that CPU conspumption occured.
    * load_s_cpu_usage_vizql
    * load_s_cpu_usage_rest
    * load_s_cpu_usage_dataserver
    * load_s_cpu_usage_tabproto
    * load_s_cpu_usage_tdeserver
    * ins_stage_to_dwh

  4. p_cpu_usage_report has the same number of rows as in p_cpu_usage but based on id records in p_cpu_usage the details are filled from Tableau repository tables so that Tableau reporting does not have to deal with joins.

  5. p_interactor_session is aggregated from p_cpu_usage_report and has a single row of data for each vizql_session - process_type pairs in p_cpu_usage_report. For example if a session (12345) used vizqlserver and dataserver and tdeserver it will have three records for the session (12345) one for each process.

  6. p_serverlogs_bootstrap_rpt has the same data as p_serverlogs but limited to records that happened before the Bootstrap action in Tableau has ended.

  7. p_cpu_usage_bootstrap_rpt has the same data as p_cpu_usage_report but limited to records that happened before the Bootstrap action in Tableau has ended.

This workflow is defined in the `workflow_reporting.yml` for the daily load and `workflow_reporting_delta.yml` for the incremental load.

## How to test / develop

**IMPORTANT** When changes are made in the reporting tables or methods existing installation MUST be considered so migration needs to be created. Those migrations needs to change the function definitions, do the alter tables if necessary and make sure nothing will fail if a system is migrated that already has data loaded with former logic.

## Using the installer:

The ```insight-datamodel-install.sh``` script can be used to install or
migrate a DataModel version.

Basic usage:
(a full install followed by an upgrade).

```
# Install the data model v1.1.16
insight-datamodel-install.sh v1.1.16

# upgrade the data model to v1.1.17
insight-datamodel-install.sh v1.1.17
```


## Building an RPM package

By tagging your commit, travis will automatically create an RPM package
that'll be uploaded to the palette rpm server.

Adding this tag:

```
git tag -a v1.1.17 -m "Merry Supernova
* added something
* changed something
* even fixed some bugs"
```

