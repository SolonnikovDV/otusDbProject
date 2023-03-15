<h1>Task 8</h1>
<br>


<h1><A name="содержание">Содержание:</A></h1>
<h2><A href="#data-download-from">1. Настроить физическую репликации между двумя кластерами базы данных</A></h2>
<h2><A href="#create-indexes">2. Настроить логическую репликации между двумя кластерами базы данных</A></h2>
<hr>

<br>
<h2><A name="data-download-from">1. Настроить физическую репликации между двумя кластерами базы данных</A></h2>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>
<h3>Демонстрационый стенд собирается на Docker.</h3>
<h3>1. Подготовка конфигурационных файлов:</h3>
<h3>1.1. Подготовка конфигурационных файлов:</h3>
<h3><tt># change postgresql.conf</tt><br>
<tt>cd /var/lib/postgresql/data</tt><br>
<tt>vi postgresql.conf</tt><br>
<tt>## changing:</tt><br>
<tt>## listen_addresses = 'localhost, 127.0.0.1'</tt><br>
<tt>## wal_level = replica</tt><br>
<tt>## max_wal_senders = 2</tt><br>
<tt>## max_replication_slots = 2</tt><br>
<tt>## hot_standby = on</tt><br>
<tt>## hot_standby_feedback = on</tt></h3>

<h3><tt># change pg_hba.conf</tt><br>
<tt>cd /var/lib/postgresql/data</tt><br>
<tt>vi pg_hba.conf</tt><br>
<tt>## add to end of file:</tt><br>
<tt>## host replication replicationuser 127.0.0.1/32 md5</tt><br></h3>

<h3><tt># restart docker container:</tt><br>
<tt>docker container restart sql-outs-project</tt></h3>

