CREATE or replace function create_p_background_jobs(p_schema_name text) returns int
AS $$
declare    
    rec record;
    v_sql text;
begin    

        v_sql := 'create table ' || p_schema_name || '.p_background_jobs ( 
                    p_id bigserial,
                    background_jobs_p_id bigint,
                    background_jobs_id bigint,
        ';
                                
        for rec in (select c.column_name || ' ' || c.data_type || decode(c.data_type, 'character varying', ' (' || c.character_maximum_length || ')',
                                                         'numeric', ' (' || c.numeric_precision_radix || ',' || coalesce(c.numeric_scale, '0') || ')',
                                                         '') || ',' as col_def
                    from
                        information_schema.columns c
                    where 
                        c.table_schema = p_schema_name and
                        c.table_name = 'background_jobs' and
                        c.column_name not in ('id', 'p_id', 'p_filepath', 'p_cre_date')
                    order by
                        c.ordinal_position)
        loop              
              v_sql := v_sql || rec.col_def || '\n';
              
        end loop;
        
        v_sql := v_sql ||
                '"date_hour" timestamp without time zone,
                "workbooks_datasources_id" Bigint,
                "workbooks_datasources_name" Character varying(255),
                "publisher_id" int,
                "publisher_name" Character varying(255),
                "publisher_friendlyname" Character varying(255),
                "project_id" int,
                "project_name" Character varying(255),
                "site_name" Character varying(255),
                "wd_type" Character varying(255),
                "h_projects_p_id" Bigint,
                "h_workbooks_datasources_p_id" Bigint,
                "h_system_users_p_id" Bigint,
                "h_users_p_id" Bigint,
                "h_sites_p_id" Bigint,
                "p_cre_date timestamp default now()';
                
        v_sql := v_sql || ')
        WITH (APPENDONLY=TRUE, ORIENTATION=COLUMN, COMPRESSTYPE=QUICKLZ)
        DISTRIBUTED BY (p_id)
        PARTITION BY RANGE (created_at)
        (PARTITION "100101"
            START (date ''1001-01-01'') INCLUSIVE
            END (date ''1001-02-01'') EXCLUSIVE
        WITH (appendonly=true, orientation=column, compresstype=quicklz)
        )';
                
        raise notice 'I: %', v_sql;
        execute v_sql;
        
        return 0;
END;
$$ LANGUAGE plpgsql;
