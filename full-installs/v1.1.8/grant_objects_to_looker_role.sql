CREATE or replace function grant_objects_to_looker_role(p_schema_name text) returns int
AS $$
declare	
	rec record;
	v_sql text;
begin	
	
		for rec in (select 'grant select on ' || schemaname || '.' || tablename || ' to palette_' || schemaname || '_looker' as grt
					from pg_tables
					where
						schemaname = p_schema_name and
						tablename not like 'ext%' and
						tablename not like '%\_prt\_%' and
						tablename not like 's\_%' and
						tablename not in ('db_version_meta', 'ptalend_flows', 'ptalend_logs', 'ptalend_stats')
					)
		loop
		
			v_sql := rec.grt;
			raise notice 'I: %', v_sql;
						
			execute v_sql;			
		end loop;
		
		return 0;
END;
$$ LANGUAGE plpgsql;