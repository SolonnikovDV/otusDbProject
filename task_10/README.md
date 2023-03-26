<h3>Task 10</h3>
<br>

<h3><A name="содержание">Содержание:</A></h3>
<h4><A href="#imoprt_data_to_mysql">1. Соединение с mysql-server из python и импорт таблиц в БД</A></h4>
<h4><A href="#insert_json">2. Примеры SQL для добавления записей и выборки</A></h4>
<hr>

<br>
<h3><A name="imoprt_data_to_mysql">1. Соединение с mysql server из python и импорт таблиц в БД</A></h3>
<h6><A href="#содержание">назад в содержание</A></h6>

<h4>1.1. Подготовка к соединению с mysql-server</h4>

<h4><tt>-- before connect to mysql from python</tt><br>
<tt>-- need to user in db ith password:</tt><br>
<tt>CREATE USER 'mysql_user'@'your_ip_see_in_python_console, it will start from 172.25 ... or something' IDENTIFIED BY 'your_mysql_pass';</tt><br>
<br>
<tt>GRANT ALL PRIVILEGES ON *.* TO 'mane_of_your_user'@'your_ip_you_set_in_create_user_query' WITH GRANT OPTION;</tt><br>
<br>
<tt>-- after that you can connect to mysql server and run python scripts</tt></h4>

<h4>1.2. Импорт датафреймов из python в БД mysql</h4>
<h4><tt>

    def insert_data_to_mysql(df_dict: dict, df_name: str):
    df = df_dict[f'{df_name}']
    print(df.head(5))
    print(df_dict['df_model'])

    # create connection to mysql db
    sql_engine = create_engine(f'mysql+pymysql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DB_NAME}', pool_recycle=3600)
    db_connection = sql_engine.connect()

    try:
        df.to_sql(df_name, db_connection, if_exists='replace')
    except ValueError as vx:
        print(vx)
    except Exception as ex:
        print(ex)
    else:
        print("Table %s created successfully." % df_name)
    finally:
        db_connection.close()
</tt></h4>

<h4>1.3. Просмотр данных об импортированных датафреймах</h4>
<h4><tt>-- check imported tables:</tt><br>
<tt>SHOW tables;</tt><br>
<br>
<tt>-- get 4 tables:</tt><h4>

| Tables_in_shoe_prices |
|-----------------------|
| df_brand              |
| df_gender             |
| df_model              |
| df_size               |

<br>
<h4><tt>-- here we see a tables have one extra field 'index'</tt>tt><br>
<tt>-- it was imported with pandas dataframe as default field witch created with dataframe:</tt><br>
<tt>SHOW fields FROM <table_name>;</tt><br>
<tt>DESCRIBE <table_name>;</tt><br></h4>

|Table Name | Field    | Type           | Null | Key | Default | Extra |
|-----------|----------|----------------|------|-----|---------|-------|
|df_brand   |index     | bigint(20)     | YES  | MUL | NULL    |       |
|           |id_brand  | double         | YES  |     | NULL    |       |
|           |Brand     | **text**       | YES  |     | NULL    |       |

<br>
<h4>1.4. Решение проблемы вставки <tt>JSON</tt> данных из датафрейма в формате <tt>string</tt></h4>
<style>
        .tab1 {
            tab-size: 2;
        }
  
        .tab2 {
            tab-size: 4;
        }
  
        .tab4 {
            tab-size: 8;
        }
</style>

<h4><tt>-- after copy columns from df_model to test_tab_json with new json column type:</tt><br>
<br>
<tt>INSERT INTO test_tab_json (id_model_attr, model_attribute)</tt><br>
<tt> &emsp; &emsp; VALUES (</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; (SELECT id_model_attr FROM df_model),</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; (SELECT cast(Model_attribute AS JSON) FROM df_model)</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;);</tt><h4>

<h4><tt>-- drop table 'df_model' and recreate it from 'test_tab_model':</tt><br>
<br>
<tt>DROP TABLE df_model;</tt><br>
<tt>CREATE TABLE df_model AS SELECT * FROM test_tab_json;</tt><br>
<tt>DROP TABLE test_tab_json;</tt><br>
<tt>DESCRIBE df_model;</tt><h4>

| Field           | Type       | Null | Key | Default | Extra |
|-----------------|------------|------|-----|---------|-------|
| id_model_attr   | double     | YES  |     | NULL    |       |
| model_attribute | **json**   | YES  |     | NULL    |       |

<h3><A name="insert_json">2. Примеры SQL для добавления записей и выборки</A></h3>
<h6><A href="#содержание">назад в содержание</A></h6>

