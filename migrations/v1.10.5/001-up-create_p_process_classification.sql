-- Very small table. 
-- Inentionally not distributed or columnar 
CREATE TABLE p_process_classification
(
  p_id                         BIGSERIAL,
  process_name                 TEXT unique,
  process_class                TEXT
);
