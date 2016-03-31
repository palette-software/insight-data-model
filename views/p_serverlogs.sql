create or replace view p_serverlogs (
		p_id
       , filename
       , host_name
       , ts
       , process_id
       , thread_id
       , sev
       , req
       , sess
       , site
       , username
	   , username_without_domain
       , k
       , v
)
as
SELECT p_id
       , filename
       , host_name
       , ts
       , pid
       , tid
       , sev
       , req
       , sess
       , site
       , "user" as username
	   , substr("user", position('\\' in "user") + 1) as username_without_domain
       , k
       , v
 FROM serverlogs;
 