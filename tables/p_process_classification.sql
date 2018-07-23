-- Very small table. 
-- Inentionally not distributed or columnar 
CREATE TABLE p_process_classification
(
  p_id                         BIGSERIAL,
  process_name                 TEXT unique,
  process_class                TEXT
);

INSERT INTO p_process_classification (process_name, process_class) VALUES ('7z', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('backgrounder', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('clustercontroller', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('dataserver', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('filestore', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('httpd', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('postgres', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('redis-server', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('searchserver', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('tabadmin', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('tabadminservice', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('tabadmsvc', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('tabadmwrk', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('tabcmd', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('tableau', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('tabprotosrv', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('tabrepo', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('tabspawn', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('tabsvc', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('tabsystray', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('tdeserver', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('tdeserver64', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('vizportal', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('vizqlserver', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('wgserver', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('zookeeper', 'Tableau');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('PaletteInsightAgent', 'Palette');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('PaletteInsightWatchdog', 'Palette');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('PaletteConsoleAgent', 'Palette');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('PaletteServiceAgent', 'Palette');
INSERT INTO p_process_classification (process_name, process_class) VALUES ('hyperd', 'Tableau');