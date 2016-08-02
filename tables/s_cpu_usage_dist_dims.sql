CREATE TABLE s_cpu_usage_dist_dims AS 
select 
		h_projects_p_id, 
		h_sites_p_id, 
		interactor_h_system_users_p_id, 
		h_workbooks_p_id, 
		publisher_h_users_p_id, 
		publisher_h_system_users_p_id
from
 		p_cpu_usage cpu
where
		1=2