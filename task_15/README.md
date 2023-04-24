## TASK 15
* * *

### Step 1: create model like 'Star' from dataset `steam_reviews` from task 14

```mysql
-- create db
CREATE DATABASE steam_rev;
```

* run python script

```python
from dask.diagnostics import ProgressBar
import utils.config as cfg
from task_14.download_from_kaggle import csv_to_dict

DB_NAME = 'csv_load'
USER = cfg.ROOT_USER
PASSWORD = cfg.ROOT_PASSWORD
HOST = cfg.ROOT_HOST
PORT = cfg.ROOT_PORT

PATH_TO_CSV = cfg.path_to_save_csv_task_14

def import_dask_to_mysql(dict_: dict, table: str):
    # get df from dictionary from ```csv_to_dict(path_to_csv: str) -> {}```
    dd = dict_[table]

    to_sql_uri = f'mysql+pymysql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DB_NAME}'

    # setup of ProgressBar for dask batches uploading
    pbar = ProgressBar()
    pbar.register()

    # setup of partitional upload dask dataFrame
    i = 0
    for i in range(dd.npartitions):
        partition = dd.get_partition(i)
        if i == 0:
            partition.to_sql(table, uri=to_sql_uri, if_exists='replace')
        if i > 0:
            partition.to_sql(table, uri=to_sql_uri, if_exists='append')
        i += 1

if __name__ == '__main__':
    import_dask_to_mysql(csv_to_dict(PATH_TO_CSV), 'steam_reviews')
```

```mysql
-- add primary key for steam_review
alter table steam_reviews
    add column id bigint serial default value first;
```

```mysql
-- cat dataset to tables Star model
-- st_hab table 'app_id', 'review_id', 'author_id',
-- st_app fields: app_id, app_name
-- st_rev fields: rev_id_hash, review_id, language, review, timestamp_created, timestamp_updated
-- st_auth fields: auth_id_hash, `author.steamid`, `author.playtime_forever`, `author.last_played`
```

```mysql
-- create hash values for satellite tables
alter table steam_reviews
    add column app_id_hash  varchar(64),
    add column rev_id_hash  varchar(64),
    add column auth_id_hash varchar(64);
```

```mysql
-- add hash for satellite tables
update steam_reviews
set app_id_hash = sha2(concat('app_id_hash', current_time(), id), 256);

update steam_reviews
set rev_id_hash = sha2(concat('rev_id_hash', current_timestamp(), id), 256);

update steam_reviews
set auth_id_hash = sha2(concat('auth_id_hash', current_timestamp(), id), 256);
```

```mysql
-- create tables from SELECT, add primary and foreign keys
create table st_app (PRIMARY KEY (app_id_hash))
select distinct app_id_hash, app_id, app_name
from steam_reviews;

create table st_rev (PRIMARY KEY (rev_id_hash))
select distinct rev_id_hash,
                review_id,
                language,
                review,
                timestamp_created,
                timestamp_updated
from steam_reviews;

create table st_auth (PRIMARY KEY (auth_id_hash))
select distinct auth_id_hash,
                `author.steamid`          as auth_id,
                `author.playtime_forever` as auth_playtime_forever,
                `author.last_played`      as auth_last_played
from steam_reviews;

create table st_hub
(
    id bigint AUTO_INCREMENT PRIMARY KEY
)
select app_id_hash, rev_id_hash, auth_id_hash
from steam_reviews;
```

* check rows count for each table in

```mysql
-- check rows count
select concat('steam_reviews row count:') as `table`, FORMAT(COUNT(id), '# #') AS rows_count
from steam_reviews
union
select concat('hub table row count:') as `table`, FORMAT(COUNT(id), '# #') AS rows_count
from st_hub
union
select concat('app table row count:') as `table`, FORMAT(COUNT(app_id), '# #') AS rows_count
from st_app
union
select concat('rev table row count:') as `title`, FORMAT(COUNT(review_id), '# #') AS rows_count
from st_rev
union
select concat('auth table row count:') as `title`, FORMAT(COUNT(auth_id), '# #') AS rows_count
from st_auth;
```

| table                     | rows\_count |
|:--------------------------|:------------|
| steam\_reviews row count: | 1,353,916   |
| hub table row count:      | 1,353,916   |
| app table row count:      | 1,353,913   |
| rev table row count:      | 1,353,913   |
| auth table row count:     | 1,353,912   |

