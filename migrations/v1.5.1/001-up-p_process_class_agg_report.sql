ALTER TABLE p_process_class_agg_report ADD COLUMN cpu_usage_cpu_time_consumption_seconds DOUBLE PRECISION DEFAULT NULL;
ALTER TABLE p_process_class_agg_report ADD COLUMN cpu_usage_memory_usage_bytes BIGINT DEFAULT NULL;
ALTER TABLE p_process_class_agg_report ADD COLUMN tableau_process BOOLEAN DEFAULT NULL;
