-- as dataset was used csv from https://www.kaggle.com/datasets/mkechinov/ecommerce-events-history-in-electronics-store
-- total rows count in csv file are 30M
-- dataset was transform to dataframe, added master key as generated hash id
-- dataframe was splited to a tables with Star pattern and add to mysql DB

--| Tables_in_ecom_events  |
--|------------------------|
--| df_cat                 |
--| df_event               |
--| df_hub (center of Star)|
--| df_prod                |
--| df_session             |

-- add PK for each satellite of the hub table (df_event, df_cat, df_prod, df_session):
alter table df_event
    add constraint df_event_pk
        primary key (event_id);

-- add FK for each key fild from other tables in DB (df_event, df_cat, df_prod, df_session):
alter table df_hub
    add constraint df_hub_df_cat_category_id_fk
        foreign key (category_id) references df_cat (category_id);


DESCRIBE df_cat;

--| Field         | Type       | Null | Key | Default | Extra |
--|---------------|------------|------|-----|---------|-------|
--| category_id   | bigint(20) | NO   | PRI | NULL    |       |
--| category_code | text       | YES  |     | NULL    |       |

DESCRIBE df_event;

--| Field         | Type        | Null | Key | Default | Extra |
--|---------------|-------------|------|-----|---------|-------|
--| event_id      | varchar(36) | NO   | PRI | NULL    |       |
--| event_type    | text        | YES  |     | NULL    |       |
--| event_time    | text        | YES  |     | NULL    |       |

DESCRIBE df_prod;

--| Field         | Type       | Null | Key | Default | Extra |
--|---------------|------------|------|-----|---------|-------|
--| product_id    | bigint(20) | NO   | PRI | NULL    |       |
--| brand         | text       | YES  |     | NULL    |       |
--| price         | double     | YES  |     | NULL    |       |

DESCRIBE df_session;

--| Field         | Type       | Null | Key | Default | Extra |
--|---------------|------------|------|-----|---------|-------|
--| user_session | varchar(36) | NO   | PRI | NULL    |       |
--| user_id      | bigint(20)  | YES  |     | NULL    |       |
--| event_time   | text        | YES  |     | NULL    |       |

DESCRIBE df_hub;

--| Field         | Type        | Null | Key | Default | Extra |
--|---------------|-------------|------|-----|---------|-------|
--| event_id      | varchar(36) | NO   | MUL | NULL    |       |
--| category_id   | bigint(20)  | YES  | MUL | NULL    |       |
--| product_id    | bigint(20)  | YES  | MUL | NULL    |       |
--| user_session  | varchar(36) | YES  | MUL | NULL    |       |

SELECT
    CONCAT(
            CAST(COUNT(event_id)/1000000 AS SIGNED),
            'M') AS total_row_count
FROM df_hub;

--| total_row_count |
--|-----------------|
--| 30M             |


-- INNER JOIN

SELECT df_hub.event_id, df_event.event_time, df_event.event_type
FROM df_event
         JOIN df_hub ON df_hub.event_id = df_event.event_id
WHERE df_event.event_type IN ('purchase')
LIMIT 5;

--| event_id                             | event_time              | event_type |
--|--------------------------------------|-------------------------|------------|
--| 00003fee-0add-4a9d-88f8-30ce8b26d59b | 2019-11-11 07:05:09 UTC | purchase   |
--| 00004937-3bc0-4561-9649-24f81fdffedf | 2019-11-05 09:11:28 UTC | purchase   |
--| 0000710a-145e-4099-97ff-a1ee1e07cd87 | 2019-11-11 10:38:42 UTC | purchase   |
--| 0000a72c-bc87-41a2-bb18-f8d8f4b21713 | 2019-11-09 04:17:29 UTC | purchase   |
--| 0000befc-879c-43c2-bd1f-19e8f3f8e359 | 2019-11-12 12:09:25 UTC | purchase   |


-- LEFT JOIN

WITH cte_session AS (SELECT df_session.user_session, df_session.user_id, df_hub.event_id
                     FROM df_session
                              lEFT JOIN df_hub ON df_session.user_session = df_hub.user_session),
     cte_event AS (SELECT df_event.event_type, df_event.event_id
                   FROM df_event
                            LEFT JOIN df_hub ON df_event.event_id = df_hub.event_id)
SELECT cte_event.event_type, cte_session.user_id
FROM cte_event
         LEFT JOIN cte_session ON cte_event.event_id = cte_session.event_id
LIMIT 5;

--| event_type | user_id   |
--|------------|-----------|
--| view       | 513408484 |
--| view       | 511475012 |
--| view       | 512565172 |
--| view       | 569936678 |
--| view       | 518566245 |


-- WHERE with 5 operators [between, and, or, in, < = >]

WITH cte_prod AS (SELECT df_prod.brand, df_prod.price, df_prod.product_id, df_hub.event_id
                  FROM df_prod
                           JOIN df_hub ON df_prod.product_id = df_hub.product_id
                  WHERE df_prod.brand IS NOT NULL),
     cte_cat AS (SELECT df_cat.category_code, df_cat.category_id, df_hub.event_id
                 FROM df_cat
                          JOIN df_hub ON df_cat.category_id = df_hub.category_id
                 WHERE df_cat.category_code IS NOT NULL),
     cte_event AS (SELECT df_event.event_id, df_event.event_time
                   FROM df_event
                            JOIN df_hub on df_event.event_id = df_hub.event_id)
SELECT cte_prod.brand, cte_prod.price, cte_cat.category_code, cte_event.event_time
FROM cte_prod
         JOIN cte_cat ON cte_cat.event_id = cte_prod.event_id
         JOIN cte_event ON cte_cat.event_id = cte_event.event_id
WHERE DAY(cte_event.event_time) between '14' AND '15' AND cte_prod.price > 500 AND cte_prod.brand IN ('volcano')
   OR DAY(cte_event.event_time) <= '18' AND cte_prod.price > 500 AND cte_prod.brand IN ('midea')
LIMIT 5;

--| brand   | price   | category_code                          | event_time          |
--|---------|---------|----------------------------------------|---------------------|
--| midea   | 967.82  | appliances.environment.air_conditioner | 2019-11-08 16:59:07 |
--| midea   | 967.82  | appliances.environment.air_conditioner | 2019-11-15 08:37:39 |
--| midea   | 967.82  | appliances.environment.air_conditioner | 2019-11-08 16:58:42 |
--| midea   | 967.82  | appliances.environment.air_conditioner | 2019-11-05 17:09:22 |
--| volcano | 518.9   | appliances.environment.air_heater      | 2019-11-15 01:01:28 |
--| volcano | 518.9   | appliances.environment.air_heater      | 2019-11-14 04:45:57 |
--| volcano | 518.9   | appliances.environment.air_heater      | 2019-11-15 05:47:42 |
--| volcano | 518.9   | appliances.environment.air_heater      | 2019-11-14 17:46:54 |
--| volcano | 518.9   | appliances.environment.air_heater      | 2019-11-15 01:01:13 |