* * *

### Step 2: try to make joins without any indexes, except existed keys:

```mysql
-- defiantly not a fast query

WITH summary AS (WITH app AS (SELECT app_id_hash, app_name FROM st_app),
                      rev AS (SELECT rev_id_hash, language, review FROM st_rev),
                      auth AS (SELECT auth_id_hash, auth_last_played FROM st_auth)

                 SELECT app.app_name   AS app_name,
                        JSON_OBJECT(
                                'app_name', app.app_name,
                                'reviews_history', JSON_ARRAYAGG(
                                        JSON_OBJECT('date_of_rev', auth.auth_last_played, 'review',
                                                    rev.review)
                                    )) AS json

                 FROM st_hub
                          JOIN app ON app.app_id_hash = st_hub.app_id_hash
                          JOIN rev ON rev.rev_id_hash = st_hub.rev_id_hash
                          JOIN auth ON auth.auth_id_hash = st_hub.auth_id_hash

                 WHERE app.app_name IS NOT NULL
                   AND year(auth.auth_last_played) IS NOT NULL
                   AND year(auth.auth_last_played) IS NOT NULL
                   AND rev.language IN ('english')
                   AND year(auth.auth_last_played) in ('2020')
                   AND MONTH(auth.auth_last_played) in ('11')

                 GROUP BY app.app_name)

SELECT summary.app_name,
       JSON_EXTRACT(summary.json, '$.reviews_history[1].review')      AS review,
       CAST(JSON_EXTRACT(summary.json, '$.reviews_history[1].date_of_rev') AS DATETIME ) AS date_of_rev

FROM summary
WHERE JSON_EXTRACT(summary.json, '$.reviews_history') LIKE '%good%'
GROUP BY summary.app_name;

-- execution: 28 s 237 ms, fetching: 15 ms
```

| app\_name                | review                                                                                                                                                                                                                                                                                           | review              |
|:-------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------------------|
| Counter-Strike: Source   | "yes"                                                                                                                                                                                                                                                                                            | 2020-11-02 21:22:33 |
| Garry's Mod              | "yes. very pog"                                                                                                                                                                                                                                                                                  | 2020-11-03 00:31:33 |
| Half-Life                | "Awesome."                                                                                                                                                                                                                                                                                       | 2020-11-28 17:15:03 |
| Half-Life 2: Episode Two | "visdeo game"                                                                                                                                                                                                                                                                                    | 2020-11-28 00:31:46 |
| Portal 2                 | "noice"                                                                                                                                                                                                                                                                                          | 2020-11-15 13:05:16 |
| The Witcher 3: Wild Hunt | "Just buy it. This game is something that will be written down in History as one of the best games through the Decades."                                                                                                                                                                         | 2020-11-26 15:57:05 |
| X Rebirth                | "It must be a terrible feeling for a developer to actually play the game they've been working on and realize that it isn't any fun.  This is the GTA IV of the \\"X\\" franchise.   The moon landing may have been one small step for a man, but this was one giant step backwards for Egosoft." | 2020-11-08 04:48:09 |

* use ```EXPLANE```

| id   | select\_type   | table            | partitions   | type    | possible\_keys                                                                                                | key                                 | key\_len   | ref                               | rows    | filtered   | Extra                                        |
|:-----|:---------------|:-----------------|:-------------|:--------|:--------------------------------------------------------------------------------------------------------------|:------------------------------------|:-----------|:----------------------------------|:--------|:-----------|:---------------------------------------------|
| 1    | PRIMARY        | &lt;derived2&gt; | null         | ALL     | null                                                                                                          | null                                | null       | null                              | 118032  | 100        | Using temporary                              |
| 2    | DERIVED        | st\_rev          | null         | ALL     | PRIMARY                                                                                                       | null                                | null       | null                              | 1311474 | 10         | Using where; Using temporary; Using filesort |
| 2    | DERIVED        | st\_hub          | null         | ref     | st\_hub\_st\_app\_app\_id\_hash\_fk,st\_hub\_st\_auth\_auth\_id\_hash\_fk,st\_hub\_st\_rev\_rev\_id\_hash\_fk | st\_hub\_st\_rev\_rev\_id\_hash\_fk | 259        | steam\_rev.st\_rev.rev\_id\_hash  | 1       | 100        | Using where                                  |
| 2    | DERIVED        | st\_app          | null         | eq\_ref | PRIMARY                                                                                                       | PRIMARY                             | 258        | steam\_rev.st\_hub.app\_id\_hash  | 1       | 90         | Using where                                  |
| 2    | DERIVED        | st\_auth         | null         | eq\_ref | PRIMARY                                                                                                       | PRIMARY                             | 258        | steam\_rev.st\_hub.auth\_id\_hash | 1       | 100        | Using where                                  |

