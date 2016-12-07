CREATE or replace function load_s_tde_filename_pids(p_schema_name text, p_load_date date) returns bigint
AS $$
declare	
	v_sql text;
	v_num_inserted bigint := 0;
    v_num_inserted_all bigint := 0;
    v_load_date_txt text := to_char(p_load_date, 'yyyy-mm-dd');
begin	

	execute 'set local search_path = ' || p_schema_name;
    
    perform check_if_load_date_already_in_table(p_schema_name, 's_tde_filename_pids', p_load_date, true);
       
	v_sql := '
	insert into s_tde_filename_pids 
		(host_name,
		file_prefix,
		pid,
		ts_from,
		ts_to)
	select
		host_name,
		file_prefix,
		pid::bigint,
		ts as ts_from,
		coalesce(lead(ts) over (partition by host_name, file_prefix order by ts), date''9999-12-31'') as ts_to
	from
	(
	  SELECT
	  	host_name,
	    substring(filename FROM ''^[a-z_]+[0-9]+'') AS file_prefix,
	    substr(line, 5) AS pid,
	    ts
	  FROM
	    plainlogs
	  WHERE 1 = 1
        and ts >= date''#v_load_date_txt#'' + interval''2 hours''
        and ts < date''#v_load_date_txt#'' + interval''26 hours''
	    and line LIKE ''pid=%''
	  GROUP BY 
	  	host_name,
		substring(filename FROM ''^[a-z_]+[0-9]+''),  		   
		substr(line, 5),
		ts
	) b    
	';
			                        
	v_sql := replace(v_sql, '#v_load_date_txt#', v_load_date_txt);
    raise notice 'I: %', v_sql;
    execute v_sql;        
	GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
    v_num_inserted_all := v_num_inserted_all + v_num_inserted;
    
    v_sql := '
    update s_tde_filename_pids as t
    set
        ts_to = s.ts_from
    from         
        (select
            ts_from,            
            host_name,
            file_prefix,
            row_number() over (partition by host_name, file_prefix order by ts_from) as rn
        from
            s_tde_filename_pids
        where 1 = 1
            and ts_from >= date''#v_load_date_txt#'' + interval''2 hours''
            and ts_from < date''#v_load_date_txt#'' + interval''26 hours''
        )s
    where 1 = 1
        and t.ts_from < date''#v_load_date_txt#'' + interval''2 hours''
        and t.ts_to = date''9999-12-31''
        and s.rn = 1
        and t.host_name = s.host_name
        and t.file_prefix = s.file_prefix
    ';

    v_sql := replace(v_sql, '#v_load_date_txt#', v_load_date_txt);
    raise notice 'I: %', v_sql;
    execute v_sql;
    
	GET DIAGNOSTICS v_num_inserted = ROW_COUNT;
    v_num_inserted_all := v_num_inserted_all + v_num_inserted;
    
    delete from s_tde_filename_pids
    where 1 = 1
        and ts_to <= p_load_date - interval'30 days';
    
    vacuum analyze s_tde_filename_pids;
    
	return v_num_inserted_all;

END;
$$ LANGUAGE plpgsql;