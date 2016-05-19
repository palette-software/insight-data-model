
select * from staging.db_version_meta
order by 1 desc;

select * from staging.serverlogs
limit 10;


alter table p_serverlogs add column elapsed_ms bigint default 0;
alter table p_serverlogs add column start_ts timestamp without time zone default null;
alter table s_serverlogs add column elapsed_ms bigint default null;
alter table s_serverlogs add column start_ts timestamp without time zone default null;

update p_serverlogs set start_ts = ts where start_ts is null;


delete from staging.p_serverlogs
where ts >= now()::date
 
 
select * from staging.serverlogs
where ts >= now()::date
and elapsed_ms is not null
limit 10