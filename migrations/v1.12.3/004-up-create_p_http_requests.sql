CREATE or replace function create_p_http_requests(p_schema_name text) returns int
AS $$
declare	
	rec record;
	v_sql text;
begin	

		v_sql := 'create table ' || p_schema_name || '.p_http_requests ( 
					p_id bigserial,
                    http_requests_p_id bigint,
					http_requests_id bigint,
		';
								
		for rec in (select c.column_name || ' ' || c.data_type || decode(c.data_type, 'character varying', ' (' || c.character_maximum_length || ')',
														 'numeric', ' (' || c.numeric_precision_radix || ',' || coalesce(c.numeric_scale, '0') || ')',
														 '') || ',' as col_def
					from
						information_schema.columns c
					where 
						c.table_schema = p_schema_name and
						c.table_name = 'http_requests' and
						c.column_name not in ('id', 'p_id', 'p_filepath', 'p_cre_date')
					order by
						c.ordinal_position)
		loop			  
			  v_sql := v_sql || rec.col_def || '\n';
			  
		end loop;
		
		v_sql := v_sql ||
				'"site_name" Character varying(255),
				 "interactor_user_id" Decimal(10,0),
				 "interactor_system_users_id" Decimal(10,0),
				 "interactor_username" Character varying(255),
				 "interactor_friendly_name" Character varying(255),
				 "workbook_id" Decimal(10,0),
				 "workbook_name" Character varying(255),
				 "workbook_repository_url" Text,
				 "publisher_user_id" Decimal(10,0),
				 "project_id" Decimal(10,0),
				 "publisher_system_users_id" Decimal(10,0),
				 "publisher_username" Character varying(255),
				 "publisher_friendly_name" Character varying(255),
				 "project_name" Character varying(255),
				 "created_at_month" Date,
				 "h_projects_p_id" Bigint,
				 "publisher_h_users_p_id" Bigint,
				 "publisher_h_system_users_p_id" Bigint,
				 "h_sites_p_id" Bigint,
				 "h_workbooks_p_id" Bigint,
				 "interactor_h_users_p_id" Bigint,
				 "interactor_h_system_users_p_id" Bigint,
                 "view_id" int';
				
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