#! /bin/bash

# connect to db
docker exec -it sql-outs-project psql postgresql://pg-user:pg-pass@localhost:5432/otus-project

# into docker container

# change postgresql.conf
cd /var/lib/postgresql/data
vi postgresql.conf
## changing:
### listen_addresses = 'localhost, 127.0.0.1'
### wal_level = replica
### max_wal_senders = 2
### max_replication_slots = 2
### hot_standby = on
### hot_standby_feedback = on

# change pg_hba.conf
cd /var/lib/postgresql/data
# vi pg_hba.conf
## add to end of file:
### host replication all 127.0.0.1 scram-sha-256

# restart docker container
docker container restart sql-outs-project

# connect to db
docker exec -it sql-outs-project psql postgresql://pg-user:pg-pass@localhost:5432/otus-project

# create cluster with current version of postgres (using postgres v14) on a port different of main instance
sudo pg_createcluster -d /home/cluster/otus_cluster/ 14 otus_cluster -p 5433
# deleting files in a cluster dir
sudo rm -R /home/cluster/otus_cluster/*
# start backup database
pg_basebackup -R -U replicauser -D /home/cluster/otus_cluster/ -p 5432
# or start backup database under replication role user
sudo pg_basebackup -p 5432 -U replicauser -X stream -C -S otus_cluster -v -R -W -D /home/cluster/otus_cluster/
# solve permission issue
sudo chown -R  postgres:postgres /home/cluster/otus_cluster/*

# start cluster
sudo pg_ctlcluster 14 otus_cluster start
# check cluster status
pg_lsclusters
# enter into replica db
sudo -u postgres psql -p 5433 -d otus-project

# create db replica_trest on master-cluster
create database replica_test
# crete table random_table on master-cluster
CREATE table random_table as SELECT TO_CHAR(day, 'YYYY-MM-DD') as date, (1000 + 500*random())*log(row_number() over()) as value FROM generate_series
        ( '2017-02-01'::date,
        '2017-04-01'::date,
        '1 day'::interval) day;






