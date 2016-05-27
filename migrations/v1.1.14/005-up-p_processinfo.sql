create view p_processinfo as
select * from palette.p_threadinfo
where	
	thread_id = -1;

grant select on p_processinfo to palette_palette_looker;

