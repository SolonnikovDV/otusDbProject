<h1>Task 6</h1>
<br>


<h1><A name="содержание">Содержание:</A></h1>
<h2><A href="#data-download-from">1. Источник данных</A></h2>
<h2><A href="#create-indexes">2. Создать индексы к таблице БД</A></h2>
<h2><A href="#return-explain-text">3. Вернуть текстом результат команды <tt>explain</tt>,в которой используется данный индекс</A></h2>
<h2><A href="#full-text-index">4. Реализовать индекс для полнотекстового поиска</A></h2>
<h2><A href="#index-on-expression">5. Реализовать индекс на часть таблицы или индекс на поле с функцией</A></h2>
<hr>

<br>
<h2><A name="data-download-from">1. Источник данных</A></h2>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>
<h3>Для данного задания создана база данных <tt>index-task</tt> на <tt>Docker</tt> образе:</h3>

`docker exec -it sql-outs-project /bin/bash`<br>
`psql -U pg-user -W dml-task`<br>
`password`<br>
<br>
`CREATE DATABASE 'index-task' ----`<br>
`dml-task=# create database "index-task" with owner="pg-user" encoding='UTF-8' tablespace=pg_default;`<br>

<h3>Данные взяты с <tt>kaggle.com</tt> в формате <tt>csv</tt> файлов и загружены в соответствующие таблицы базы данных:</h3>
<br>

`-- CREATE TABLES from CSV files ----`<br>

`index-task=# create table books_data (title varchar, description varchar, authors varchar, image varchar, prewiewLlink varchar, publisher varchar, publisherDate varchar, infoLink varchar, categories varchar, ratingsCount float);`<br>

`index-task=# create table books_rating (id varchar, title varchar, price float, user_id varchar, prifileName varchar, "review/helpfulness"  varchar, "review/score" float, "review/time" bigint, "review/summary" varchar, "review/text" varchar);`<br>
<br>

`-- Load data from CSV to tables ----`<br>

`index-task=# \copy books_data from '/home/books_data.csv' csv header;`<br>
`COPY 212404`<br>

`index-task=# \copy books_rating from '/home/Books_rating.csv' csv header;`<br>
`COPY 3000000`<br>
<br>
<hr>

<br>
<h2><A name="create-indexes">2. Создать индексы к таблице БД</A></h2>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>
<h3><A href="#simple-index">2.1. Простой индекс</A></h3>
<h3><A href="#multifield-index">2.2. Составной индекс</A></h3>
<h3><A href="#explain-query-result">2.3. Результат команды <tt>EXPLAIN</tt> по каждому простому индексу</A></h3>
<br>
<h3>Создаем идексы для таблиц <tt>books_rating, books_data</tt></h3>
<br>

<h3><A name="simple-index">2.1. Простые индексы по одному полю</A></h3>
<br>

|table name  |field name    |index name               |index type|
|------------|--------------|-------------------------|----------|
|books_rating|review/score  |books_rating_review/score|btree     |
|books_data  |title         |books_data_title         |btree     |

<h3>Код:</h3>

`-- simple index ----` <br>
`CREATE INDEX "books_rating_review/score" ON books_rating USING btree( "review/score");`<br>
`CREATE INDEX "books_data_title" ON books_data USING btree(title);`<br>

<br>

<h3><A name="multifield-index">2.2. Составные индексы по нескольким полям</A></h3>
<br>

|table name  |field name                   |index name                 |index type|
|------------|-----------------------------|---------------------------|----------|
|books_rating|id, title                    |books_rating_title         |btree     |

<h3>Код:</h3>

`CREATE INDEX "books_rating_title" ON books_rating USING btree( id, title);`<br>

<br>

<h2><A name="explain-query-result">3. Результат команды <tt>EXPLAIN</tt> по каждому созданному индексу:</A></h2>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>
<h3><A href="#books_rating_review/score">3.1 Простой индекс "books_rating_review/score"</A></h3>
<h3><A href="#books_data_title">3.2 Простой индекс "books_data_title"</A></h3> 
<h3><A href="#books_rating_title">3.3 Составной "books_rating_title"</A></h3> 
<br>

<h3><A name="books_rating_review/score">3.1 Индекс "books_rating_review/score"</A></h4>

|table name  |field name    |index name               |index type|
|------------|--------------|-------------------------|----------|
|books_rating|review/score  |books_rating_review/score|btree     |

<h3>Код:</h3>

`explain select * from books_rating `<br>
`where "review/score" = 1;`<br>

<h3>Результат запроса: </h3>