* on explain we can see that primary key (index) on 'st_rev' table doesn't work
* fix it, and add indexes on 'st_rev':

```mysql
CREATE INDEX st_rev_language_index
    ON steam_rev.st_rev (language);
```

| id    | select\_type | table            | partitions | type    | possible\_keys                                                                                                | key                                 | key\_len | ref                               | rows   | filtered | Extra                           |
|:------|:-------------|:-----------------|:-----------|:--------|:--------------------------------------------------------------------------------------------------------------|:------------------------------------|:---------|:----------------------------------|:-------|:---------|:--------------------------------|
| 1     | PRIMARY      | &lt;derived2&gt; | null       | ALL     | null                                                                                                          | null                                | null     | null                              | 592497 | 100      | Using temporary                 |
| 2     | DERIVED      | st\_rev          | null       | ref     | PRIMARY,st\_rev\_language\_index                                                                              | st\_rev\_language\_index            | 43       | const                             | 658331 | 100      | Using temporary; Using filesort |
| 2     | DERIVED      | st\_hub          | null       | ref     | st\_hub\_st\_app\_app\_id\_hash\_fk,st\_hub\_st\_auth\_auth\_id\_hash\_fk,st\_hub\_st\_rev\_rev\_id\_hash\_fk | st\_hub\_st\_rev\_rev\_id\_hash\_fk | 259      | steam\_rev.st\_rev.rev\_id\_hash  | 1      | 100      | Using where                     |
| 2     | DERIVED      | st\_auth         | null       | eq\_ref | PRIMARY                                                                                                       | PRIMARY                             | 258      | steam\_rev.st\_hub.auth\_id\_hash | 1      | 100      | Using where                     |
| 2     | DERIVED      | st\_app          | null       | eq\_ref | PRIMARY                                                                                                       | PRIMARY                             | 258      | steam\_rev.st\_hub.app\_id\_hash  | 1      | 90       | Using where                     |

* now it use index on 'language' field
* but it still to slow

```mysql
-- execution: 23 s 190 ms, fetching: 23 ms
```

* trying to add fulltext index on column 'review' is failed because it doesn't work on JSON
* changing query and remove all indexes except keys: 

```mysql
WITH app AS (SELECT app_id_hash, app_name FROM st_app),
     rev AS (SELECT rev_id_hash, language, review FROM st_rev),
     auth AS (SELECT auth_id_hash, auth_last_played FROM st_auth)

SELECT app.app_name AS app_name, rev.review as review, auth.auth_last_played as auth_last_played

FROM st_hub
         JOIN app ON app.app_id_hash = st_hub.app_id_hash
         JOIN rev ON rev.rev_id_hash = st_hub.rev_id_hash
         JOIN auth ON auth.auth_id_hash = st_hub.auth_id_hash

WHERE app.app_name IS NOT NULL
  AND year(auth.auth_last_played) IS NOT NULL
  AND year(auth.auth_last_played) IS NOT NULL
  AND rev.language IN ('english')
  AND year(auth.auth_last_played) IN ('2020')
  AND MONTH(auth.auth_last_played) IN ('11')
  AND rev.review LIKE '%good%'

GROUP BY app_name, rev.review, auth.auth_last_played;

-- execution: 6 s 26 ms, fetching: 20 ms
```

### Step 3: let's see to ```EXPLAIN```

* use default `EXPLAIN`

```mysql
EXPLAIN
```