<h3>1.2. Создание и настройка кластера:</h3>
<h3><tt># create cluster with current version of postgres (using postgres v14) on a port different of main instance:</tt><br>
<tt>sudo pg_createcluster -d /home/cluster/otus_cluster/ 14 otus_cluster -p 5433</tt><br>
<tt># deleting files in a cluster dir:</tt><br>
<tt>sudo rm -R /home/cluster/otus_cluster/*</tt><br>
<tt># start backup database:</tt><br>
<tt>pg_basebackup -R -U replicauser -D /home/cluster/otus_cluster/ -p 5432</tt><br>
<tt># or start backup database under replication role user:</tt><br>
<tt>sudo pg_basebackup -p 5432 -U replicauser -X stream -C -S otus_cluster -v -R -W -D /home/cluster/otus_cluster</tt></h3>

<h3>1.3. Старт кластера:</h3>
<h3><tt># start cluster:</tt><br>
<tt>sudo pg_ctlcluster 14 otus_cluster start</tt><br>
<tt># check cluster status:</tt><br>
<tt>pg_lsclusters</tt><br>
<tt># enter into replica db:</tt><br>
<tt>sudo -u postgres psql -p 5433 -d otus-project</tt></h3>

<h3>1.4. Проверка синхронизации:</h3>

<h3>База данных синхронизирована</h3>
<img src="task_8/screen_physic_replic/04_check_replica_db.png">

<h3>Создание таблицы на мастере в базе данных:</h3>
<h3><tt># create db replica_trest on master-cluster:</tt><br>
<tt>create database replica_test</tt><br>
<tt># crete table random_table on master-cluster:</tt><br>
<tt>CREATE table random_table </tt><br>
<tt>as SELECT TO_CHAR(day, 'YYYY-MM-DD') as date, (1000 + 500*random())*log(row_number() over()) as value FROM generate_series</tt><br>
        <tt>( '2017-02-01'::date,</tt><br>
        <tt>'2017-04-01'::date,</tt><br>
        <tt>'1 day'::interval) day;</tt></h3>
<img src="task_8/screen_physic_replic/05_2_create_table_master_replica.png">

<h3>Проверка вставки данных:</h3>
<img src="task_8/screen_physic_replic/05_3_insert_value_replica.png">

<h3>1.5. Настройка задержки синхронизации(параметр <tt>checkpoint_timeout</tt>):</h3>
<img src="task_8/screen_physic_replic/06_5_min_dalay_checkpoint_wal.png">

<h2><A name="create-indexes">2. Настроить логическую репликации между двумя кластерами базы данных</A></h2>
<h6><A href="#содержание">назад в содержание</A></h6>

<h3>Демонстрационый стенд собирается на Docker.</h3>

<h3>1. Подготовка конфигурационных файлов:</h3>

<h3>1.1. Подготовка конфигурационных файлов:</h3>

<h3><tt># change postgresql.conf:</tt><br>
<tt>cd /var/lib/postgresql/data</tt><br>
<tt>vi postgresql.conf</tt><br>
<tt>## changing:</tt><br>
<tt>## wal_level = logical</tt></h3>

<h3><tt># or use next query:</tt><br>
<tt>ALTER SYSTEM SET wal_level = logical;</tt></h3>

<h3><tt># restart docker container</tt><br>
<tt>docker container restart sql-outs-project</tt><br></h3>

<h3>1.2. Создание и настройка кластера:</h3>

<h3><tt># create cluster for logical replication
<tt>sudo pg_createcluster -d /home/cluster/otus_cluster_logical/ 14 otus_cluster_logical -p 5431</tt><br>
<tt># start cluster:</tt><br>
<tt>sudo pg_ctlcluster 14 otus_cluster_logical start</tt><br>
<tt># check cluster status:</tt><br>
<tt>pg_lsclusters</tt><br>
<br>
<tt># change wal level on replica cluster and rester cluster:</tt><br>
<tt>ALTER SYSTEM SET wal_level = logical;</tt><br>
<br>
<tt># check max_publication_slots:</tt><br>
<tt>show max_replication_slots;</tt><br>
<tt># or:</tt><br>
<tt>SELECT slot_name, slot_type, active FROM pg_replication_slots;</tt><br>
<br>
<tt># increase max_publication_slots:</tt><br>
<tt>alter system set max_replication_slots = '4';</tt><br>
<tt># restart</tt><br></h3>
<br>
<img src="task_8/screen_logical_replic/01_run_logical_cluster.png">

<h3>1.3. Создание публикации на мастер-кластере:</h3>

<h3><tt># create table in db from csv file:</tt><br>
<tt>docker cp shoe_prices.csv' sql-outs-project:/home/</tt><br>
<tt>create table shoe_prices (brand varchar, model varchar, type varchar, gender varchar, size varchar, color varchar, material varchar, price varchar);</tt><br>
<br>
<tt># copy data from csv to table:</tt><br>
<tt>COPY shoe_prices (brand, model, type, gender, size, color, material, price)</tt><br>
<tt>FROM '/home/shoe_prices.csv'</tt><br>
<tt>DELIMITER ','</tt><br>
<tt>CSV HEADER;</tt><br>
<br>
<tt># create publication:</tt><br>
<tt>create publication test_pub for table shoe_prices;</tt></h3>
<br>
<img src="task_8/screen_logical_replic/02_create_publication.png">

<h3>1.4. Создание подписки на слейве</h3>

<h3><tt># enter into replica cluster:</tt><br>
<tt>sudo -u postgres psql -p 5431</tt><br>
<br>
<tt># create db and table on a subscriber side:</tt><br>
<tt>create database db_test;</tt><br>
<tt>create table shoe_prices (brand varchar, model varchar, type varchar, gender varchar, size varchar, color varchar, material varchar, price varchar);</tt><br>
<br>
<tt># create subscription on logic replica cluster:</tt><br>
<tt>create subscription test</tt><br>
<tt>connection 'host=localhost port=5432 dbname=replica_logical user=pg-user password=pg-pass'</tt><br>
<tt>publication test with (copy_data=true);</tt><br></h3>
<br>
<img src="task_8/screen_logical_replic/03_create_subcribe.png">

<h3>1.5. Проверка синхронизации:</h3>

<h3><tt># insert values into table on master and check if te table on slave is changed:</tt><br>
<tt>insert into shoe_prices values </tt><br>
<tt>('new_brand', 'new_model', 'some_type', 'unknown_gender', 'super_size', 'deep_color', 'nasa_material', 'huge_price');</tt><br><h3>
<br>
<img src="task_8/screen_logical_replic/04_siync_subcribe.png">

