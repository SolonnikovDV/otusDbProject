#!/bin/bash

# run connection to data base and call system information
psql postgresql://pg-user:pg-pass@localhost:5432/otus-project -c \
"SELECT version(),
pg_postmaster_start_time(),
user, pg_backend_pid(),
inet_server_port()"

psql postgresql://pg-user:pg-pass@localhost:5432/otus-project -c \
"SELECT version(),
pg_postmaster_start_time(),
user, pg_backend_pid(),
inet_server_port()"

psql postgresql://pg-user:pg-pass@localhost:5432/otus-project -c \
"SELECT version(),
pg_postmaster_start_time(),
user, pg_backend_pid(),
inet_server_port()"

# displays roles with attributes
psql postgresql://pg-user:pg-pass@localhost:5432/otus-project -c \
"SELECT usename AS role_name,
  CASE
     WHEN usesuper AND usecreatedb THEN
	    CAST('superuser, create database' AS pg_catalog.text)
     WHEN usesuper THEN
	    CAST('superuser' AS pg_catalog.text)
     WHEN usecreatedb THEN
	    CAST('create database' AS pg_catalog.text)
     ELSE
	    CAST('' AS pg_catalog.text)
  END role_attributes
FROM pg_catalog.pg_user
ORDER BY role_name desc;"

# show all tables in data base
echo "Do you want to browse data base schema"
select yn in "Yes" "No"; do
  case $yn in
  Yes)
    psql postgresql://pg-user:pg-pass@localhost:5432/otus-project -c \
      "SELECT table_schema , table_name
      FROM information_schema.tables
      WHERE table_schema not in ('information_schema', 'pg_catalog')
			AND table_type = 'BASE TABLE'
      ORDER BY table_schema, table_name;"
    break
    ;;
  No)
    exit
    ;;
  esac
  # goto psql shell
  psql postgresql://pg-user:pg-pass@localhost:5432/otus-project
done