<h4>2.1. Вставка JSON записей:<h4>
<h4><tt>-- 1. INSERT new record (row):</tt><br>
<tt>INSERT INTO df_model (id_model_attr, model_attribute)</tt><br>
<tt> &emsp; &emsp; VALUES ( </tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; 741, </tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; '{</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;  "Type": ["Running", "Workout"],</tt><br> 
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;  "Color": ["Silver", "Black"],</tt><br> 
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;  "Model": "Absolutely new model",</tt><br> 
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;  "Material": ["Leather", "Cosmic"],</tt><br> 
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;  "Price (USD)": "$170.00 "</tt><br> 
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; }'</tt><br> 
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;);</tt></h4>

<h4>2.2 Выборка записей из JSON</h4>
<h4>2.2.1 Выборка последней вставленной записи:</hh>
<h4><tt>-- check inserted row:</tt><br>
<tt>SELECT id_model_attr, model_attribute</tt><br>
<tt>FROM df_model</tt><br>
<tt>WHERE id_model_attr in(741);</tt><h4>

| id_model_attr | model_attribute                                                                                                                                               |
|---------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
|           741 | {"Type": ["Running", "Workout"], "Color": ["Silver", "Black"], "Model": "Absolutely new model", "Material": ["Leather", "Cosmic"], "Price (USD)": "$170.00 "} |

<h4>2.2.2 Выборка записей поля <tt>'Model'</tt> в JSON строке:</hh>
<h4><tt>-- select all model from json column:</tt><br>
<tt>SELECT model_attribute->>"$.Model"</tt><br>
<tt>FROM df_model;</tt></h4>

| model_attribute->>"$.Model"  |
|------------------------------|
| Air Jordan 1                 |
| Ultra Boost 21               |
| Classic Leather              |
| Chuck Taylor                 |
| ...                          |

<h4>2.2.3 Разделение JSON на колонки:</hh>

<h4><tt>-- explode JSON to a series of columns:</tt><br>
SELECT</tt><br>
<tt>&emsp; &emsp; &emsp; &emsp;     id_model_attr,
<tt> &emsp; &emsp; &emsp; &emsp; json_extract(model_attribute, '$.Model') AS Model_,</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; json_extract(model_attribute, '$.Type') AS Type_,</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; json_extract(model_attribute, '$.Color') AS Color_,</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; json_extract(model_attribute, '$.Material') AS Material_,</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; json_extract(model_attribute, '$."Price (USD)"') AS Price_</tt><br>
<tt> FROM df_model</tt><br>
LIMIT 5;</tt><h4>

| id_model_attr | Model_            | Type_        | Color_      | Material_   | Price_     |
|---------------|-------------------|--------------|-------------|-------------|------------|
|             1 | "Air Jordan 1"    | "Basketball" | "Red/Black" | "Leather"   | "$170.00 " |
|             2 | "Ultra Boost 21"  | "Running"    | "Black"     | "Primeknit" | "$180.00 " |
|             3 | "Classic Leather" | "Casual"     | "White"     | "Leather"   | "$75.00 "  |
|             4 | "Chuck Taylor"    | "Casual"     | "Navy"      | "Canvas"    | "$55.00 "  |
|             5 | "Future Rider"    | "Lifestyle"  | "Pink"      | "Mesh"      | "$80.00 "  |

<h4>2.2.4 Разделение JSON на колонки, парсинг строк, приведение к типу <tt>SIGNED</tt>:</hh>

<h4><tt>-- explode JSON, parse string value and cast it to integer (signet) and do select with conditions:</tt><br>
<tt> SELECT</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp;     id_model_attr AS id,</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp;     JSON_EXTRACT(model_attribute , "$.Model") AS model,</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp;     JSON_EXTRACT(model_attribute , "$.Color") AS color,</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp;     JSON_EXTRACT(model_attribute , "$.Material") AS material,</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp;     JSON_EXTRACT(model_attribute ,"$.Type") AS type,</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp;     cast(</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;      SUBSTRING_INDEX(</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;     SUBSTRING_INDEX(</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;      JSON_EXTRACT(model_attribute , '$."Price (USD)"'), '$', -1),</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;     '.', 1)</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;      AS SIGNED) AS price_in_usd</tt><br>
<tt> FROM df_model</tt><br>
<tt> WHERE JSON_EXTRACT(model_attribute , "$.Color") IN ("Black")</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp;    AND cast(</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;  &emsp; &emsp;      SUBSTRING_INDEX(</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;     SUBSTRING_INDEX(JSON_EXTRACT(model_attribute , '$."Price (USD)"'), '$', -1),</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;     '.', 1)</tt><br>
<tt> &emsp; &emsp; &emsp; &emsp; &emsp; &emsp;  &emsp; &emsp;      AS ) > 160;</tt></h4>