| id    | select\_type | table            | partitions | type    | possible\_keys                                                                                                | key                                 |  key\_len | ref                               | rows    | filtered | Extra                        |
|:------|:-------------|:-----------------|:-----------|:--------|:--------------------------------------------------------------------------------------------------------------|:------------------------------------|:----------|:----------------------------------|:--------|:---------|:-----------------------------|
| 1     | PRIMARY      | &lt;derived2&gt; | null       | ALL     | null                                                                                                          | null                                | null      | null                              | 13165   | 100      | Using temporary              |
| 2     | DERIVED      | st\_rev          | null       | ALL     | PRIMARY                                                                                                       | null                                | null      | null                              | 1316662 | 1.11     | Using where; Using temporary |
| 2     | DERIVED      | st\_hub          | null       | ref     | st\_hub\_st\_app\_app\_id\_hash\_fk,st\_hub\_st\_auth\_auth\_id\_hash\_fk,st\_hub\_st\_rev\_rev\_id\_hash\_fk | st\_hub\_st\_rev\_rev\_id\_hash\_fk | 259       | steam\_rev.st\_rev.rev\_id\_hash  | 1       | 100      | Using where                  |
| 2     | DERIVED      | st\_auth         | null       | eq\_ref | PRIMARY                                                                                                       | PRIMARY                             | 258       | steam\_rev.st\_hub.auth\_id\_hash | 1       | 100      | Using where                  |
| 2     | DERIVED      | st\_app          | null       | eq\_ref | PRIMARY                                                                                                       | PRIMARY                             | 258       | steam\_rev.st\_hub.app\_id\_hash  | 1       | 90       | Using where                  |

```mysql
EXPLAIN ANALYZE
```

```text
-> Table scan on <temporary>  (cost=5.00..5.00 rows=0) (actual time=27885.687..27885.688 rows=7 loops=1)
    -> Temporary table with deduplication  (cost=2.50..2.50 rows=0) (actual time=27885.686..27885.686 rows=7 loops=1)
        -> Table scan on summary  (cost=2.50..2.50 rows=0) (actual time=27885.653..27885.655 rows=7 loops=1)
            -> Materialize CTE summary  (cost=0.00..0.00 rows=0) (actual time=27885.651..27885.651 rows=7 loops=1)
                -> Filter: (json_extract(json_object('app_name',st_app.app_name,'reviews_history',json_arrayagg(tmp_field)),'$.reviews_history') like '%good%')  (actual time=27728.460..27841.046 rows=7 loops=1)
                    -> Group aggregate: json_arrayagg(tmp_field)  (actual time=27725.545..27770.780 rows=7 loops=1)
                        -> Sort: app_name  (actual time=27723.278..27731.909 rows=37463 loops=1)
                            -> Stream results  (cost=1916761.68 rows=586930) (actual time=0.674..27631.096 rows=37463 loops=1)
                                -> Nested loop inner join  (cost=1916761.68 rows=586930) (actual time=0.658..27393.429 rows=37463 loops=1)
                                    -> Nested loop inner join  (cost=1558221.79 rows=586930) (actual time=0.553..19016.584 rows=554508 loops=1)
                                        -> Nested loop inner join  (cost=840913.56 rows=652145) (actual time=0.510..11689.198 rows=554508 loops=1)
                                            -> Index lookup on st_rev using st_rev_language_index (language='english')  (cost=123554.06 rows=652145) (actual time=0.437..2615.864 rows=554508 loops=1)
                                            -> Filter: ((st_hub.app_id_hash is not null) and (st_hub.auth_id_hash is not null))  (cost=1.00 rows=1) (actual time=0.015..0.016 rows=1 loops=554508)
                                                -> Index lookup on st_hub using st_hub_st_rev_rev_id_hash_fk (rev_id_hash=st_rev.rev_id_hash)  (cost=1.00 rows=1) (actual time=0.015..0.016 rows=1 loops=554508)
                                        -> Filter: (st_app.app_name is not null)  (cost=1.00 rows=1) (actual time=0.013..0.013 rows=1 loops=554508)
                                            -> Single-row index lookup on st_app using PRIMARY (app_id_hash=st_hub.app_id_hash)  (cost=1.00 rows=1) (actual time=0.013..0.013 rows=1 loops=554508)
                                    -> Filter: ((year(st_auth.auth_last_played) is not null) and (year(st_auth.auth_last_played) is not null) and (year(st_auth.auth_last_played) = '2020') and (month(st_auth.auth_last_played) = '11'))  (cost=0.51 rows=1) (actual time=0.015..0.015 rows=0 loops=554508)
                                        -> Single-row index lookup on st_auth using PRIMARY (auth_id_hash=st_hub.auth_id_hash)  (cost=0.51 rows=1) (actual time=0.014..0.014 rows=1 loops=554508)

```

