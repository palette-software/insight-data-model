CREATE TABLE s_http_requests_with_workbooks
(	
	site_id bigint,
	vizql_session varchar,
	repository_url varchar,
	workbook_id bigint,
	user_ip varchar,
	completed_at timestamp without time zone, 
	h_workbooks_p_id bigint,	
	h_projects_p_id bigint,
	publisher_h_users_p_id bigint,
	publisher_h_system_users_p_id bigint,
	h_sites_p_id bigint,
	interactor_h_users_p_id bigint,
	interactor_h_system_users_p_id bigint
)
	WITH (appendonly=true, orientation=column, compresstype=quicklz)
DISTRIBUTED BY (vizql_session);