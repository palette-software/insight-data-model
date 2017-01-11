create or replace function create_view_p_workbooks(p_schema_name text) returns int as $$
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
            c.table_name = 'h_workbooks'
            order by ordinal_position)
    loop
        var := var || '\twb.' || rec.column_name || ',\n';
    end loop;
    sel := 'CREATE OR REPLACE VIEW ' || p_schema_name || '.p_workbooks AS \nselect \n';
    sel := sel || var;
    sel := sel || 
    'p.name || '' ('' || p.id || '')'' AS project_name_id,
     p.name AS project_name,
     s.name AS site_name,
     s.name || '' ('' || s.id || '')'' AS site_name_id,
     wb.owner_id as publisher_id,
     wb_su.name as publisher_name,
     wb_su.name || '' ('' || wb.owner_id || '')'' AS publisher_name_id,
     wb.name || '' ('' || wb.id || '')'' AS workbook_name_id, 
     ''WORKBOOK''::text AS type 
from '|| p_schema_name ||'.h_workbooks wb
    left outer join '|| p_schema_name ||'.h_projects p on (p.id = wb.project_id and p.site_id = wb.site_id and least(wb.p_valid_to, p.p_valid_to) >= greatest(wb.p_valid_from, p.p_valid_from)) 
    left outer join '|| p_schema_name ||'.h_sites s on (s.id = wb.site_id and least(wb.p_valid_to, s.p_valid_to) >= greatest(wb.p_valid_from, s.p_valid_from))
    left outer join '|| p_schema_name ||'.h_users wb_u on (wb_u.id  = wb.owner_id and wb_u.site_id = wb.site_id and least(wb.p_valid_to, wb_u.p_valid_to) >= greatest(wb.p_valid_from, wb_u.p_valid_from))
    left outer join '|| p_schema_name ||'.h_system_users wb_su on (wb_su.id = wb_u.system_user_id and least(wb.p_valid_to, wb_su.p_valid_to) >= greatest(wb.p_valid_from, wb_su.p_valid_from))
group by
';
    sel := sel || var;
    sel := sel || 
    'p.name || '' ('' || p.id || '')'',
     p.name,
     s.name,
     s.name || '' ('' || s.id || '')'',
     wb.owner_id,
     wb_su.name,
     wb_su.name || '' ('' || wb.owner_id || '')'',
     wb.name || '' ('' || wb.id || '')''
    ';
    execute sel;
    return 0;
END; 
$$ LANGUAGE plpgsql;
