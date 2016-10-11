CREATE TABLE hist_comments
(
	p_id bigserial,
	p_filepath text,
	id INTEGER,
	comment_id INTEGER,
	comment TEXT,
	p_cre_date timestamp without time zone default now()
)
	WITH (appendonly=true, orientation=row, compresstype=quicklz)
DISTRIBUTED BY (p_id);


