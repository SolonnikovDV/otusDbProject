<h1>Task 7</h1>
<br>


<h1><A name="содержание">Содержание:</A></h1>
<h2><A href="#data-download-from">1. Источник данных</A></h2>
<h2><A href="#create-indexes">2. Написать запрос суммы очков с группировкой и сортировкой по годам</A></h2>
<h2><A href="#return-explain-text">3. Написать cte для суммы очков с группировкой и сортировкой по годам</A></h2>
<h2><A href="#full-text-index">4. Используя функцию LAG вывести кол-во очков по всем игрокам за текущий код и за предыдущий</A></h2>
<hr>

<br>
<h2><A name="data-download-from">1. Источник данных</A></h2>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>
<h3>Для данного задания создана таблица <tt>statistic</tt> в базе данных:</h3>

`CREATE TABLE statistic(`<br>
`player_name VARCHAR(100) NOT NULL,`<br>
`player_id INT NOT NULL,`<br>
`year_game SMALLINT NOT NULL CHECK (year_game > 0),`<br>
`points DECIMAL(12,2) CHECK (points >= 0),`<br>
`PRIMARY KEY (player_name,year_game)`<br>
`);`<br>
<br>
<h3>Таблица зполнена следующими данными:</h3>
<br>

`INSERT INTO`<br>
`statistic(player_name, player_id, year_game, points)`<br>
`VALUES`<br>
`('Mike',1,2018,18),`<br>
`('Jack',2,2018,14),`<br>
`('Jackie',3,2018,30),`<br>
`('Jet',4,2018,30),`<br>
`('Luke',1,2019,16),`<br>
`('Mike',2,2019,14),`<br>
`('Jack',3,2019,15),`<br>
`('Jackie',4,2019,28),`<br>
`('Jet',5,2019,25),`<br>
`('Luke',1,2020,19),`<br>
`('Mike',2,2020,17),`<br>
`('Jack',3,2020,18),`<br>
`('Jackie',4,2020,29),`<br>
`('Jet',5,2020,27);`<br>

<h3>Полученный датасет:</h3>

`SELECT * `<br>
`FROM statistic `<br>
`ORDER BY year_game ASC;`<br>

|player_name|player_id|year_game|points|
|-----------|---------|---------|------|
|Mike       |        1|     2018| 18.00|
|Jack       |        2|     2018| 14.00|
|Jackie     |        3|     2018| 30.00|
|Jet        |        4|     2018| 30.00|
|Luke       |        1|     2019| 16.00|
|Mike       |        2|     2019| 14.00|
|Jack       |        3|     2019| 15.00|
|Jackie     |        4|     2019| 28.00|
|Jet        |        5|     2019| 25.00|
|Luke       |        1|     2020| 19.00|
|Mike       |        2|     2020| 17.00|
|Jack       |        3|     2020| 18.00|
|Jackie     |        4|     2020| 29.00|
|Jet        |        5|     2020| 27.00|
<hr>

<br>
<h2><A name="create-indexes">2. Написать запрос суммы очков с группировкой и сортировкой по годам</A></h2>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>

<h3>Решение зазачи простым запросом через использование аггрегурующих функций <tt>sum(points)</tt> - подсчет сумммы очков и <tt>GROUP BY</tt> - группировка (схлопывание) по заданному полю:</h3>
<br>

`-- get sum of points by year with simple query ---`<br><br>
`SELECT year_game, sum(points)`<br>
`FROM statistic`<br>
`GROUP BY year_game `<br>
`ORDER BY year_game ASC ;`<br>
<br>

<h3>Полученный датасет:</h3>

|year_game|sum   |
|---------|------|
|     2018| 92.00|
|     2019| 98.00|
|     2020|110.00|

<hr>

<br>
<h2><A name="return-explain-text">3. Написать cte для суммы очков с группировкой и сортировкой по годам</A></h2>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>

<h3>Решение зазачи через представление <tt>WITH [cte_name] AS (SELECT ... FROM ...)</tt> и аггрегурующие функции <tt>sum(points)</tt> - подсчет сумммы очков и <tt>GROUP BY</tt> - группировка (схлопывание) по заданному полю:</h3>
<br>

`-- get sum of points by year with CTE ------------`<br><br>
`WITH total_poins AS (`<br>
`SELECT year_game, sum(points) AS total_points`<br>
`FROM statistic`<br>
`GROUP BY year_game`<br>
`ORDER BY year_game asc )`<br>
`SELECT * FROM statistic total_poins;`<br>
<br>

<h3>Полученный датасет:</h3>

|year_game|total_points|
|---------|------------|
|     2018|       92.00|
|     2019|       98.00|
|     2020|      110.00|

<hr>


<br>
<h2><A name="full-text-index">4. Используя функцию LAG вывести кол-во очков по всем игрокам за текущий код и за предыдущий</A></h6>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>

<h3>Решение зазачи через оконную функцию <tt>OVER (ORDER BY ...)</tt> с фильтром <tt>NULL</tt> полей через CTE:</h3>
<br>

`-- get sum of points by year with LAG ------------`<br><br>
`WITH windows AS (`<br>
`SELECT player_name , player_id, year_game ,lag(sum(points ), 1) OVER(PARTITION BY year_game  ORDER BY points ) AS total_points`<br>
`FROM statistic`<br>
`WHERE year_game >= (SELECT (max(year_game)-1) FROM statistic)`<br>
`GROUP BY player_name , player_id , year_game  `<br>
`ORDER BY year_game, player_id asc`<br>
`)`<br>
`SELECT * FROM windows`<br>
`WHERE total_points NOTNULL ;`<br>
<br>

<h3>Полученный датасет:</h3>

|player_name|player_id|year_game|total_points|
|-----------|---------|---------|------------|
|Luke       |        1|     2019|       15.00|
|Jack       |        3|     2019|       14.00|
|Jackie     |        4|     2019|       25.00|
|Jet        |        5|     2019|       16.00|
|Luke       |        1|     2020|       18.00|
|Jack       |        3|     2020|       17.00|
|Jackie     |        4|     2020|       27.00|
|Jet        |        5|     2020|       19.00|


<hr>