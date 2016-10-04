CREATE VIEW p_srvlogs_bootstrap_r_multiline AS 
WITH t_base AS (
    SELECT 
        p_id,
        ts,
        start_ts,
        process_name, 
        parent_vizql_session,
        k,
        string_to_array(v, '\\n ') AS v_array,
        array_upper(string_to_array(v, '\\n '), 1) AS v_array_length
    FROM p_serverlogs_bootstrap_rpt
    )    
    
SELECT 
    b.p_id,
    g.i AS line_num,
    b.ts, 
    b.start_ts, 
    b.process_name, 
    b.parent_vizql_session,
    b.k, 
    b.v_array[g.i] AS v_line_value 
FROM 
    t_base b
    inner join (SELECT 
                    t.p_id,
                    t.start_ts, 
                    generate_series(1, t.v_array_length) AS i
                FROM 
                    t_base t) g ON b.p_id = g.p_id AND b.start_ts = g.start_ts
;