<br>

* change format of ```EXPLAIN``` from ```TRADITIONAL``` to ```TREE```:

```mysql
SET @@explain_format=TREE;
SELECT @@explain_format;
```

| @@explain\_format |
|:------------------|
| TREE              |

* the ```TREE``` looks like ```ANALYZE```

```text
-> Table scan on <temporary>  (cost=5.00..5.00 rows=0)
    -> Temporary table with deduplication  (cost=2.50..2.50 rows=0)
        -> Table scan on summary  (cost=2.50..2.50 rows=0)
            -> Materialize CTE summary  (cost=0.00..0.00 rows=0)
                -> Filter: (json_extract(json_object('app_name',st_app.app_name,'reviews_history',json_arrayagg(tmp_field)),'$.reviews_history') like '%good%')
                    -> Group aggregate: json_arrayagg(tmp_field)
                        -> Sort: app_name
                            -> Stream results  (cost=2012788.98 rows=586930)
                                -> Nested loop inner join  (cost=2012788.98 rows=586930)
                                    -> Nested loop inner join  (cost=1418475.71 rows=652145)
                                        -> Nested loop inner join  (cost=808753.54 rows=652145)
                                            -> Index lookup on st_rev using st_rev_language_index (language='english')  (cost=124528.56 rows=652145)
                                            -> Filter: ((st_hub.auth_id_hash is not null) and (st_hub.app_id_hash is not null))  (cost=0.95 rows=1)
                                                -> Index lookup on st_hub using st_hub_st_rev_rev_id_hash_fk (rev_id_hash=st_rev.rev_id_hash)  (cost=0.95 rows=1)
                                        -> Filter: ((year(st_auth.auth_last_played) is not null) and (year(st_auth.auth_last_played) is not null) and (year(st_auth.auth_last_played) = '2020') and (month(st_auth.auth_last_played) = '11'))  (cost=0.83 rows=1)
                                            -> Single-row index lookup on st_auth using PRIMARY (auth_id_hash=st_hub.auth_id_hash)  (cost=0.83 rows=1)
                                    -> Filter: (st_app.app_name is not null)  (cost=0.81 rows=1)
                                        -> Single-row index lookup on st_app using PRIMARY (app_id_hash=st_hub.app_id_hash)  (cost=0.81 rows=1)

```

<br>

* let's see to ```JSON``` format :

```mysql
SET @@explain_format=JSON;
SELECT @@explain_format;
```

