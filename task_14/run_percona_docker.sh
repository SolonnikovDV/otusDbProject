#!/bin/bash

# import percona image
docker pull bitnami/percona-mysql:latest

# run container from imported image
# set port
# set password for root user
docker run --name percona -p 3309:3306 -e MYSQL_ROOT_PASSWORD=pass -d bitnami/percona-mysql:latest

# enter into docker container under root
docker exec -it -u root -w  /root  percona /bin/bash

# go to mysql shell
mysql -u root -ppass

# create database
create database steam_rev;
use steam_rev;

# now run python script to upload dataset into db
python3 ~/PycharmProjects/otusDbProject/task_14/load_data_to_db.py