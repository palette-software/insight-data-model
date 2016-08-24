alter table p_serverlogs_bootstrap_rpt rename to p_serverlogs_bootstrap_rpt_old;
\i -up-p_serverlogs_bootstrap_rpt.sql
insert into s_serverlogs_bootstrap_rpt select * from p_serverlogs_bootstrap_rpt_old;
select manage_partitions('palette', 'p_serverlogs_bootstrap_rpt');
drop table p_serverlogs_bootstrap_rpt_old;