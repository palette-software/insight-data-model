CREATE OR REPLACE FUNCTION load_s_high_load_threads(p_schema_name TEXT, p_threshold FLOAT)
  RETURNS BIGINT
AS $$
DECLARE
  v_sql               TEXT;
  v_num_inserted      BIGINT := 0;
  v_num_inserted_host BIGINT := 0;
  v_from_for_host     TEXT;
  v_sql_cur           TEXT;
  rec                 RECORD;
  v_max_tho_p_id      BIGINT;
BEGIN

  EXECUTE 'set local search_path = ' || p_schema_name;

  FOR rec IN (SELECT DISTINCT host_name
              FROM
                p_threadinfo_delta)
  LOOP

    -- Get last day that is already laoded
    v_sql_cur := 'select to_char(coalesce(max(ts_rounded_15_secs), date''1001-01-01''), ''yyyy-mm-dd'') from p_high_load_threads where host_name = ''#host_name#''';
    v_sql_cur := replace(v_sql_cur, '#host_name#', rec.host_name);
    EXECUTE v_sql_cur
    INTO v_from_for_host;

    -- Get max tho_p_id from target table. Use last day to improve query performance
    v_sql_cur := 'select coalesce(max(tho_p_id), 0)
                        from
                            p_high_load_threads
                        where
                            host_name = ''#host_name#''
                            and ts_rounded_15_secs >= date''#v_from_for_host#''
                    ';

    v_sql_cur := replace(v_sql_cur, '#host_name#', rec.host_name);
    v_sql_cur := replace(v_sql_cur, '#v_from_for_host#', v_from_for_host);
    EXECUTE v_sql_cur
    INTO v_max_tho_p_id;

    -- This loading method is far from perfect. There are flaws in it by design (for performance purposes):
    --    When a "minute" is not complete during the load (the last minute of the batch), that can either have higher or smaller
    --    average load than the threashold. And if it is smaller than those values might be ignored forever and after (if there is a above treshold value in the same
    --    batch with bigger p_id.)
    --    The other case is if the first half of the minute is above threshold we add that thread to the suspicious list but it might come below threshold with the
    --    other part of the minute.
    --    UTC midnight issues are not handled nor even thought about at this point.
    v_sql :=
    'insert into s_high_load_threads (
      tho_p_id,
      threadinfo_id,
      host_name,
      process_name,
      ts,
      ts_rounded_15_secs,
      ts_date,
      process_id,
      thread_id,
      start_ts,
      cpu_time_ticks,
      cpu_time_delta_ticks,
      ts_interval_ticks,
      cpu_core_consumption,
      memory_usage_bytes,
      memory_usage_delta_bytes,
      is_thread_level,
      p_cre_date,
      write_operation_count,
      other_operation_count,
      read_operation_count,
      read_transfer_count,
      write_transfer_count,
      other_transfer_count,
      read_operation_count_delta,
      write_operation_count_delta,
      other_operation_count_delta,
      read_transfer_count_delta,
      write_transfer_count_delta,
      other_transfer_count_delta
        )
    select
         ptd.p_id as tho_p_id,
         ptd.threadinfo_id,
         ptd.host_name,
         ptd.process_name,
         ptd.ts,
         ptd.ts_rounded_15_secs,
         ptd.ts_date,
         ptd.process_id,
         ptd.thread_id,
         ptd.start_ts,
         ptd.cpu_time_ticks,
         ptd.cpu_time_delta_ticks,
         ptd.ts_interval_ticks,
         ptd.cpu_core_consumption,
         ptd.memory_usage_bytes,
         ptd.memory_usage_delta_bytes,
         ptd.is_thread_level,
         ptd.p_cre_date,
         ptd.write_operation_count,
         ptd.other_operation_count,
         ptd.read_operation_count,
         ptd.read_transfer_count,
         ptd.write_transfer_count,
         ptd.other_transfer_count,
         ptd.read_operation_count_delta,
         ptd.write_operation_count_delta,
         ptd.other_operation_count_delta,
         ptd.read_transfer_count_delta,
         ptd.write_transfer_count_delta,
         ptd.other_transfer_count_delta
    from
          palette.p_threadinfo_delta ptd
        INNER JOIN
            (SELECT DISTINCT
              host_name,
              start_ts,
              process_id,
              thread_id
            FROM (
				      SELECT
				        i.host_name,
				        i.start_ts,
				        i.process_id,
				        i.thread_id,
				        avg(i.cpu_core_consumption)                AS consumption,
				        date_trunc(''minute'', i.ts_rounded_15_secs) AS minute
				      FROM palette.p_threadinfo_delta i
				      WHERE 1 = 1
				            AND thread_id <> -1
                    and ts_rounded_15_secs >= date''#v_from_for_host#''
                    and host_name = ''#host_name#''
				      GROUP BY host_name, start_ts, process_id, thread_id, minute
				      HAVING 1 = 1
				        and avg(i.cpu_core_consumption) > #p_threshold#
				      union all
				      select distinct
				        host_name,
				        start_ts,
				        process_id,
				        thread_id,
				        null,
				        null
				      from p_high_load_threads phl
				      where 1 = 1
                    and host_name = ''#host_name#''
                    and ts_rounded_15_secs >= date''#v_from_for_host#''
				    ) grouped
				) kept
				ON 1 = 1
				   AND ptd.host_name = kept.host_name
				   AND ptd.process_id = kept.process_id
				   AND ptd.thread_id = kept.thread_id
				   AND ptd.start_ts = kept.start_ts
		where 1 = 1
        and ptd.ts_rounded_15_secs >= date''#v_from_for_host#''
        and ptd.host_name = ''#host_name#''
        and ptd.p_id > #v_max_tho_p_id#


    ';

    v_sql := replace(v_sql, '#v_from_for_host#', v_from_for_host);
    v_sql := replace(v_sql, '#host_name#', rec.host_name);
    v_sql := replace(v_sql, '#v_max_tho_p_id#', v_max_tho_p_id);
    v_sql := replace(v_sql, '#p_threshold#', p_threshold);

    RAISE NOTICE 'I: %', v_sql;

    EXECUTE v_sql;
    GET DIAGNOSTICS v_num_inserted_host = ROW_COUNT;

    v_num_inserted := v_num_inserted + v_num_inserted_host;

  END LOOP;

  RETURN v_num_inserted;
END;
$$ LANGUAGE plpgsql;
