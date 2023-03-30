<h3>Task 10</h3>
<br>

<h3><A name="содержание">Содержание:</A></h3>
<h4><A href="#imoprt_data_to_mysql">1. Соединение с mysql-server из python и импорт таблиц в БД</A></h4>
<h4><A href="#inner_join">2. Запрос с <tt>'inner join'</tt></A></h4>
<h4><A href="#left_join">3. Запрос с <tt>'left join'</tt></A></h4>
<h4><A href="#where_query">4. 5 запросов с <tt>'WHERE'</tt> с использованием разных операторов</tt></A></h4>
<hr>

<br>
<h3><A name="imoprt_data_to_mysql">1. Соединение с mysql server из python и импорт таблиц в БД</A></h3>
<h6><A href="#содержание">назад в содержание</A></h6>

<h4>1.1. Чтение csv в dataframe Pandas</h4>

<h4>В качестве исходного датасета взят csv 9Gb с [kaggle](https://www.kaggle.com/datasets/mkechinov/ecommerce-events-history-in-electronics-store)</h4>
<h4>Исходный csv содержит 67М сторок, но для datafame объем чтение был ограничен 30М строками</h4>

```python
    def csv_to_df() -> pd.DataFrame:
        # set option to see all columns in console
        pd.set_option('display.max_columns', None)

        # read csv file to df
        with open(path_to_csv) as csv_file:
            # engine="pyarrow" on pandas works faster even read csv with chunks or wright/read parquet
            # df = pd.read_csv(csv_file, engine="pyarrow")
            df = pd.read_csv(csv_file, nrows=30000000)

        return df
```

<h4>Обработка данных происходит на backEnd<br></h4> 
* разделение на таблицы:

```python
    df.iloc[:, [col_number, next_col_number, ...]]
```

* сгенерировано ключевое поле:

```python
    def hash_id_generate (count: int) -> []:
        list_of_hash = []

        for i in tqdm(range(count)):
            i = uuid.uuid4()
            list_of_hash.append(i)
        return list_of_hash
```
* удаление строк дубликатов, в данном случае удалялись строки, где дублирущее значение возникало в поле-ключе (<tt>.drop_duplicates()</tt>), проверка на <tt>is NULL</tt> и удаление <tt>NULL</tt> значение из полей ключа: 

```python
    # val.columns[0] - name of column in a string type
    for key, val in enumerate(tqdm(df_list)):
        
        # distinct values:
        val = val.drop_duplicates(subset=[val.columns[0]], keep="first",)
        
        # is NULL check:
        val = val.dropna(subset=[val.columns[0]])
        
        # append df to a dictionary of dataframes:
        df_dict.update({key_list[key]: val})
```

<h4>1.2. Импорт датафреймов из python в БД mysql</h4>

```python
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
```

<h4>1.3. Просмотр данных об импортированных датафреймах</h4>
<h4>В качестве модели данных выбрана "Звезда"</h4>
<h4>Всего 5 таблиц, одна из них <tt>'df_hub'</tt> является хабом ключей таблиц сателитов содержащих соответствующие ключам атрибуты</h4>

```mysql
SHOW tables;
```

| Tables_in_ecom_events  |
|------------------------|
| df_cat                 |
| df_event               |
| df_hub (center of Star)|
| df_prod                |
| df_session             |

```mysql
DESCRIBE df_hub;
```

| Field         | Type        | Null | Key | Default | Extra |
|---------------|-------------|------|-----|---------|-------|
| event_id      | varchar(36) | NO   | MUL | NULL    |       |
| category_id   | bigint(20)  | YES  | MUL | NULL    |       |
| product_id    | bigint(20)  | YES  | MUL | NULL    |       |
| user_session  | varchar(36) | YES  | MUL | NULL    |       |

<br>

<h4>Всего таблица <tt>'df_hub'</tt> содержит 30 млн записей</h4>

```mysql
SELECT CONCAT(
               CAST(COUNT(event_id) / 1000000 AS SIGNED),
               'M') AS total_row_count
FROM df_hub;
```

| total_row_count |
|-----------------|
| 30M             |

<h3><A name="inner_join">2. Запрос с <tt>'inner join'</tt></A></h3>
<h6><A href="#содержание">назад в содержание</A></h6>

```mysql
SELECT df_hub.event_id, df_event.event_time, df_event.event_type
FROM df_event
         JOIN df_hub ON df_hub.event_id = df_event.event_id
WHERE df_event.event_type IN ('purchase')
LIMIT 5;
```

| event_id                             | event_time              | event_type |
|--------------------------------------|-------------------------|------------|
| 00003fee-0add-4a9d-88f8-30ce8b26d59b | 2019-11-11 07:05:09 UTC | purchase   |
| 00004937-3bc0-4561-9649-24f81fdffedf | 2019-11-05 09:11:28 UTC | purchase   |
| 0000710a-145e-4099-97ff-a1ee1e07cd87 | 2019-11-11 10:38:42 UTC | purchase   |
| 0000a72c-bc87-41a2-bb18-f8d8f4b21713 | 2019-11-09 04:17:29 UTC | purchase   |
| 0000befc-879c-43c2-bd1f-19e8f3f8e359 | 2019-11-12 12:09:25 UTC | purchase   |

<h3><A name="left_join">3. Запрос с <tt>'left join'</tt></A></h3>
<h6><A href="#содержание">назад в содержание</A></h6>

```mysql
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
```

| event_type | user_id   |
|------------|-----------|
| view       | 513408484 |
| view       | 511475012 |
| view       | 512565172 |
| view       | 569936678 |
| view       | 518566245 |

<h4>В данном случае, объединение не даст выборку, отличную от <tt>'INNER JOIN'</tt>, так как все таблицы связаны ссылками через ```df_hub``` , то есть в итоге объединенные таблицы будут сожерэать одинаковый набор данных (ключей)</h4>

<h3><A name="where_query">4. 5 запросов с <tt>'WHERE'</tt> с использованием разных операторов</A></h3>
<h6><A href="#содержание">назад в содержание</A></h6>

<h4>Выборка из трех таблиц с условиями <tt>'WHERE [AND, = >, IN, IS NOT NULL, BETWEEN]'</tt>:</h4>

```mysql
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
   OR DAY(cte_event.event_time) < '18' AND cte_prod.price > 500 AND cte_prod.brand IN ('midea');
```

| brand   | price | category_code                      | event_time          |
|---------|-------|------------------------------------|---------------------|
| volcano | 518.9 | appliances.environment.air_heater  | 2019-11-15 01:01:28 |
| volcano | 518.9 | appliances.environment.air_heater  | 2019-11-14 04:45:57 |
| volcano | 518.9 | appliances.environment.air_heater  | 2019-11-15 05:47:42 |
| volcano | 518.9 | appliances.environment.air_heater  | 2019-11-14 17:46:54 |
| volcano | 518.9 | appliances.environment.air_heater  | 2019-11-15 01:01:13 |
 
<h4>Но если изменить параметр сравнения в последнем условии <br>
<tt>OR DAY(cte_event.event_time) = '18'</tt> на <br>
<tt>OR DAY(cte_event.event_time) <= '18'</tt> <br>
то результат изменится:</h4>

| brand   | price   | category_code                          | event_time          |
|---------|---------|----------------------------------------|---------------------|
| midea   | 967.82  | appliances.environment.air_conditioner | 2019-11-08 16:59:07 |
| midea   | 967.82  | appliances.environment.air_conditioner | 2019-11-15 08:37:39 |
| midea   | 967.82  | appliances.environment.air_conditioner | 2019-11-08 16:58:42 |
| midea   | 967.82  | appliances.environment.air_conditioner | 2019-11-05 17:09:22 |
| volcano | 518.9   | appliances.environment.air_heater      | 2019-11-15 01:01:28 |
| volcano | 518.9   | appliances.environment.air_heater      | 2019-11-14 04:45:57 |
| volcano | 518.9   | appliances.environment.air_heater      | 2019-11-15 05:47:42 |
| volcano | 518.9   | appliances.environment.air_heater      | 2019-11-14 17:46:54 |
| volcano | 518.9   | appliances.environment.air_heater      | 2019-11-15 01:01:13 |