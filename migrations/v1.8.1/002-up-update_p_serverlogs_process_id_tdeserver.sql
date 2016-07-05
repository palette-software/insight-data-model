 insert into p_serverlogs
 ( 
p_filepath,
filename,
process_name,
host_name,
ts,
process_id,
thread_id,
sev,
req,
sess,
site,
username,
username_without_domain,
k,
v,
parent_vizql_session,
parent_vizql_destroy_sess_ts,
parent_dataserver_session,
spawned_by_parent_ts,
parent_process_type,
parent_vizql_site,
parent_vizql_username,
parent_dataserver_site,
parent_dataserver_username,
thread_name,
elapsed_ms,
start_ts,
session_start_ts_utc,
session_end_ts_utc,
site_name_id,
project_name_id,
workbook_name_id,
workbook_rev,
publisher_username_id,
p_id,
p_cre_date)
select p_filepath,
s.filename,
process_name,
host_name,
ts,
t1.process_id,
thread_id,
sev,
req,
sess,
site,
username,
username_without_domain,
k,
v,
parent_vizql_session,
parent_vizql_destroy_sess_ts,
parent_dataserver_session,
spawned_by_parent_ts,
parent_process_type,
parent_vizql_site,
parent_vizql_username,
parent_dataserver_site,
parent_dataserver_username,
thread_name,
elapsed_ms,
start_ts,
session_start_ts_utc,
session_end_ts_utc,
site_name_id,
project_name_id,
workbook_name_id,
workbook_rev,
publisher_username_id,
p_id,
p_cre_date
from p_serverlogs s
left join 
(select distinct filename, process_id from
(select pl0.filename, coalesce(max(case when pl0.line like 'pid=%' then substr(pl0.line, 5) end) over (partition by pl0.filename),  substr(pids.line, 5))::bigint as process_id,
                                row_number() over (partition by pl0.p_id order by pl0.ts desc) as rn
                                from plainlogs pl0
                                left join
                                (select filename, line, ts from plainlogs where line like 'pid=%') pids                            
                                on substring(pl0.filename from 'tdeserver_[a-z]+server_[0-9]+')
                                 = substring(pids.filename from 'tdeserver_[a-z]+server_[0-9]+')
                                 and pl0.ts >= pids.ts
                                 where (pl0.filename like 'tdeserver_vizqlserver%' or pl0.filename like 'tdeserver_dataserver%')
) t where rn = 1
) t1
on s.filename = t1.filename
where (s.filename like 'tdeserver_vizql%' or s.filename like 'tdeserver_dataserver%')
and s.process_id is null
;

delete from p_serverlogs s where
(s.filename like 'tdeserver_vizql%' or s.filename like 'tdeserver_dataserver%')
and s.process_id is null
;

                                 