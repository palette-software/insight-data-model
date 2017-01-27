CREATE or replace function create_s_tables(p_schema_name text) returns int
AS $$
declare    
    rec1 record;
    rec2 record;
    v_sql text;
    col_def text;
    distr text;
begin

    v_sql := '';

    for rec1 in (
        select 
            tablename,
            'create table ' || schemaname || '.' || 's_' || substr(tablename, 3)
            || '\n(\n\t' as beginning
        from 
            pg_tables
        where 
            tablename like 'h#_%' escape '#'
            and schemaname = p_schema_name)
    loop
        distr := '';
        col_def := '';        

        for rec2 in (
            select 
                c.ordinal_position,
                c.column_name,
                c.data_type 
                    || decode(c.data_type, 'character varying', 
                               ' (' || c.character_maximum_length || ')', 'numeric', 
                               ' (' || c.numeric_precision_radix || ',' || coalesce(c.numeric_scale, '0') || ')','') 
                    || ',\n\t' as col_d
            from
                information_schema.columns c
            where 
                c.table_name = rec1.tablename
                and c.table_schema = p_schema_name
                and c.column_name not in ('p_id', 'p_active_flag', 'p_valid_from', 'p_valid_to')
            order by c.ordinal_position asc)
        loop
            if rec2.ordinal_position = 3 then 
                distr := rec2.column_name;
            end if;
            col_def := col_def || rec2.column_name || ' ' || rec2.col_d;
        end loop;
        
        col_def := trim(trailing ',\n\t' from col_def);
        v_sql := rec1.beginning || col_def || '\n)\n' || 'DISTRIBUTED BY(' || distr || ')';
        
        raise notice 'I: %', v_sql;
        execute v_sql;
    end loop;

    return 0;
END;
$$ LANGUAGE plpgsql;
