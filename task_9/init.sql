-- create db 'otus_testdb':
CREATE DATABASE IF NOT EXISTS otus_testdb;

-- check 'buffer' vars:
SHOW variables LIKE '%buffer%';
-- will get the next table:

| Variable_name                           | Value              |
|-----------------------------------------|--------------------|
| bulk_insert_buffer_size                 | 8388608            |
| **innodb_buffer_pool_chunk_size**       | **134217728**      |
| innodb_buffer_pool_dump_at_shutdown     | ON                 |
| innodb_buffer_pool_dump_now             | OFF                |
| innodb_buffer_pool_dump_pct             | 25                 |
| innodb_buffer_pool_filename             | ib_buffer_pool     |
| innodb_buffer_pool_in_core_file         | ON                 |
| **innodb_buffer_pool_instances**        | **1**              |
| innodb_buffer_pool_load_abort           | OFF                |
| innodb_buffer_pool_load_at_startup      | ON                 |
| innodb_buffer_pool_load_now             | OFF                |
| **innodb_buffer_pool_size**             | **134217728**      |
| innodb_change_buffer_max_size           | 25                 |
| innodb_change_buffering                 | all                |
| innodb_log_buffer_size                  | 16777216           |
| innodb_sort_buffer_size                 | 1048576            |
| join_buffer_size                        | 262144             |
| key_buffer_size                         | 8388608            |
| myisam_sort_buffer_size                 | 8388608            |
| net_buffer_length                       | 16384              |
| preload_buffer_size                     | 32768              |
| read_buffer_size                        | 131072             |
| read_rnd_buffer_size                    | 262144             |
| sort_buffer_size                        | 262144             |
| sql_buffer_result                       | OFF                |
|-----------------------------------------|--------------------|

-- check current value of innodb_buffer_pool_size:
SELECT @@innodb_buffer_pool_size/1024/1024 AS 'InnoDB Buffer Pool Size in MByte';
-- check current value of innodb_buffer_pool_size:
SELECT @@innodb_buffer_pool_instances AS 'InnoDB Buffer Pool Instance';

-- increase innodb_buffer_pool_size from 128 Mb to 2Gb (128 * 16 = 2048Mb):
SET GLOBAL innodb_buffer_pool_size = (SELECT @@innodb_buffer_pool_chunk_size) * 16;

-- to check new status of innodb_buffer_pool_size and innodb_buffer_pool_instances:
SELECT @@innodb_buffer_pool_size/1024/1024 AS 'InnoDB Buffer Pool Size in MByte';

-- NOTICE: all changes will drops after restart server
-- if it need to save vars values, file 'my.cnf' should de be changed



-- for the reason that innodb_buffer_pool_instances is a read only variable
-- it could be changed only in /etc/mysql/my.cnf with server restart
-- run into terminal
-- > vi /etc/mysql/my.cnf
-- and add next strings after [mysqld]:
-- # innodb_buffer_pool_instances=2
-- # innodb_buffer_pool_size= 2147483648

-- restart mysql server services
-- > sudo service mysql restart

-- check innodb_buffer_pool_instances:
SELECT @@innodb_buffer_pool_size/1024/1024 AS 'InnoDB Buffer Pool Size in MByte';
SELECT @@innodb_buffer_pool_instances AS 'InnoDB Buffer Pool Instance';