```json
{
  "query_block": {
    "select_id": 1,
    "cost_info": {
      "query_cost": "66032.12"
    },
    "grouping_operation": {
      "using_temporary_table": true,
      "using_filesort": false,
      "table": {
        "table_name": "summary",
        "access_type": "ALL",
        "rows_examined_per_scan": 586930,
        "rows_produced_per_join": 586930,
        "filtered": "100.00",
        "cost_info": {
          "read_cost": "7339.12",
          "eval_cost": "58693.00",
          "prefix_cost": "66032.12",
          "data_read_per_join": "80M"
        },
        "used_columns": [
          "app_name",
          "json"
        ],
        "materialized_from_subquery": {
          "using_temporary_table": true,
          "dependent": false,
          "cacheable": true,
          "query_block": {
            "select_id": 2,
            "cost_info": {
              "query_cost": "2600641.16"
            },
            "grouping_operation": {
              "using_temporary_table": true,
              "using_filesort": true,
              "cost_info": {
                "sort_cost": "586930.48"
              },
              "nested_loop": [
                {
                  "table": {
                    "table_name": "st_rev",
                    "access_type": "ref",
                    "possible_keys": [
                      "PRIMARY",
                      "st_rev_language_index"
                    ],
                    "key": "st_rev_language_index",
                    "used_key_parts": [
                      "language"
                    ],
                    "key_length": "43",
                    "ref": [
                      "const"
                    ],
                    "rows_examined_per_scan": 652145,
                    "rows_produced_per_join": 652145,
                    "filtered": "100.00",
                    "cost_info": {
                      "read_cost": "59314.06",
                      "eval_cost": "65214.50",
                      "prefix_cost": "124528.56",
                      "data_read_per_join": "845M"
                    },
                    "used_columns": [
                      "rev_id_hash",
                      "language",
                      "review"
                    ]
                  }
                },
                {
                  "table": {
                    "table_name": "st_hub",
                    "access_type": "ref",
                    "possible_keys": [
                      "st_hub_st_app_app_id_hash_fk",
                      "st_hub_st_auth_auth_id_hash_fk",
                      "st_hub_st_rev_rev_id_hash_fk"
                    ],
                    "key": "st_hub_st_rev_rev_id_hash_fk",
                    "used_key_parts": [
                      "rev_id_hash"
                    ],
                    "key_length": "259",
                    "ref": [
                      "steam_rev.st_rev.rev_id_hash"
                    ],
                    "rows_examined_per_scan": 1,
                    "rows_produced_per_join": 652145,
                    "filtered": "100.00",
                    "cost_info": {
                      "read_cost": "619231.54",
                      "eval_cost": "65214.50",
                      "prefix_cost": "808974.60",
                      "data_read_per_join": "487M"
                    },
                    "used_columns": [
                      "id",
                      "app_id_hash",
                      "rev_id_hash",
                      "auth_id_hash"
                    ],
                    "attached_condition": "((`steam_rev`.`st_hub`.`auth_id_hash` is not null) and (`steam_rev`.`st_hub`.`app_id_hash` is not null))"
                  }
                },
                {
                  "table": {
                    "table_name": "st_auth",
                    "access_type": "eq_ref",
                    "possible_keys": [
                      "PRIMARY"
                    ],
                    "key": "PRIMARY",
                    "used_key_parts": [
                      "auth_id_hash"
                    ],
                    "key_length": "258",
                    "ref": [
                      "steam_rev.st_hub.auth_id_hash"
                    ],
                    "rows_examined_per_scan": 1,
                    "rows_produced_per_join": 652145,
                    "filtered": "100.00",
                    "cost_info": {
                      "read_cost": "544900.68",
                      "eval_cost": "65214.50",
                      "prefix_cost": "1419089.79",
                      "data_read_per_join": "174M"
                    },
                    "used_columns": [
                      "auth_id_hash",
                      "auth_last_played"
                    ],
                    "attached_condition": "((year(`steam_rev`.`st_auth`.`auth_last_played`) is not null) and (year(`steam_rev`.`st_auth`.`auth_last_played`) is not null) and (year(`steam_rev`.`st_auth`.`auth_last_played`) = '2020') and (month(`steam_rev`.`st_auth`.`auth_last_played`) = '11'))"
                  }
                },
                {
                  "table": {
                    "table_name": "st_app",
                    "access_type": "eq_ref",
                    "possible_keys": [
                      "PRIMARY"
                    ],
                    "key": "PRIMARY",
                    "used_key_parts": [
                      "app_id_hash"
                    ],
                    "key_length": "258",
                    "ref": [
                      "steam_rev.st_hub.app_id_hash"
                    ],
                    "rows_examined_per_scan": 1,
                    "rows_produced_per_join": 586930,
                    "filtered": "90.00",
                    "cost_info": {
                      "read_cost": "529406.39",
                      "eval_cost": "58693.05",
                      "prefix_cost": "2013710.67",
                      "data_read_per_join": "219M"
                    },
                    "used_columns": [
                      "app_id_hash",
                      "app_name"
                    ],
                    "attached_condition": "(`steam_rev`.`st_app`.`app_name` is not null)"
                  }
                }
              ]
            }
          }
        }
      }
    }
  }
}
```

<br>

* turn back from ```TREE``` to ```TRADITIONAL``` view:

```mysql
SET @@explain_format=TRADITIONAL;
SELECT @@explain_format;
```

| @@explain\_format |
|:------------------|
| TRADITIONAL       |

* in ```EXPLAIN``` one table 'st_rev' do not use any index
* so, go to Step 4
* * * 

### Step 4: add indexes for a fields in selection condition:

* add index on `language` field, because it's using in a condition

* speed of doing query do not change
```mysql
CREATE INDEX st_rev_language_index
    ON steam_rev.st_rev (language);

-- execution: 7 s 666 ms, fetching: 28 ms
```
<br>

* add a `FULLTEXT INDEX` on a `review` field
* these modification increase a little bia a speed of our query from 7s to 4s

```mysql
-- add to condition block
WITH ...
AND MATCH(rev.review) AGAINST ('good')
    
-- execution: 4 s 867 ms, fetching: 30 ms
```




