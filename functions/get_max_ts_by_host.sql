CREATE OR REPLACE FUNCTION get_max_ts_by_host(p_schema_name text, p_table_name text, p_host_name text, p_column_name text) RETURNS timestamp 
AS $$
declare
    v_sql text;    
    v_max_timestamp timestamp;
    v_column_name varchar;
    rec record;
    v_host_name text;
begin

        v_host_name := lower(p_host_name);
        v_max_timestamp := null;

        for rec in (select
                        a.e
                    from
                        (
                        select 
                            'select max(' || p_column_name || ') from ' || schemaname || '."' || partitiontablename || '"' as e
                        from pg_partitions
                        where tablename = p_table_name and
                              schemaname = p_schema_name and
                              lower(partitionname) = v_host_name
                        ) a
                        where
                            a.e is not null
                        order by e desc
                    )
                    
        loop
            execute rec.e into v_max_timestamp;
            exit when v_max_timestamp is not null;
        end loop;                    
    
        if (v_max_timestamp is null) then
            v_sql :='select coalesce(max(' || p_column_name || '), date''1001-01-01'')
                     from ' 
                        || p_schema_name || '.'  || p_table_name ||
                    ' where  
                        lower(host_name) = ''' || v_host_name || '''';
                                
                         
             execute v_sql into v_max_timestamp;
        end if;

        return v_max_timestamp;        
end;
$$ LANGUAGE plpgsql;
