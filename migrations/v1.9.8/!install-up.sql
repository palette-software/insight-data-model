\set ON_ERROR_STOP on
set search_path = '#schema_name#';
set role palette_palette_updater;

BEGIN;

delete from p_process_class_agg_report
where
	ts_rounded_15_secs >= date'2016-06-14';
	

CREATE OR REPLACE FUNCTION reload_p_process_class_agg_report() RETURNS bigint
AS $$
declare
	v_cnt int;
	c refcursor;
	rec record;
	v_sql text;	
	v_datum_text varchar;
begin	


	-- This is just a simple loop from 1 to 39.
	-- rec.d is not relevant.
	open  c for (select date'2016-06-12' + generate_series(1,39) as d 				 
				order by d desc);
	loop
		fetch c into rec;
		exit when not found;
		-- Just to see how we proceed
		raise notice 'I: %', rec.d;		
		
		select load_p_process_class_agg_report('palette');				
	end loop;
	close c;
	return 0;
END;
$$ LANGUAGE plpgsql;

select reload_p_process_class_agg_report();

drop FUNCTION reload_p_process_class_agg_report();

insert into db_version_meta(version_number) values ('v1.9.8');

COMMIT;
