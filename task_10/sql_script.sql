-- before connect to mysql from python
-- need to user in db ith password:
CREATE USER 'mysql_user'@'your_ip_see_in_python_console, it will start from 172.25 ... or something' IDENTIFIED BY 'your_mysql_pass';
GRANT ALL PRIVILEGES ON *.* TO 'mane_of_your_user'@'your_ip_you_set_in_create_user_query' WITH GRANT OPTION;
-- after that you can connect to mysql server and run python scripts

-- check imported tables:
SHOW tables;
-- get 4 tables:

--| Tables_in_shoe_prices |
--|-----------------------|
--| df_brand              |
--| df_gender             |
--| df_model              |
--| df_size               |

-- here we see a tables have one extra field 'index'
-- it was imported with pandas dataframe as default field witch created with dataframe:
SHOW fields FROM <table_name>;
DESCRIBE <table_name>;

--|Table Name | Field    | Type           | Null | Key | Default | Extra |
--|-----------|----------|----------------|------|-----|---------|-------|
--|df_brand   |index     | bigint(20)     | YES  | MUL | NULL    |       |
--|           |id_brand  | double         | YES  |     | NULL    |       |
--|           |Brand     | **text**       | YES  |     | NULL    |       |


-- despite that df_model dataframe in pandas include column with json-like string
-- after import to mysql the same column turned to a 'text' type
-- to resolve this problem, copy column `Model_attribute` to `test_tab_json` with cast it to JSON type:
create TABLE test_tab_json AS select id_model_attr, cast(Model_attribute as JSON) as model_attribute from df_model;
DESCRIBE test_tab_json;

--| Field            | Type       | Null | Key | Default | Extra |
--|------------------|------------|------|-----|---------|-------|
--| id_model_attr    | double     | YES  |     | NULL    |       |
--| model_attribute  | **json**   | YES  |     | NULL    |       |

-- after copy columns from df_model to test_tab_json with new json column type:
insert into test_tab_json (id_model_attr, model_attribute)
    values (
            (select id_model_attr from df_model),
            (select cast(Model_attribute as JSON) from df_model)
           );

-- drop table df_model and recreate it from test_tab_model:
drop table df_model;
create TABLE df_model AS select * from test_tab_json;
drop table test_tab_json;
DESCRIBE df_model;

--| Field           | Type       | Null | Key | Default | Extra |
--|-----------------|------------|------|-----|---------|-------|
--| id_model_attr   | double     | YES  |     | NULL    |       |
--| model_attribute | **json**   | YES  |     | NULL    |       |


-- do some query to 'df_model' with JSON type column:
-- 1. INSERT new record (row):
INSERT INTO df_model (id_model_attr, model_attribute)
    VALUES (741,
            '{
                "Type": ["Running", "Workout"],
                "Color": ["Silver", "Black"],
                "Model": "Absolutely new model",
                "Material": ["Leather", "Cosmic"],
                "Price (USD)": "$170.00 "
             }'
            );

-- 2. SELECT :
-- check inserted row:
SELECT id_model_attr, model_attribute
FROM df_model
WHERE id_model_attr in(741);

--| id_model_attr | model_attribute                                                                                                                                               |
--|---------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
--|           741 | {"Type": ["Running", "Workout"], "Color": ["Silver", "Black"], "Model": "Absolutely new model", "Material": ["Leather", "Cosmic"], "Price (USD)": "$170.00 "} |

-- select all model from json column:
SELECT model_attribute->>"$.Model"
FROM df_model;

--| model_attribute->>"$.Model"  |
--|------------------------------|
--| Air Jordan 1                 |
--| Ultra Boost 21               |
--| Classic Leather              |
--| Chuck Taylor                 |
--| Future Rider                 |
--| Old Skool                    |
--| 990v5                        |
--| ...                          |

-- explode JSON to a series of columns:
SELECT
    id_model_attr,
    json_extract(model_attribute, '$.Model') AS Model_,
    json_extract(model_attribute, '$.Type') AS Type_,
    json_extract(model_attribute, '$.Color') AS Color_,
    json_extract(model_attribute, '$.Material') AS Material_,
    json_extract(model_attribute, '$."Price (USD)"') AS Price_
FROM df_model
LIMIT 5;

--| id_model_attr | Model_            | Type_        | Color_      | Material_   | Price_     |
--|---------------|-------------------|--------------|-------------|-------------|------------|
--|             1 | "Air Jordan 1"    | "Basketball" | "Red/Black" | "Leather"   | "$170.00 " |
--|             2 | "Ultra Boost 21"  | "Running"    | "Black"     | "Primeknit" | "$180.00 " |
--|             3 | "Classic Leather" | "Casual"     | "White"     | "Leather"   | "$75.00 "  |
--|             4 | "Chuck Taylor"    | "Casual"     | "Navy"      | "Canvas"    | "$55.00 "  |
--|             5 | "Future Rider"    | "Lifestyle"  | "Pink"      | "Mesh"      | "$80.00 "  |


-- explode JSON, parse string value and cast it to integer (signet) and do select with conditions:
SELECT
    id_model_attr AS id,
    JSON_EXTRACT(model_attribute , "$.Model") AS model,
    JSON_EXTRACT(model_attribute , "$.Color") AS color,
    JSON_EXTRACT(model_attribute , "$.Material") AS material,
    JSON_EXTRACT(model_attribute ,"$.Type") AS type,
    cast(
        SUBSTRING_INDEX(
                        SUBSTRING_INDEX(
                                        JSON_EXTRACT(model_attribute , '$."Price (USD)"'), '$', -1),
                        '.', 1)
        AS SIGNED) AS price_in_usd
FROM df_model
WHERE JSON_EXTRACT(model_attribute , "$.Color") IN ("Black")
    AND cast(
            SUBSTRING_INDEX(
                            SUBSTRING_INDEX(JSON_EXTRACT(model_attribute , '$."Price (USD)"'), '$', -1),
                            '.', 1)
            AS ) > 160;

--| id   | model                     | color   | material            | type            | price_in_usd |
--|------|---------------------------|---------|---------------------|-----------------|--------------|
--|    2 | "Ultra Boost 21"          | "Black" | "Primeknit"         | "Running"       |          180 |
--|   67 | "Yeezy Boost 350"         | "Black" | "Primeknit"         | "Lifestyle"     |          220 |
--|   89 | "Gel-Kayano 28 Lite-Show" | "Black" | "Mesh"              | "Running"       |          170 |
--|  118 | "ZoomX Invincible Run"    | "Black" | "Mesh/Synthetic"    | "Running"       |          180 |
--|  340 | "Legacy Lifter"           | "Black" | "Leather"           | "Weightlifting" |          200 |
--|  356 | "Air Max 97"              | "Black" | "Leather/Synthetic" | "Running"       |          170 |
--|  479 | "Fresh Foam More v3"      | "Black" | "Mesh/Synthetic"    | "Running"       |          165 |
--|  609 | "Ultraboost 4.0"          | "Black" | "Primeknit"         | "Running"       |          180 |
--|  620 | "Gel-Quantum 360 6"       | "Black" | "Mesh"              | "Running"       |          180 |