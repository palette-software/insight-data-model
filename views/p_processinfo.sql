create view p_processinfo as
select * from p_threadinfo
where    
    thread_id = -1;
