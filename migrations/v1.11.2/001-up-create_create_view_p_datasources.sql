create or replace function create_view_p_datasources(p_schema_name text) returns int as $$
declare
	rec record;
	var text;
	sel text; 
begin
	var := '';
	sel := '';
	
	for rec in (
		select 
			column_name
		from information_schema.columns c
		where c.table_schema = p_schema_name and
			c.table_name = 'h_datasources')
	loop
		var := var || '\tds.' || rec.column_name || ',\n';
	end loop;
	sel := 'CREATE OR REPLACE VIEW ' || p_schema_name || '.p_datasources AS \nselect \n';
	sel := sel || var;
	sel := sel || '	((p.name::text || '' (''::text) || p.id::text) || '')''::text AS project_name_id, 
	((s.name::text || '' (''::text) || s.id::text) || '')''::text AS site_name_id, 
	((wb_su.name::text || '' (''::text) || ds.owner_id::text) || '')''::text AS publisher_name_id, 
	((ds.name::text || '' (''::text) || ds.id::text) || '')''::text AS workbook_name_id, 
	''DATASOURCE''::text AS type 
from '|| p_schema_name ||'.h_datasources ds
	left outer join '|| p_schema_name ||'.h_projects p on (p.id = ds.project_id and p.site_id = ds.site_id and least(ds.p_valid_to, p.p_valid_to) >= greatest(ds.p_valid_from, p.p_valid_from)) 
	left outer join '|| p_schema_name ||'.h_sites s on (s.id = ds.site_id and least(ds.p_valid_to, s.p_valid_to) >= greatest(ds.p_valid_from, s.p_valid_from))
	left outer join '|| p_schema_name ||'.h_users wb_u on (wb_u.id  = ds.owner_id and wb_u.site_id = ds.site_id and least(ds.p_valid_to, wb_u.p_valid_to) >= greatest(ds.p_valid_from, wb_u.p_valid_from))
	left outer join '|| p_schema_name ||'.h_system_users wb_su on (wb_su.id = wb_u.system_user_id and least(ds.p_valid_to, wb_su.p_valid_to) >= greatest(ds.p_valid_from, wb_su.p_valid_from))
group by
';
	sel := sel || var;
	sel := sel || '	((p.name::text || '' (''::text) || p.id::text) || '')''::text, 
	((s.name::text || '' (''::text) || s.id::text) || '')''::text, 
	((wb_su.name::text || '' (''::text) || ds.owner_id::text) || '')''::text, 
	((ds.name::text || '' (''::text) || ds.id::text) || '')''::text, 
	''DATASOURCE''::text;';
	execute sel;
	return 0;
END; 
$$ LANGUAGE plpgsql;
