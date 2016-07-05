
CREATE or replace function load_s_serverlogs_tdeserver(p_schema_name text) returns bigint
AS $$
declare	
	v_sql text;
	v_num_inserted bigint;	
	v_sql_cur text;
	v_max_ts_date_p_serverlogs text;	
	v_max_ts_date_p_threadinfo text;
	v_max_ts_p_threadinfo text;	
begin	

			execute 'set local search_path = ' || p_schema_name;
			
			v_sql_cur := 'select to_char((select get_max_ts_date(''#schema_name#'', ''p_serverlogs'')), ''yyyy-mm-dd'')';
			v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);
			execute v_sql_cur into v_max_ts_date_p_serverlogs;
			v_max_ts_date_p_serverlogs := 'date''' || v_max_ts_date_p_serverlogs || '''';
									
			v_sql_cur := 'select to_char((select get_max_ts(''#schema_name#'', ''p_threadinfo'')), ''yyyy-mm-dd hh:mi:ss.ms'')';
			v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);			
			execute v_sql_cur into v_max_ts_p_threadinfo;
			v_max_ts_p_threadinfo := 'timestamp''' || v_max_ts_p_threadinfo || '''';									
									
			v_sql_cur := 'select to_char((select get_max_ts_date(''#schema_name#'', ''p_threadinfo'')), ''yyyy-mm-dd'')';
			v_sql_cur := replace(v_sql_cur, '#schema_name#', p_schema_name);			
			execute v_sql_cur into v_max_ts_date_p_threadinfo;
			v_max_ts_date_p_threadinfo := 'date''' || v_max_ts_date_p_threadinfo || '''';			
			
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
					parent_vizql_destroy_sess_ts,
					parent_dataserver_session,
					spawned_by_parent_ts,
					parent_process_type,
					parent_vizql_site,
					parent_vizql_username,
					parent_dataserver_site,
					parent_dataserver_username,
					elapsed_ms,
					start_ts
			)			
			
			with t_s_spawner as
                (
                    select
                                slog.host_name as spawner_host_name,
                                max(slog.site) as parent_vizql_site,
								slog.sess as spawner_session,        
								max(slog.username_without_domain) as parent_vizql_username,
                                max(parent_vizql_destroy_sess_ts) as parent_vizql_destroy_sess_ts                          
                    from 
                        (select host_name,
                                max(site) as site,
                                sess,
								max(username_without_domain) as username_without_domain,
                                max(case when k = ''destroy-session'' then ts end) as parent_vizql_destroy_sess_ts
                        from
                            p_serverlogs
                        where
                            (filename like ''vizqlserver%'' or filename like ''dataserver%'') and
                            ts >= (#max_ts_date_p_serverlogs# - interval ''1 day'')
						group by
							host_name,
                            sess
							
                        union all                        
						
                        select  host_name,
                                max(site) as site,
                                sess,
								max(username_without_domain) as username_without_domain,
                                max(case when k = ''destroy-session'' then ts end) as parent_vizql_destroy_sess_ts
                        from
                            s_serverlogs
                        where
                            (filename like ''vizqlserver%'' or filename like ''dataserver%'')
						group by
							host_name,
                            sess
                        ) slog
						group by
							host_name,
                            sess
				),
				
				session_map as (
					select
						tid,
						sessid,
						first_p_id,
						coalesce(lead(first_p_id) over (partition by filename, session_uid order by ts, p_id) - 1, max_file_p_id) as last_p_id,
						ts_start,
						coalesce(lead(ts) over (partition by filename, session_uid order by ts, p_id), max_file_ts) as ts_end,
						session_uid,
						filename
					from
					(
						select
							p_id,
							pid as tid,
							ts,
							line,
							substr(line, position(''sessionid='' in line) + 10, 36) as sessid,
							lag(p_id) over (partition by filename, pid order by ts, p_id) as first_p_id,
							lag(substr(line, 1, greatest(position('':'' in line) - 1, 1))) over (partition by filename, pid order by ts, p_id) as session_uid,
							lag(ts) over (partition by filename, pid order by ts, p_id) as ts_start,
							filename,
							max(p_id) over (partition by filename) as max_file_p_id,
							max(ts) over (partition by filename) as max_file_ts
						from 
							plainlogs p
						where 
							ts >= (#max_ts_date_p_serverlogs# - interval ''1 day'')
							and (filename like ''tdeserver_vizqlserver%'' or filename like ''tdeserver_dataserver%'')
					) t
					where line like ''(queryband%''
				)
				select * 
				from 
					(select 
							p_id,
							pl.p_filepath,
							pl.filename,
							replace(case when position(''_'' in pl.filename) > 0 then substr(pl.filename, 1, position(''_'' in pl.filename) -1) else pl.filename end, ''.txt'', '''') as process_name,
							pl.host_name,
							pl.ts,
							pl.process_id as pid,
							pl.pid as tid,
							null as sev,
							null as req,
							null as sess,
							null as site,
							null as user,
							null as username_without_domain,
							null as k,
							pl.line as v,
							case when pl.filename like ''tdeserver_vizqlserver%'' then sm.sessid end as parent_vizql_session,
							sp.parent_vizql_destroy_sess_ts as parent_vizql_destroy_sess_ts,
							case when pl.filename like ''tdeserver_dataserver%'' then sm.sessid end as parent_dataserver_session,
							sm.ts_start as spawned_by_parent_ts,
							case when pl.filename like ''tdeserver_vizqlserver%'' then ''vizqlserver''
								 when pl.filename like ''tdeserver_dataserver%'' then  ''dataserver''
							end as parent_process_type,
							case when pl.filename like ''tdeserver_vizqlserver%'' then sp.parent_vizql_site end as parent_vizql_site,
							case when pl.filename like ''tdeserver_vizqlserver%'' then sp.parent_vizql_username end as parent_vizql_username,
							case when pl.filename like ''tdeserver_dataserver%'' then sp.parent_vizql_site end as parent_dataserver_site,
							case when pl.filename like ''tdeserver_dataserver%'' then sp.parent_vizql_username end as parent_dataserver_username,
							pl.elapsed_ms,
							pl.start_ts					
					from (select pl0.*, coalesce(max(case when pl0.line like ''pid=%'' then substr(pl0.line, 5) end) over (partition by pl0.filename),  substr(pids.line, 5))::bigint as process_id,
                                row_number() over (partition by pl0.p_id order by pl0.ts desc) as rn
                                from plainlogs pl0
                                left join
                                (select filename, line, ts from plainlogs where line like ''pid=%'') pids                            
                                on substring(pl0.filename from ''tdeserver_[a-z]+server_[0-9]+'')
                                 = substring(pids.filename from ''tdeserver_[a-z]+server_[0-9]+'')
                                 and pl0.ts >= pids.ts
                                 where (pl0.filename like ''tdeserver_vizqlserver%'' or pl0.filename like ''tdeserver_dataserver%'')
                 ) pl
						left join session_map sm on pl.filename = sm.filename
						  							and pl.line like (sm.session_uid || '':%'')
						  							and pl.p_id between sm.first_p_id and sm.last_p_id
													
						left join t_s_spawner sp on sp.spawner_session = sm.sessid
						
					where pl.ts >= #max_ts_date_p_serverlogs# - interval ''1 day''
							and pl.filename like ''tdeserver%''
                            and pl.rn = 1
			) t 
			where 
				t.ts >= #max_ts_date_p_serverlogs# and
				t.ts <= #max_ts_p_threadinfo# + interval''15 sec''
			';
			
		v_sql := replace(v_sql, '#max_ts_date_p_serverlogs#', v_max_ts_date_p_serverlogs);
		v_sql := replace(v_sql, '#max_ts_date_p_threadinfo#', v_max_ts_date_p_threadinfo);
		v_sql := replace(v_sql, '#max_ts_p_threadinfo#', v_max_ts_p_threadinfo);
		
		raise notice 'I: %', v_sql;	

		execute v_sql;		
		GET DIAGNOSTICS v_num_inserted = ROW_COUNT;			

		return v_num_inserted;

END;
$$ LANGUAGE plpgsql;