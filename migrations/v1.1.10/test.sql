truncate table s_serverlogs_compressed;
truncate table s_cpu_usage;


delete from staging."p_serverlogs_1_prt_20160425_2_prt_WIN-FPC6VT52C21";

delete from staging.p_serverlogs
				 where 
					(substr(filename, 1, 11) = 'tabprotosrv' or substr(filename, 1, 10) = 'dataserver')
					and ts >= (select staging.get_max_ts_date('staging', 'p_serverlogs'))
						
					

vacuum staging.p_serverlogs;


select manage_partitions('staging', 'p_serverlogs');


select load_p_serverlogs('staging');
/*select load_p_serverlogs_rest('staging');
select load_p_serverlogs_vizql('staging');
select load_s_serverlogs_dataserver('staging'); -- Ha to come after vizql
select load_s_serverlogs_tabproto('staging'); -- Have to come after dataserver 
*/



select * from staging.s_serverlogs;

select load_s_serverlogs_vizql_compressed('staging');
select load_s_serverlogs_tabproto_compressed('staging');
select load_s_serverlogs_dataserver_compressed('staging');

select load_s_cpu_usage_vizql('staging');
select load_s_cpu_usage_rest('staging');
select load_s_cpu_usage_tabproto('staging');
select load_s_cpu_usage_dataserver('staging');


--select load_s_cpu_usage('staging');

select process_name, count(1) from s_cpu_usage
group by process_name;


select distinct parent_process_type from s_cpu_usage
where process_name = 'tabprotosrv'
limit 1000;

select * from s_serverlogs_compressed;

select * from p_serverlogs 
where filename like '%tabprotosrv%'
limit 1000;

where parent_process_type = 'dataserver'
and parent_dataserver_session = '2624E2BB3CBD41D493C48D52B8D80795-0:0'




select * from p_serverlogs_kgz
where v like '%CreateServerProcess%'
and filename like '%dataserver%'
;
"ACTION: Created new dataserver session: 206622C018244B76AD6BA5692E154C18"
;

select * from serverlogs_
where sess like '206622C018244B76AD6BA5692E154C18%'
and v like '%CreateServerProcess%'
order by ts;




select *
from p_serverlogs_kgz
where filename like '%dataserver%'
and sess like '%206622C018244B76AD6BA5692E154C18%';


select * from p_serverlogs_kgz
where filename like '%tabproto%'
and ts >timestamp'2016-04-23 14:00:49.725'
order by ts
limit 10000;
--and parent_vizql_session like 'B6561E242E9B4CCF984B95923EC28B5E%'
--and parent_dataserver_session like '%206622C018244B76AD6BA5692E154C18%';
parent_datesrv: 54631A2EFE31416C8754DB9FCBF04988-0:0, 2624E2BB3CBD41D493C48D52B8D80795-0:0
;

select * from serverlogs
where sess = '2624E2BB3CBD41D493C48D52B8D80795-0:0';

select * from serverlogs
where --v like '%Created new dataserver%'
--and 
filename like '%vizqlserver%'
and v like '%54631A2EFE31416C8754DB9FCBF04988%'
;
