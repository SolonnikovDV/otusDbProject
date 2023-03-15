#! /bin/bash

# connect to db
docker exec -it sql-outs-project psql postgresql://pg-user:pg-pass@localhost:5432/replica_logical

# into docker container

# change postgresql.conf
cd /var/lib/postgresql/data
vi postgresql.conf
## changing:
### wal_level = logical

# or use next query
ALTER SYSTEM SET wal_level = logical;

# restart docker container
docker container restart sql-outs-project

# connect to docker-container
docker exec -it sql-outs-project
# create cluster for logical replication
sudo pg_createcluster -d /home/cluster/otus_cluster_logical/ 14 otus_cluster_logical -p 5431
# start cluster
sudo pg_ctlcluster 14 otus_cluster_logical start
# check cluster status
pg_lsclusters

# change wal level on replica cluster and rester cluster
ALTER SYSTEM SET wal_level = logical;

# check max_publication_slots;
show max_replication_slots;
SELECT slot_name, slot_type, active FROM pg_replication_slots;

# increase max_publication_slots
alter system set max_replication_slots = '4';
# restart

# on a master
# create table in db from csv file
docker cp 'Shoe prices.csv' sql-outs-project:/home/
create table shoe_prices (brand varchar, model varchar, type varchar, gender varchar, size varchar, color varchar, material varchar, price varchar);
COPY shoe_prices (brand, model, type, gender, size, color, material, price)
FROM '/home/shoe_prices.csv'
DELIMITER ','
CSV HEADER;

# create publication
create publication test_pub for table shoe_prices;

# enter into replica cluster
sudo -u postgres psql -p 5431
# create db and table on a subscriber side
create database db_test;
create table shoe_prices (brand varchar, model varchar, type varchar, gender varchar, size varchar, color varchar, material varchar, price varchar);

# create subscription on logic replica cluster
create subscription test
connection 'host=localhost port=5432 dbname=replica_logical user=pg-user password=pg-pass'
publication test with (copy_data=true);

# insert values into table on master and check if te table on slave is changed:
insert into shoe_prices values ('new_brand', 'new_model', 'some_type', 'unknown_gender', 'super_size', 'deep_color', 'nasa_material', 'huge_price');