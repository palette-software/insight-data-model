create table db_version_meta (
    id serial,
    version_number text not null,
    cre_date timestamp not null    default now()
);
