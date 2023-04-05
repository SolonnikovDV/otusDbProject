## Task 12

<h3><A name="contents">Содержание:</A></h3>
<h4><A href="#import_data_to_mysql_python">1. Upload .csv with python</A></h4>
<h4><A href="#import_data_load_data">2. Upload .csv with <tt>'LOAD DATA'</tt></A></h4>
<h4><A href="#import_data_load_data_mysqlimport">3. Upload .csv with <tt>'mysqlimport'</tt></A></h4>
<h4><A href="#transaction_case">4. Transaction case</A></h4>
<hr>

<h3><A href name="import_data_to_mysql_python">1. Upload .csv with python</A></h3>
<h6><A href="#contents">back to contents >></A></h6>
<br>

#### Process describe:
* for import data using ```KaggleApi``` from [Kaggle: Spotify Dataset 1921-2020, 600k+ Tracks](https://www.kaggle.com/datasets/yamaerenay/spotify-dataset-19212020-600k-tracks)

```python
import os
from kaggle.api.kaggle_api_extended import KaggleApi

def get_data_from_api(dataset: str, path_to_save_csv: str):
    # authorization key
    os.environ['KAGGLE_USERNAME'] = KAGGLE_USERNAME
    os.environ['KAGGLE_KEY'] = KAGGLE_KEY
    
    # download dataset
    api = KaggleApi()
    api.authenticate()
    api.dataset_download_files(dataset, path_to_save_csv, unzip=True)
```

* total downloaded files: ['tracks.csv', 'artists.csv', 'dict_artists.json']

| size, Mb | file name         |
|----------|-------------------|
| 64M      | artists.csv       |
| 332M     | dict_artists.json |
| 111M     | tracks.csv        |

* read all downloaded .csv files to pandas dataframe

```python
import pandas as pd

# using engin='pyarrow' to boost reading speed of bif files
with open(f'{path_to_csv}/{file}') as csv_file:
    df = pd.read_csv(csv_file, engine='pyarrow')
```

* load dataframes to db

```python
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.pool import NullPool
import csv

def import_df_to_mysql(dict_of_df: dict, csv_name: str):
    df = dict_of_df[csv_name]
    # create connection to mysql db
    engine = create_engine(f'mysql+pymysql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DB_NAME}', 
                           pool_recycle=3600, 
                           poolclass=NullPool)
    con = engine.connect()
    
    df.to_sql(name=csv_name,
                  con=con,
                  if_exists='replace',
                  index=False)
```

* .csv files imported to db

```mysql
SELECT 
    TABLE_NAME AS `Table`, 
    CONCAT(ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024), ' Mb') AS `Size`
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = "csv_load_db"
ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC;
```

| Table   | Size   |
|---------|--------|
| tracks  | 153 Mb |
| artists | 106 Mb |

```mysql
DESCRIBE artists;
```

| Field      | Type       | Null | Key | Default | Extra |
|------------|------------|------|-----|---------|-------|
| id         | text       | YES  |     | NULL    |       |
| followers  | double     | YES  |     | NULL    |       |
| genres     | text       | YES  |     | NULL    |       |
| name       | text       | YES  |     | NULL    |       |
| popularity | bigint(20) | YES  |     | NULL    |       |

```mysql
DESCRIBE tracks;
```

| Field            | Type       | Null | Key | Default | Extra |
|------------------|------------|------|-----|---------|-------|
| id               | text       | YES  |     | NULL    |       |
| name             | text       | YES  |     | NULL    |       |
| popularity       | bigint(20) | YES  |     | NULL    |       |
| duration_ms      | bigint(20) | YES  |     | NULL    |       |
| explicit         | bigint(20) | YES  |     | NULL    |       |
| artists          | text       | YES  |     | NULL    |       |
| id_artists       | text       | YES  |     | NULL    |       |
| release_date     | text       | YES  |     | NULL    |       |
| danceability     | double     | YES  |     | NULL    |       |
| energy           | double     | YES  |     | NULL    |       |
| key              | bigint(20) | YES  |     | NULL    |       |
| loudness         | double     | YES  |     | NULL    |       |
| mode             | bigint(20) | YES  |     | NULL    |       |
| speechiness      | double     | YES  |     | NULL    |       |
| acousticness     | double     | YES  |     | NULL    |       |
| instrumentalness | double     | YES  |     | NULL    |       |
| liveness         | double     | YES  |     | NULL    |       |
| valence          | double     | YES  |     | NULL    |       |
| tempo            | double     | YES  |     | NULL    |       |
| time_signature   | bigint(20) | YES  |     | NULL    |       |

### Upload csv to db using python scrips is a most powerful method (IMAO), because it allows any type of validation, customisation and transformation data into dataframe.

<br>
<h4><A name="import_data_load_data">2. Upload .csv with <tt>'LOAD DATA'</tt></A></h4>
<h6><A href="#contents">back to contents >></A></h6>
<br>

#### Process describe:
* copy .csv file to docker-container with mysql-server
    * get name of container:

        ```shell
        docker ps
        ```

    * copy file from local to docker container:
  
        ```shell
        docker cp statistic.csv otus-mysql-docker-otusdb-1:/home 
        ```
      
    * enter into docker container and check copied file
  
        ```shell
        docker exec -it otus-mysql-docker-otusdb-1 /bin/bash
        ```
      
        ```dockerfile
        cd home/
        cat statistic.csv
        ```
      
      * and we can see csv-file content here:
      
        ```text
        event_time,event_type,product_id,category_id,category_code,brand,price,user_id,user_session
        2019-11-01 00:00:00 UTC,view,1003461,2053013555631882655,electronics.smartphone,xiaomi,489.07,520088904,4d3b30da-a5e4-49df-b1a8-ba5943f1dd33
        2019-11-01 00:00:00 UTC,view,5000088,2053013566100866035,appliances.sewing_machine,janome,293.65,530496790,8e5f4f83-366c-4f70-860e-ca7417414283
        2019-11-01 00:00:01 UTC,view,17302664,2053013553853497655,,creed,28.31,561587266,755422e7-9040-477b-9bd2-6a6e8fd97387
        2019-11-01 00:00:01 UTC,view,3601530,2053013563810775923,appliances.kitchen.washer,lg,712.87,518085591,3bfb58cd-7892-48cc-8020-2f17e6de6e7f
        ```
        
* create table into db:

```mysql
CREATE TABLE statistic_load_data
(
    event_time VARCHAR(30),
    event_type TINYTEXT,
    product_id MIDDLEINT,
    category_id BIGINT,
    category_code VARCHAR(150),
    price FLOAT,
    brand TINYTEXT,
    user_id BIGINT,
    user_session VARCHAR(100)
);
```

* copy csv-file to the created table with ```LOAD DATA``` :

```mysql
LOAD DATA INFILE '/home/statistic.csv'
    INTO TABLE statistic_load_data
    FIELDS TERMINATED BY ','
    ignore 60000000 rows; # used huge csv with 67M rows
    
-- [2023-04-05 14:55:36] 7,501,980 rows affected in 1 m 24 s 277 ms
```

```mysql
SELECT count(event_type) FROM statistic_load_data;
```

| count(event_type) |
|:------------------|
| 7501980           |

```mysql
SELECT * FROM statistic_load_data limit 3;
```

| event\_time             | event\_type | product\_id | category\_id        | category\_code                   | price   | brand  | user\_id  | user\_session                        |
|:------------------------|:------------|:------------|:--------------------|:---------------------------------|:--------|:-------|:----------|:-------------------------------------|
| 2019-11-26 14:26:56 UTC | view        | 1005263     | 2053013555631882655 | electronics.smartphone           | oppo    | 694.97 | 520447984 | 1b7eaf4e-f08f-42f3-be4d-fee825d53e19 |
| 2019-11-26 14:26:57 UTC | view        | 16600166    | 2053013560287560373 |                                  |         | 396.41 | 576659486 | af83c54a-58a5-4f0a-b661-b33f66b64f9b |
| 2019-11-26 14:26:57 UTC | view        | 2701995     | 2053013563911439225 | appliances.kitchen.refrigerators | samsung | 681.87 | 517182670 | cc6f77c2-46e3-47fa-88d1-b70e58054715 |


<hr>
<br>

<h4><A href="import_data_load_data_mysqlimport">3. Upload .csv with <tt>'mysqlimport'</tt></A></h4>
<h6><A href="#contents">back to contents >></A></h6>

#### Process describe:
* create table named like csv-file:

```mysql
CREATE TABLE statistic
(
    event_time text,
    event_type text,
    product_id text,
    category_id text,
    category_code text,
    price text,
    brand text,
    user_id text,
    user_session text
);
```

* use msql shell to upload csv-file:

```shell
mysqlimport  --fields-terminated-by=',' --ignore-lines=66000000  --user=mysql_user -p csv_load_db /home/statistic.csv
```

```text
csv_load_db.statistic: Records: 1501980  Deleted: 0  Skipped: 0  Warnings: 0
```

<hr>
<br>

<h4><A href="transaction_case">4. Transaction case</A></h4>
<h6><A href="#contents">back to contents >></A></h6>

#### Process describe:
* take two tables ```tracks``` and ```artists```

```mysql
DESCRIBE artists;
```

| Field      | Type          | Null   | Key | Default | Extra |
|:-----------|:--------------|:-------|:----|:--------|:------|
| id         | varchar\(22\) | YES    | MUL | null    |       |
| followers  | double        | YES    |     | null    |       |
| genres     | text          | YES    |     | null    |       |
| name       | text          | YES    |     | null    |       |
| popularity | bigint\(20\)  | YES    |     | null    |       |

```mysql
SHOW INDEX FROM artists;
```

| Table   | Non\_unique | Key\_name          | Seq\_in\_index | Column\_name | Collation | Cardinality | Sub\_part | Packed | Null  | Index\_type | Comment | Index\_comment | Visible | Expression |
|:--------|:------------|:-------------------|:---------------|:-------------|:----------|:------------|:----------|:-------|:------|:------------|:--------|:---------------|:--------|:-----------|
| artists | 1           | artists\_id\_index | 1              | id           | A         | 1159608     | null      | null   | YES   | BTREE       |         |                | YES     | null       |


```mysql
DESCRIBE tracks;
```

| Field            | Type          | Null  | Key | Default | Extra |
|:-----------------|:--------------|:------|:----|:--------|:------|
| id               | varchar\(22\) | YES   | MUL | null    |       |
| name             | text          | YES   |     | null    |       |
| popularity       | bigint\(20\)  | YES   |     | null    |       |
| duration\_ms     | bigint\(20\)  | YES   |     | null    |       |
| explicit         | bigint\(20\)  | YES   |     | null    |       |
| artists          | text          | YES   |     | null    |       |
| id\_artists      | text          | YES   |     | null    |       |
| release\_date    | text          | YES   |     | null    |       |
| danceability     | double        | YES   |     | null    |       |
| energy           | double        | YES   |     | null    |       |
| key              | bigint\(20\)  | YES   |     | null    |       |
| loudness         | double        | YES   |     | null    |       |
| mode             | bigint\(20\)  | YES   |     | null    |       |
| speechiness      | double        | YES   |     | null    |       |
| acousticness     | double        | YES   |     | null    |       |
| instrumentalness | double        | YES   |     | null    |       |
| liveness         | double        | YES   |     | null    |       |
| valence          | double        | YES   |     | null    |       |
| tempo            | double        | YES   |     | null    |       |
| time\_signature  | bigint\(20\)  | YES   |     | null    |       |

```mysql
SHOW INDEX FROM tracks;
```

| Table  | Non\_unique | Key\_name         | Seq\_in\_index | Column\_name | Collation | Cardinality | Sub\_part | Packed | Null  | Index\_type | Comment | Index\_comment | Visible | Expression |
|:-------|:------------|:------------------|:---------------|:-------------|:----------|:------------|:----------|:-------|:------|:------------|:--------|:---------------|:--------|:-----------|
| tracks | 1           | tracks\_id\_index | 1              | id           | A         | 560086      | null      | null   | YES   | BTREE       |         |                | YES     | null       |

* create stored procedure

```mysql
-- create stored procedure
DELIMITER //
CREATE PROCEDURE transactions()
BEGIN
    select artists.name, tracks.artists
    from tracks
             JOIN artists ON tracks.id_artists = artists.id;
END //
```

* check procedure status:

```mysql
SHOW PROCEDURE STATUS WHERE name in ('transactions');
```

| Db            | Name         | Type      | Definer                | Modified            | Created             | Security\_type | Comment | character\_set\_client | collation\_connection | Database Collation    |
|:--------------|:-------------|:----------|:-----------------------|:--------------------|:--------------------|:---------------|:--------|:-----------------------|:----------------------|:----------------------|
| csv\_load\_db | transactions | PROCEDURE | mysql\_user@172.25.0.1 | 2023-04-05 13:03:44 | 2023-04-05 13:03:44 | DEFINER        |         | utf8mb4                | utf8mb4\_0900\_ai\_ci | utf8mb4\_0900\_ai\_ci |

* call stored procedure:

```mysql
CALL transactions();
```

| name            | artists               |
|:----------------|:----------------------|
| Uli             | \['Uli'\]             |
| Fernando Pessoa | \['Fernando Pessoa'\] |
| Ignacio Corsini | \['Ignacio Corsini'\] |
| Ignacio Corsini | \['Ignacio Corsini'\] |
| ...             | ...                   |

* procedure works successful