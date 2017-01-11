create or replace view p_workbook_datasource_size
(
    id,
    type,
    date,
    size_bytes,
    p_id
) as

select    
    u.id,
    u.workbook_datasource_type,    
    u.date,
    u.size_bytes,
    u.p_id as workbook_datasource_p_id
from (            
                select 
                    'WORKBOOK' as workbook_datasource_type,
                    num_days_in_hist.date,
                    wb.p_id,
                    wb.id,
                    wb.size as size_bytes                    
                from
                    (select 
                            id,
                            min_date -1 + generate_series(1, a.num_days + 1)  date
                        from
                        (
                            select
                                id,
                                min(created_at)::date min_date,
                                max(p_valid_from)::date max_date,
                                case when max(p_active_flag) = 'Y' then
                                    (now()::date - min(created_at::date))::int 
                                else
                                    (max(p_valid_to::date) - min(created_at::date))::int 
                                end as num_days
                            from                            
                                h_workbooks    
                            group by
                                id
                        ) a
                     ) num_days_in_hist
                    inner join h_workbooks wb on (wb.id = num_days_in_hist.id and 
                                                               case when num_days_in_hist.date = wb.created_at::date
                                                                       then
                                                                                wb.created_at 
                                                                        else
                                                                                num_days_in_hist.date
                                                                    end between wb.p_valid_from and wb.p_valid_to)                    
                
            union all
                        
                select 
                    'DATASOURCE' as workbook_datasource_type,
                    num_days_in_hist.date,
                    ds.p_id,
                    ds.id,
                    ds.size as size_bytes                    
                from
                    (select 
                            id,
                            min_date -1 + generate_series(1, a.num_days + 1)  date
                        from
                        (
                            select
                                id,
                                min(created_at)::date min_date,
                                max(p_valid_from)::date max_date,
                                case when max(p_active_flag) = 'Y' then
                                    (now()::date - min(created_at::date))::int 
                                else
                                    (max(p_valid_to::date) - min(created_at::date))::int 
                                end as num_days
                            from                            
                                h_datasources
                            group by
                                id
                        ) a
                     ) num_days_in_hist
                    inner join h_datasources ds on (ds.id = num_days_in_hist.id and 
                                                                case when num_days_in_hist.date = ds.created_at::date
                                                                         then
                                                                                ds.created_at 
                                                                        else
                                                                                num_days_in_hist.date
                                                                    end between ds.p_valid_from and ds.p_valid_to)                    
    ) u        
;
