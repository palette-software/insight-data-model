drop view palette.p_srvlogs_bootstrap_r_multiline;

create view palette.p_srvlogs_bootstrap_r_multiline as
with t_base as
(select 
        p_id,
        ts,
        start_ts,
        parent_vizql_session,
        k,
        string_to_array(v, '\\n ') as v_array,
        array_upper(string_to_array(v, '\\n '), 1) as v_array_length
from 
    palette.p_serverlogs_bootstrap_rpt
)

select 
    b.p_id,
    g.i as v_line_id,
    b.ts,
    b.start_ts,
    b.parent_vizql_session,
    b.k,
    b.v_array,
    b.v_array_length,
    b.v_array[g.i] as v_one_line
from
    t_base b
    inner join (select
                    p_id,
                    start_ts,
                    generate_series(1, t.v_array_length) as i
                from
                    t_base t
                ) g on (b.p_id = g.p_id and b.start_ts = g.start_ts)  
;

select *
from
(
select * from palette.p_srvlogs_bootstrap_r_multiline
where  start_ts > now()::date - 2
) a
limit 10
;


grant select on palette.p_srvlogs_bootstrap_r_multiline to palette_palette_looker;








        
        
