CREATE or replace function create_p_threadinfo_delta(p_schema_name text) returns int
AS $$
declare
    v_sql text;            
    rec record;    
    v_col_list text;
begin    

        execute 'set local search_path = ' || p_schema_name;

        v_col_list := '';
        
        for rec in (select 
                        c.column_name || ' ' ||
                                    c.data_type || decode(c.data_type, 'character varying', ' (' || c.character_maximum_length || ')',
                                                         'numeric', ' (' || c.numeric_precision_radix || ',' || coalesce(c.numeric_scale, '0') || ')',
                                                         '') || ',' as col_def
                    from information_schema.columns c
                     where
                         c.table_name = 'p_threadinfo' and
                        c.table_schema = p_schema_name and
                        c.column_name not in ('p_id', 'p_cre_date')
                     order by
                         ordinal_position
                    )
        loop
            
            v_col_list := v_col_list || ' ' || rec.col_def;
            
        end loop;
                        
                
        v_sql := '
        create table p_threadinfo_delta ( 
            p_id bigserial,
        ' ||
            v_col_list        
        ||
            'p_cre_date timestamp without time zone default now()'
        ||
        ')
        WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
        DISTRIBUTED BY (host_name, process_id, thread_id)
        PARTITION BY RANGE (ts_rounded_15_secs)
        SUBPARTITION BY LIST (host_name)
        SUBPARTITION TEMPLATE (SUBPARTITION init VALUES (''init'')
        WITH (appendonly=true, orientation=column, compresstype=quicklz))
        (PARTITION "10010101" START (date ''1001-01-01'') INCLUSIVE
            END (date ''1001-01-02'') EXCLUSIVE 
        WITH (appendonly=true, orientation=column, compresstype=quicklz)
        )
        ';
        
        raise notice 'I: %', v_sql;
        execute v_sql;
        
        return 0;
END;
$$ LANGUAGE plpgsql;
