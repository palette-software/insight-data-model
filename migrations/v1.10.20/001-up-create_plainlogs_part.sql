CREATE or replace function create_plainlogs_part(p_schema_name text, p_table_name text) returns int
AS $$
declare
	v_sql_cur text;
	c refcursor;
	rec record;
	v_sql text;
	v_max_ts_date_p_threadinfo text;
	v_max_ts_date_p_serverlogs text;
	v_subpart_cols text;
    v_table_name text;    
BEGIN

		v_subpart_cols := '';
		execute 'set local search_path = ' || p_schema_name;
		
        v_table_name := lower(p_table_name);
        
		v_sql_cur := '';
		v_sql := '';
		
		v_sql_cur := 'select distinct ts::date d from ' || 'plainlogs_old';
		
		open c for execute (v_sql_cur);
			loop
				  fetch c into rec;
				  exit when not found;
				  
				  v_sql := 'ALTER TABLE #schema_name#.#table_name# 
				  		         ADD PARTITION "#partition_name#" START (date''#start_date#'') INCLUSIVE END (date''#end_date#'') EXCLUSIVE WITH (appendonly=true, orientation=column, compresstype=quicklz)';

				  v_sql := replace(v_sql, '#schema_name#', p_schema_name);
				  v_sql := replace(v_sql, '#table_name#', v_table_name);
				
				  v_sql := replace(v_sql, '#partition_name#', to_char(rec.d, 'yyyymmdd'));
				  v_sql := replace(v_sql, '#start_date#', to_char(rec.d, 'yyyy-mm-dd'));
				  v_sql := replace(v_sql, '#end_date#', to_char(rec.d + 1, 'yyyy-mm-dd'));
				
                
				begin
					execute v_sql;						
				end;
				
				 raise notice 'I: %', v_sql;
			end loop;
			close c;
	
	return 0;

END;
$$ LANGUAGE plpgsql;