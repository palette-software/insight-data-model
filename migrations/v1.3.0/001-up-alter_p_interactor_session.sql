alter table p_interactor_session 
	add init_show_bootstrap_normal boolean DEFAULT NULL;
alter table p_interactor_session 
	add show_count integer DEFAULT NULL;
alter table p_interactor_session 
	add bootstrap_count integer DEFAULT NULL;
alter table p_interactor_session 
	add show_elapsed_secs double precision DEFAULT NULL;
alter table p_interactor_session 
	add bootstrap_elapsed_secs double precision DEFAULT NULL;
alter table p_interactor_session 
	add show_bootstrap_delay_secs double precision DEFAULT NULL;

