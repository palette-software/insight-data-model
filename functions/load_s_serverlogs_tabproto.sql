CREATE or replace function load_s_serverlogs_tabproto(p_schema_name text, p_load_date date) returns bigint
AS $$
declare
	v_sql text;
	v_num_inserted bigint;
    v_load_date_txt text := to_char(p_load_date, 'yyyy-mm-dd');
begin	

	execute 'set local search_path = ' || p_schema_name;
    
    perform check_if_load_date_already_in_table(p_schema_name, 'p_serverlogs', p_load_date, true);
	
	v_sql := 
	'insert into s_serverlogs (
			serverlogs_id,
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
			parent_dataserver_session,
			spawned_by_parent_ts,
			parent_vizql_destroy_sess_ts,
			parent_process_type,
			parent_vizql_site,
			parent_vizql_username,
			parent_dataserver_site,
			parent_dataserver_username,
			elapsed_ms,
			start_ts					
	)			
	
	with t_s_spawner as
		(select
			sl.spawner_process_type,
			sl.spawner_host_name,
			sl.spawner_session,
			sl.spawned_tabproto_process_id,
			sl.spawned_tabproto_process_id_ts,
			tinfo.start_ts,
			case when spawner_process_type = ''vizqlserver'' then sl.spawner_vizql_destroy_sess_ts
				 when spawner_process_type = ''dataserver'' then ds.parent_vizql_destroy_sess_ts
			end as spawner_ts_destroy_sess,					
			ds.parent_vizql_session as parent_ds_vizql_session,										
			case when spawner_process_type = ''vizqlserver'' then sl.parent_site
				 when spawner_process_type = ''dataserver'' then ds.parent_vizql_site
			end as parent_vizql_site,					
			case when spawner_process_type = ''vizqlserver'' then sl.parent_username
				 when spawner_process_type = ''dataserver'' then ds.parent_vizql_username
			end as parent_vizql_username,					
			case when spawner_process_type = ''vizqlserver'' then null
				 when spawner_process_type = ''dataserver'' then parent_site
			end as parent_dataserver_site,					
			case when spawner_process_type = ''vizqlserver'' then null
				 when spawner_process_type = ''dataserver'' then parent_username
			end as parent_dataserver_username										
		from
			(select distinct
						process_name as spawner_process_type,
						slog.host_name as spawner_host_name,
						slog.site as spawner_site,
						slog.sess as spawner_session,
						case when v like ''%CreateServerProcess%'' then (replace(substr(slog.v, position(''pid'' in slog.v) + 4), ''"'', ''''))::bigint end as spawned_tabproto_process_id,
						slog.ts as spawned_tabproto_process_id_ts,								
						max(case when k = ''destroy-session'' then ts end) over (partition by host_name, sess) as spawner_vizql_destroy_sess_ts,
						parent_vizql_destroy_sess_ts,
						case when v like ''%CreateServerProcess%'' then true else false end as keep_this_line,
						slog.site as parent_site,
						slog.username_without_domain as parent_username
			from ( 				
				select filename,
						host_name,
						site,
						sess,
						ts,
						k,
						v,
						parent_vizql_destroy_sess_ts,
						username_without_domain,
                        process_name
				from
						s_serverlogs
				where
					process_name in (''vizqlserver'', ''dataserver'') and
					(v like ''%CreateServerProcess%'' or k = ''destroy-session'')	
				) slog
			) sl
			
			left outer join (select 
                                    host_name,
									sess,
									max(parent_vizql_destroy_sess_ts) as parent_vizql_destroy_sess_ts,
									max(parent_vizql_session) as parent_vizql_session,
									max(parent_vizql_site) as parent_vizql_site,
									max(parent_vizql_username) as parent_vizql_username
							from (
								select 
                                        host_name,
										sess,
										parent_vizql_destroy_sess_ts,
										parent_vizql_session,
										parent_vizql_site,
										parent_vizql_username 
								from
										s_serverlogs
								where
									process_name = ''dataserver''
								) u									
							group by
								  host_name,
								  sess
							) ds on (ds.host_name = sl.spawner_host_name and
                                    ds.sess = sl.spawner_session)
			left outer join	(select distinct 
								host_name, 
								process_id, 
								start_ts
						from
								p_threadinfo_delta
						where
							thread_id = -1 and
							ts_rounded_15_secs >= date''#v_load_date_txt#'' - interval''24 hours'' and
							process_name = ''tabprotosrv''
						) tinfo on (tinfo.host_name = sl.spawner_host_name and 
									tinfo.process_id = sl.spawned_tabproto_process_id)
			where
				sl.keep_this_line
		)

		select 
				  a.p_id		
				, a.p_filepath
				, a.filename
				, replace(case when position(''_'' in a.filename) > 0 then substr(a.filename, 1, position(''_'' in a.filename) -1) else a.filename end, ''.txt'', '''') as process_name
				, a.host_name
				, a.ts
				, a.process_id
				, a.thread_id
				, a.sev
				, a.req
				, a.sess
				, a.site
				, a."user"
				, substr(a."user", position(''\\\\'' in a."user") + 1) as username_without_domain
				, a.k
				, a.v						
				, decode(a.spawner_process_type, 
							''vizqlserver'', 
								case 
									 when a.start_ts = min(a.start_ts) over (partition by a.spawner_process_type, a.spawner_session, a.spawned_tabproto_process_id_ts, a.host_name, a.process_id) then
										a.spawner_session
									else ''-'' 
				  				end
							,''dataserver'',										
								a.parent_ds_vizql_session										
						, null) as parent_vizql_session
				 , decode(a.spawner_process_type, ''dataserver'', case when a.start_ts = min(a.start_ts) over (partition by a.spawner_process_type, a.spawner_session, a.spawned_tabproto_process_id_ts, a.host_name, a.process_id) then
						a.spawner_session
					else ''-''
				  end, null) as parent_dataserver_session
				, case when a.spawner_process_type = ''vizqlserver'' and a.ts > a.spawner_ts_destroy_sess then null
						else a.spawned_tabproto_process_id_ts
				  end as spawned_by_parent_ts
				, case when a.spawner_process_type = ''vizqlserver'' and a.ts > a.spawner_ts_destroy_sess then null 
						else a.spawner_ts_destroy_sess
				  end as parent_vizql_destroy_sess_ts
				, case when a.spawner_process_type = ''vizqlserver'' and a.ts > a.spawner_ts_destroy_sess then null 
						else a.spawner_process_type
				  end as parent_process_type
				, a.parent_vizql_site as parent_vizql_site
				, a.parent_vizql_username as parent_vizql_username
				, a.parent_dataserver_site as parent_dataserver_site
				, a.parent_dataserver_username as parent_dataserver_username
				, a.elapsed_ms
				, a.log_start_ts as start_ts
		from
			(
			select 	
					  s_spawner.spawner_process_type
					, s_spawner.spawner_session		
					, s_spawner.spawned_tabproto_process_id_ts
					, s_spawner.spawner_ts_destroy_sess
					, s_spawner.parent_ds_vizql_session
					, s_spawner.parent_vizql_site
					, s_spawner.parent_vizql_username
					, s_spawner.parent_dataserver_site
					, s_spawner.parent_dataserver_username
					, s_spawner.start_ts
					, s_tabproto.p_id	
					, s_tabproto.p_filepath
					, s_tabproto.filename
					, s_tabproto.host_name
					, s_tabproto.ts
					, s_tabproto.pid as process_id
					, s_tabproto.tid as thread_id
					, s_tabproto.sev
					, s_tabproto.req
					, s_tabproto.sess
					, s_tabproto.site
					, s_tabproto.user							
					, s_tabproto.k
					, s_tabproto.v
					, row_number() over (partition by s_tabproto.p_id order by s_spawner.spawned_tabproto_process_id_ts desc, 
																			   s_spawner.start_ts desc) rn
					, s_tabproto.elapsed_ms
					, s_tabproto.start_ts as log_start_ts
			from
				serverlogs s_tabproto
				left outer join t_s_spawner s_spawner on (s_tabproto.host_name = s_spawner.spawner_host_name and 
														 s_tabproto.pid = s_spawner.spawned_tabproto_process_id and 
														 s_tabproto.ts >= s_spawner.spawned_tabproto_process_id_ts and 
														 s_tabproto.ts >= s_spawner.start_ts)						
			where
				substr(s_tabproto.filename, 1, 11) = ''tabprotosrv'' and
				s_tabproto.ts >= date''#v_load_date_txt#'' and 
				s_tabproto.ts <= date''#v_load_date_txt#'' + interval''26 hours''
			) a
		where 
			rn = 1
	'
	;
						
	v_sql := replace(v_sql, '#v_load_date_txt#', v_load_date_txt);	
						
	raise notice 'I: %', v_sql;

	execute v_sql;		
	GET DIAGNOSTICS v_num_inserted = ROW_COUNT;			

	return v_num_inserted;

END;
$$ LANGUAGE plpgsql;