CREATE or replace function load_p_background_jobs(p_schema_name text) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;
	
begin	
		v_sql := 
				'insert into #schema_name#.p_background_jobs
				(
					background_jobs_id,
					job_type,
					progress,
					args,
					notes,
					updated_at,
					created_at,
					completed_at,
					started_at,
					date_hour,
					job_name,
					finish_code,
					priority,
					title,
					created_on_worker,
					processed_on_worker,
					link,
					lock_version,
					backgrounder_id,
					serial_collection_id,
					site_id,
					subtitle,
					language,
					locale,
					workbooks_datasources_id,
					workbooks_datasources_name,
					publisher_name,
					publisher_friendlyname,
					project_name,
					site_name,
					wd_type,
					h_projects_p_id,
					h_workbooks_datasources_p_id,
					h_system_users_p_id,
					h_users_p_id,
					h_sites_p_id
				)

				SELECT DISTINCT
				  background_jobs.id,
				  background_jobs.job_type,
				  background_jobs.progress,
				  background_jobs.args,
				  background_jobs.notes,
				  background_jobs.updated_at,
				  background_jobs.created_at,
				  background_jobs.completed_at,
				  background_jobs.started_at,
				  DATE_TRUNC(''hour'',background_jobs.started_at) date_hour,
				  background_jobs.job_name,
				  background_jobs.finish_code,
				  background_jobs.priority,
				  background_jobs.title,
				  background_jobs.created_on_worker,
				  background_jobs.processed_on_worker,
				  background_jobs.link,
				  background_jobs.lock_version,
				  background_jobs.backgrounder_id,
				  background_jobs.serial_collection_id,
				  background_jobs.site_id,
				  background_jobs.subtitle,
				  background_jobs.language,
				  background_jobs.locale,
				  workbooks_datasources.workbooks_datasources_id,
				  workbooks_datasources.workbooks_datasources_name,
				  workbooks_datasources.publisher_name,
				  workbooks_datasources.publisher_friendlyname,
				  workbooks_datasources.project_name,
				  sites.name site_name,
				  workbooks_datasources.wd_type,
				  projects_p_id,
				  workbooks_datasources_p_id,
				  system_users_p_id,
				  users_p_id,
				  sites.p_id sites_p_id
				FROM  
				  #schema_name#.background_jobs
				  LEFT JOIN 
				  (
				    SELECT DISTINCT
				      workbooks_datasources.wd_type,
				      workbooks_datasources.workbooks_datasources_id,
				      workbooks_datasources.name workbooks_datasources_name,
				      system_users.name publisher_name,
				      system_users.friendly_name publisher_friendlyname,
				      projects.name project_name,
				      projects.p_valid_from AS projects_p_valid_from,
				      projects.p_valid_to AS projects_p_valid_to,
				      projects.p_id AS projects_p_id,
				      workbooks_datasources.p_valid_from AS workbooks_datasources_p_valid_from,
				      workbooks_datasources.p_valid_to AS workbooks_datasources_p_valid_to,
				      workbooks_datasources.p_id AS workbooks_datasources_p_id,
				      system_users.p_valid_from AS system_users_p_valid_from,
				      system_users.p_valid_to AS system_users_p_valid_to,
				      system_users.p_id AS system_users_p_id,
				      users.p_valid_from AS users_p_valid_from,
				      users.p_valid_to AS users_p_valid_to,
				      users.p_id AS users_p_id
				    FROM
				      (
				        SELECT
				          ''Workbook'' wd_type,
				          h_workbooks.id workbooks_datasources_id,
				          h_workbooks.name,
				          h_workbooks.owner_id,
				          h_workbooks.project_id,
				          h_workbooks.p_valid_from,
				          h_workbooks.p_valid_to,
				          h_workbooks.p_id
				        FROM #schema_name#.h_workbooks 
				        UNION ALL
				        SELECT
				          ''Datasource'' wd_type,
				          h_datasources.id workbooks_datasources_id,
				          h_datasources.name,
				          h_datasources.owner_id,
				          h_datasources.project_id,
				          h_datasources.p_valid_from,
				          h_datasources.p_valid_to,
				          h_datasources.p_id
				        FROM #schema_name#.h_datasources 
				      ) workbooks_datasources,
				      (
				        SELECT 
				          id, 
				          system_user_id,
				          p_valid_from,
				          p_valid_to,
				          p_id
				        FROM #schema_name#.h_users 
				      ) users,
				      (
				        SELECT 
				          id, 
				          name, 
				          friendly_name,
				          p_valid_from,
				          p_valid_to,
				          p_id
				        FROM #schema_name#.h_system_users 
				      ) system_users,
				      (
				        SELECT 
				          id, 
				          name,
				          p_valid_from,
				          p_valid_to,
				          p_id
				        FROM #schema_name#.h_projects 
				      ) projects
				    WHERE
				      workbooks_datasources.owner_id=users.id AND 
				      users.system_user_id=system_users.id AND 
				      workbooks_datasources.project_id=projects.id
				  ) workbooks_datasources 
				  ON 
				    background_jobs.title = workbooks_datasources.workbooks_datasources_name AND 
				    background_jobs.subtitle = workbooks_datasources.wd_type
				    AND background_jobs.updated_at BETWEEN projects_p_valid_from AND projects_p_valid_to
				    AND background_jobs.updated_at BETWEEN workbooks_datasources_p_valid_from AND workbooks_datasources_p_valid_to
				    AND background_jobs.updated_at BETWEEN system_users_p_valid_from AND system_users_p_valid_to
				    AND background_jobs.updated_at BETWEEN users_p_valid_from AND users_p_valid_to
				  LEFT JOIN 
				  (
				    SELECT 
				      id, 
				      name,
				      p_valid_from,
				      p_valid_to,
				      p_id
				    FROM #schema_name#.h_sites 
				  ) sites 
				  ON sites.id = background_jobs.site_id
				  AND background_jobs.updated_at BETWEEN sites.p_valid_from AND sites.p_valid_to				
				';
	


		v_sql := replace(v_sql, '#schema_name#', p_schema_name);		
		raise notice 'I: %', v_sql;

		execute v_sql;
		
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
			
		return v_num_inserted;
END;
$$ LANGUAGE plpgsql;