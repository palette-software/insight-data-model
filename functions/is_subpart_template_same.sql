CREATE or replace function is_subpart_template_same(p_schema_name text, p_table_name text, p_subpart_cols text) returns boolean
AS $$
declare
    v_subpart_cols text;
    
BEGIN

    v_subpart_cols := '';
    
    select lower(string_agg(partitionname, ',')) into v_subpart_cols
    from pg_partition_templates
    where 
        partitionname <> 'new_host' and
        schemaname = p_schema_name and
        tablename = p_table_name;
        
    if lower(p_subpart_cols) = v_subpart_cols then
        return true;
    else
        return false;
    end if;
    
END;
$$ LANGUAGE plpgsql;
