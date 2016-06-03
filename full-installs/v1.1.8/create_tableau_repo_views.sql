CREATE or replace function create_tableau_repo_views(p_schema_name text) returns int
AS $$
declare	
	rec record;
	v_sql text;
begin	
	
		for rec in (select 'create or replace view ' || schemaname || '.' || substr(tablename, 3) || 
					' as select * from ' || schemaname || '.' || tablename || 
					' where p_active_flag = ''Y'';' as view_def
					from pg_tables
					where tablename like 'h#_%' escape '#'
					and schemaname = p_schema_name) 
		
		loop
		
			raise notice 'I: %', v_sql;
			v_sql := rec.view_def;
			
			execute v_sql;			
		end loop;
		
		return 0;
END;
$$ LANGUAGE plpgsql;