|QUERY PLAN                                                                                      |
|------------------------------------------------------------------------------------------------|
|Bitmap Heap Scan on books_rating  (cost=3816.93..303561.39 rows=203419 width=719)               |
|  Recheck Cond: ("review/score" = '1'::double precision)                                        |
|  ->  Bitmap Index Scan on "books_rating_review/score"  (cost=0.00..3766.07 rows=203419 width=0)|
|        Index Cond: ("review/score" = '1'::double precision)                                    |
|JIT:                                                                                            |
|  Functions: 2                                                                                  |
|  Options: Inlining false, Optimization false, Expressions true, Deforming true                 |

<br>

<h3><A name="books_data_title">3.2 Простой индекс "books_data_title"</A></h4>

|table name  |field name    |index name               |index type|
|------------|--------------|-------------------------|----------|
|books_data  |title         |books_data_title         |btree     |

<h3><A href="#search-of-path">Код:</A></h3>

`explain select * from books_data `<br>
`where title ilike '%writing%';`<br>

<h3>Результат запроса: </h3>

|QUERY PLAN                                                                   |
|-----------------------------------------------------------------------------|
|Gather  (cost=1000.00..23410.37 rows=21 width=998)                           |
|  Workers Planned: 2                                                         |
|  ->  Parallel Seq Scan on books_data  (cost=0.00..22408.27 rows=9 width=998)|
|        Filter: ((title)::text ~~* '%writing%'::text)                        |


<br>

<h3><A name="books_rating_title">3.3 Составной индекс "books_rating_title"</A></h4>

|table name  |field name    |index name               |index type|
|------------|--------------|-------------------------|----------|
|books_rating|title, id     |books_rating_title       |btree     |

<h3>Код:</h3>

`explain select id, title, user_id, prifilename, "review/score" `<br>
`from books_rating where title like '%lexandra%';`

<h3>Результат запроса:</h3>

|QUERY PLAN                                                                       |
|---------------------------------------------------------------------------------|
|Gather  (cost=1000.00..296462.66 rows=262 width=87)                              |
|  Workers Planned: 2                                                             |
|  ->  Parallel Seq Scan on books_rating  (cost=0.00..295436.46 rows=109 width=87)|
|        Filter: ((title)::text ~~ '%lexandra%'::text)                            |
|JIT:                                                                             |
|  Functions: 4                                                                   |
|  Options: Inlining false, Optimization false, Expressions true, Deforming true  |

<hr>


<br>
<h2><A name="full-text-index">4. Реализовать индекс для полнотекстового поиска/A</h2>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>
<h3>Подготовка полей таблицы для полнотекстового поиска:</h3>
<br>
`-- change type of column "review/summary", "review/text" to TEXT`<br>
`alter table books_rating ALTER COLUMN "review/summary" TYPE TEXT;`<br>
`alter table books_rating ALTER COLUMN "review/text" TYPE TEXT;`<br>
<br>

<h3>Создаем расширения <tt>pg_trgm</tt> и <tt>btree_gin</tt> для <tt>Postgres</tt> для реализации полнотекстового поиска:</h3>

`-- create extension trgm, btree_gin`<br>
`CREATE EXTENSION pg_trgm;`<br>
`CREATE EXTENSION btree_gin;`<br>
<br>

<h3>Создаем индекс:</h3>
`-- create index`<br>
`create index text_trgm_idx on books_rating using gin("review/summary" gin_trgm_ops);`<br>

<h3>Индекс <tt>trgm</tt> выполняет полнотектовый поиск по ключевому слову "шаблону" без учета склоняемых форм с указанием признака соответствия "шаблону". Для указания точности следует вручную указать лимит:</h3>

`-- set level of similarity on a postgres session (will turn back to a default on session exit)`<br>
`select set_limit(0.1); `

<h3>Выполняем поиск с ключевым словом "best" с сортировкой по степени соответствия шаблону:</h3>

`select "review/summary", similarity("review/summary", 'best')`<br>
`from books_rating where title % 'best'`<br>
`order by similarity desc ;`

<h3>Результат команды <tt>EXPLAIN</tt>:</h3>

|QUERY PLAN                                                                               |
|-----------------------------------------------------------------------------------------|
|Gather Merge  (cost=297364.71..300356.02 rows=25638 width=36)                            |
|  Workers Planned: 2                                                                     |
|  ->  Sort  (cost=296364.69..296396.74 rows=12819 width=36)                              |
|        Sort Key: (similarity("review/summary", 'best'::text)) DESC                      |
|        ->  Parallel Seq Scan on books_rating  (cost=0.00..295490.05 rows=12819 width=36)|
|              Filter: ((title)::text % 'best'::text)                                     |
|JIT:                                                                                     |
|  Functions: 4                                                                           |
|  Options: Inlining false, Optimization false, Expressions true, Deforming true          |

<hr>

<br>
<h2><A name="index-on-expression">5. Реализовать индекс на часть таблицы или индекс на поле с функцией</A></h2>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>
<h3>Данная часть реализована в данном <A name="search-of-path">запросе</A></h3>
<h3>
<hr>