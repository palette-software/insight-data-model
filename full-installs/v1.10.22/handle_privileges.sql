CREATE or replace function handle_privileges(p_schema_name text) returns int
AS $$
declare	
	rec record;
	v_sql text;
begin		
		-- tables, views
		for rec in (select 
							s.nspname schema_name, 
							c.relname rel_name, 
							c.relkind,
							r.rolname rel_owner,							
							case when c.relname not in ('ext_error_table') then
								'alter table ' || s.nspname || '.' || c.relname || ' owner to ' || 'palette_' || s.nspname || '_updater' 
								else
									''
							end as cmd_owner_to_palette,		
							case when 
									c.relname not like 'ext\\_%' and
									c.relname not like 's\\_%'				
								then
									'grant select on ' || s.nspname || '.' || c.relname || ' to palette_' || s.nspname || '_looker'
								else
									''
							end as cmd_select_to_looker		
					from pg_namespace  s 
						join pg_class c on (c.relnamespace = s.oid)
						join pg_roles r on (c.relowner = r.oid)
					where s.nspname = p_schema_name
						and c.relkind in ('r','v')
						and c.relchecks = 0						
					order by relkind desc, relname
					)
		loop
					
			v_sql := rec.cmd_owner_to_palette;
			raise notice 'I: %', v_sql;						
			execute v_sql;			
			
			v_sql := rec.cmd_select_to_looker;
			raise notice 'I: %', v_sql;						
			execute v_sql;
			
		end loop;
		
		-- functions
		
		for rec in (select 
						'alter function ' ||
							r.routine_schema ||'.'|| r.routine_name || '('|| string_agg(p.data_type, ',' order by p.ordinal_position) || ')' ||
						' owner to palette_' || r.routine_schema || '_updater' as cmd
					from 
						information_schema.routines r,
						information_schema.parameters p
					where 
						r.routine_schema = p_schema_name and						
						r.specific_name = p.specific_name and
						r.specific_schema = p.specific_schema 
					group by
					    r.specific_schema,
					    r.routine_schema,
						r.specific_name,
						r.routine_name
					)
		loop
			v_sql := rec.cmd;
			raise notice 'I: %', v_sql;						
			execute v_sql;		
		end loop;
				
		execute 'grant all on ' || p_schema_name || '.ext_error_table to palette_' || p_schema_name || '_updater';
		return 0;
END;
$$ LANGUAGE plpgsql;