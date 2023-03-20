<h3>Task 8</h3>
<br>

<h3><A name="содержание">Содержание:</A></h3>
<h4><A href="#get_docker_image">1. Установить докер-образ mysql</A></h4>
<h4><A href="#create-db">2. Создать базу даных</A></h4>
<hr>

<br>
<h3><A name="get_docker_image">1. Установить докер-образ mysql</A></h3>
<h6><A href="#содержание">назад в содержание</A></h6>

<h4><tt># download docker image from git 'https://github.com/aeuge/otus-mysql-docker' </tt><br>
<tt># go to your local docker images directory</tt><br>
<tt># run next:</tt><br>
<tt>> gh repo clone aeuge/otus-mysql-docker</tt><br>
<br>
<tt># go into 'aeuge/otus-mysql-docker' and run:</tt><br>
<tt>> docker-compose up otusdb -d</tt></h4>

<h4><tt># enter to mysql:</tt><br>
<tt>> mysql -u root -p12345 --port=3309 --protocol=tcp otus</tt></h4>
<br>
<img src="https://github.com/SolonnikovDV/otusDbProject/blob/master/task_9/screens/01_create_db.png">

<h3><A name="create-db">2. Создать базу даныхa и настроить пременные 'buffer'</A></h3>
<h6><A href="#содержание">назад в содержание</A></h6>

<h4>2.1. Создать базу данных otus_testdb</h4>
<h4><tt>-- create db 'otus_testdb':</tt><br>
<tt>CREATE DATABASE IF NOT EXISTS otus_testdb;</tt><h4>

<h4>2.2 Настроить переменные 'buffer': innodb_buffer_pool_sizea и innodb_buffer_pool_instances</h4>
<h4><tt>-- check 'buffer' vars:</tt><br>
<tt>SHOW variables LIKE '%buffer%';</tt></h4>
<h4><tt>-- will get the next table:</tt></h4>

| Variable_name                       | Value          |
|-------------------------------------|----------------|
| bulk_insert_buffer_size             | 8388608        |
| innodb_buffer_pool_chunk_size       | 134217728      |
| innodb_buffer_pool_dump_at_shutdown | ON             |
| innodb_buffer_pool_dump_now         | OFF            |
| innodb_buffer_pool_dump_pct         | 25             |
| innodb_buffer_pool_filename         | ib_buffer_pool |
| innodb_buffer_pool_in_core_file     | ON             |
| **innodb_buffer_pool_instances**    | **1**          |
| innodb_buffer_pool_load_abort       | OFF            |
| innodb_buffer_pool_load_at_startup  | ON             |
| innodb_buffer_pool_load_now         | OFF            |
| **innodb_buffer_pool_size**         | **134217728**  |
| innodb_change_buffer_max_size       | 25             |
| innodb_change_buffering             | all            |
| innodb_log_buffer_size              | 16777216       |
| innodb_sort_buffer_size             | 1048576        |
| join_buffer_size                    | 262144         |
| key_buffer_size                     | 8388608        |
| myisam_sort_buffer_size             | 8388608        |
| net_buffer_length                   | 16384          |
| preload_buffer_size                 | 32768          |
| read_buffer_size                    | 131072         |
| read_rnd_buffer_size                | 262144         |
| sort_buffer_size                    | 262144         |
| sql_buffer_result                   | OFF            |

<h4><tt>-- check current value of innodb_buffer_pool_size:</tt><br>
<tt>SELECT @@innodb_buffer_pool_size/1024/1024 AS 'InnoDB Buffer Pool Size in MByte';</tt><br>
<tt>-- check current value of innodb_buffer_pool_size:</tt><br>
<tt>SELECT @@innodb_buffer_pool_instances AS 'InnoDB Buffer Pool Instance';</tt><br>
<br>
<tt>-- increase innodb_buffer_pool_size from 128 Mb to 2Gb (128 * 16 = 2048Mb):</tt><br>
<tt>SET GLOBAL innodb_buffer_pool_size = (SELECT @@innodb_buffer_pool_chunk_size) * 16;</tt><br>
<br>
<tt>-- to check new status of innodb_buffer_pool_size and innodb_buffer_pool_instances:</tt><br>
<tt>SELECT @@innodb_buffer_pool_size/1024/1024 AS 'InnoDB Buffer Pool Size in MByte';</tt><br>
<br>
<br>
<img src="https://github.com/SolonnikovDV/otusDbProject/blob/master/task_8/screens/03_buffer_pool_size_and_instance.png">

**```-- NOTICE: all changes will drops after restart server```** 
<br>
**```-- if it need to save vars values, file 'my.cnf' should de be changed```**

<h4>2.3 Сохранение кастомных настроек переменных 'buffer' </h4>
<h4><tt>-- for the reason that innodb_buffer_pool_instances is a read only variable</tt><br>
<tt>-- it could be changed only in /etc/mysql/my.cnf with server restart</tt><br>
<tt>-- run into terminal</tt><br>
<tt>-- > vi /etc/mysql/my.cnf</tt><br>
<tt>-- and add next strings after [mysqld]:</tt><br>
<tt>-- # innodb_buffer_pool_instances=2</tt><br>
<tt>-- # innodb_buffer_pool_size= 2147483648</tt><br>

<tt>-- restart mysql server services</tt><br>
<tt>-- > sudo service mysql restart</tt><br>

<tt>-- check innodb_buffer_pool_instances:</tt><br>
<tt>SELECT @@innodb_buffer_pool_size/1024/1024 AS 'InnoDB Buffer Pool Size in MByte';</tt><br>
<tt>SELECT @@innodb_buffer_pool_instances AS 'InnoDB Buffer Pool Instance';</tt></h4>
<br>
<img src="https://github.com/SolonnikovDV/otusDbProject/blob/master/task_8/screens/04_changing_my.conf.png">
