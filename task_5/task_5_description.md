<h1>Task 5</h1>
<br>


<h1><A name="содержание">Содержание:</A></h1>
<h2><A href="#используемые-даные">1. Используемые данные</A></h2>
<h2><A href="#запрос-regexp">2. Запрос по своей базе с регулярным выражением</A></h2>
<h2><A href="#запрос-select-join">3. Запроc по своей базе с использованием <tt>LEFT JOIN</tt> и <tt>INNER JOIN</tt></A></h2>
<h2><A href="#запрос-insert-returning">4. Запрос на добавление данных с выводом информации о добавленных строках <tt>RETURNING</tt></A></h2>
<h2><A href="#запрос-update-from">5. Запрос с обновлением данных с <tt>UPDATE FROM</tt></A></h2>
<h2><A href="#delete-using-join">6. Запрос для удаления данных с оператором <tt>DELETE</tt> используя <tt>JOIN</tt> с другой таблицей с помощью <tt>USING</tt></A></h2>
<h2><A href="#утилита-copy">7. Пример использования утилиты <tt>COPY</tt></A></h2>
<hr>

<br>
<h2><A name="используемые-даные">1. Используемые данные</A></h2>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>
<h3>Данные взяты с публичного <tt><a href="https://github.com/dword4/nhlapi">API</tt></a>, поставляющего информацию о командах NHL</h3>
<h3>Скрипт извлечения, преобразования и загрузки данных в Postgres <a href="https://github.com/SolonnikovDV/otusDbProject/blob/master/task_5/get_data_api.py">здесь</a></h3>
<h3>Скрипты подготовки таблиц, полученных из датафреймов <a href="https://github.com/SolonnikovDV/otusDbProject/blob/master/task_5/tables_setup.sql">здесь</a></h3>
<h3>Скрипты выполнения задач Task 5 <a href="https://github.com/SolonnikovDV/otusDbProject/blob/master/task_5/task_examples.sql">здесь</a></h3>
<hr>

<br>
<h2><A name="запрос-regexp">2. Запрос по своей базе с регулярным выражением</A></h2>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>
<h3>Запрос по таблице <tt>df_person</tt> с условием найти все поля содержащие в начале строку <tt>Left</tt>:
<h3>select "fullName", "position.name" , "link"</h3>
<h3>from df_person dp</h3>
<h3>where "position.name"  like 'Left%';</h3><h3>
<br>
<h3>Получаем выборку по признаку <tt>Left</tt>:</h3>

|fullName                |position.name|link                  |
|------------------------|-------------|----------------------|
|Tomas Tatar             |Left Wing    |/api/v1/people/8475193|
|Erik Haula              |Left Wing    |/api/v1/people/8475287|
|Ondrej Palat            |Left Wing    |/api/v1/people/8476292|
|Miles Wood              |Left Wing    |/api/v1/people/8477425|
|Jesper Bratt            |Left Wing    |/api/v1/people/8479407|
|...						|			  |						 |
<hr>

<br>
<h2><A name="запрос-select-join">3. Запроc по своей базе с использованием <tt>LEFT JOIN</tt> и <tt>INNER JOIN</tt></A</h2>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>
<h3><A href="#left-join">3.1. <tt>LEFT JOIN</tt></A></h3>
<h3><A href="#right-join">3.2. <tt>RIGHT JOIN</tt></A></h3>
<h3><A href="#inner-join">3.3. <tt>INNER JOIN</tt></A></h3>
<br>

<h3><A name="#left-join">3.1. <tt>LEFT JOIN</tt></A></h3>
<h3>Запрос c <tt>LEFT JOIN</tt> по таблице <tt>df_person</tt>:
  <h3><tt>select "name", "teamName" , "division.name"</h3>
  <h3>from df_teams</h3>
  <h3>left join df_division on df_teams."division.id" = df_division."division.id";</h3></tt></h3><h3>
<br>
<h3>Получаем выборку <tt>LEFT JOIN</tt>>:</h3>

| # |name                 |teamName      |division.name|    |
|---|---------------------|--------------|-------------|----|
|1  |New Jersey Devils    |Devils        |Metropolitan |    |
|2  |New York Islanders   |Islanders     |Metropolitan |    |
|3  |New York Rangers     |Rangers       |Metropolitan |    |
|4  |Philadelphia Flyers  |Flyers        |Metropolitan |    |
|   |......				        |				       |			       |    |
|32 |Seattle Kraken       |Kraken        |Pacific      |    |
|33 |new team             |NT            |NULL         |-> запись не найдена    |

<h3><tt>LEFT JOIN</tt> не обнаружил записей в таблице справа <tt>df_division</tt> для строки #33 таблицы <tt>df_teams</tt></h3>
<br>
<h3>Запрос c <tt>INNER JOIN</tt> по таблице <tt>df_person</tt>:
  <h3><tt>sselect "name", "teamName" , "division.name"</h3>
  <h3>from df_teams</h3>
  <h3>inner join df_division on df_teams."division.id" = df_division."division.id";</h3></tt>
</h3>

<br>
<h3><A href="#right-join">3.2. <tt>RIGHT JOIN</tt></A></h3>
<h3>Запрос c <tt>RIGHT JOIN</tt> по таблице <tt>df_person</tt>:
  <h3><tt>select "name", "teamName" , "division.name"</h3>
  <h3>from df_teams</h3>
  <h3>left join df_division on df_teams."division.id" = df_division."division.id";</h3></tt></h3><h3>
<br>
<h3>Получаем выборку <tt>LEFT JOIN</tt>>:</h3>

| # |name                     |teamName                  |division.name|
|---|-------------------------|--------------------------|-------------|
|1  |New Jersey Devils        |Devils                    |Metropolitan |
|2  |New York Islanders       |Islanders                 |Metropolitan |
|3  |New York Rangers         |Rangers                   |Metropolitan |
|4  |Philadelphia Flyers      |Flyers                    |Metropolitan |
|   |......				            |				                   |			       |
|32 |Seattle Kraken           |Kraken                    |Pacific      |
|33 |NULL -> запись не найдена|NULL -> запись на найдена |Hellfire     |

<h3><tt>RIGHT JOIN</tt> не обнаружил записей в таблице слева <tt>df_teams</tt> для строки #33 таблицы <tt>df_teams</tt></h3>
<br>

<h3><A href="#inner-join">3.3. <tt>INNER JOIN</tt></A></h3>
<h3>Запрос c <tt>INNER JOIN</tt> по таблице <tt>df_person</tt>:
  <h3><tt>sselect "name", "teamName" , "division.name"</h3>
  <h3>from df_teams</h3>
  <h3>inner join df_division on df_teams."division.id" = df_division."division.id";</h3></tt>
</h3>

<br>
<h3>Получаем выборку <tt>INNER JOIN</tt>>:</h3>

| # |name                 |teamName      |division.name|
|---|---------------------|--------------|-------------|
|1  |New Jersey Devils    |Devils        |Metropolitan |
|2  |New York Islanders   |Islanders     |Metropolitan |
|3  |New York Rangers     |Rangers       |Metropolitan |
|4  |Philadelphia Flyers  |Flyers        |Metropolitan |
|   |......				 |				|			  |
|32 |Seattle Kraken       |Kraken        |Pacific      |
<h3><tt>INNER JOIN</tt> возвращает только те поля, где обнаружено взаимное совпадение значений полей, <tt>NULL</tt> значения при данном объединении отсутствуют</h3>
<hr>

<br>
<h2><A name="запрос-insert-returning">4. Запрос на добавление данных с выводом информации о добавленных строках - <tt>RETURNING</tt></A></h2>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>
<h3>За отображение сведений о выполненных изменениях с таблицей операциями <tt>UPDATE, INSERT, DELETE</tt> отвечает операция <tt>RETURNING(col1, col2, ...)</tt>:</h3>
<h3>
  <h3><tt>insert into df_division ("division.id" , "division.name" ) </h3> 
  <h3>values (666 , 'Hellfire') returning *;</tt></h3>
<h3>
<br>

|division.id | division.name |
|------------|---------------|
|666	       |Hellfire       |

<hr>

<br>
<h2><A name="запрос-update-from">5. Запрос с обновлением данных с <tt>UPDATE FROM</tt></A></h2>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>

<h3>
  Создадим таблицу <tt>new_table</tt> и добавим в нее пустые строки,содержащие только <tt>id</tt>
    <h3><tt>create table new_table (id bigint, name varchar, division_id int, division_name text);</tt></h3>
    <h3><tt>insert into new_table  values</tt></h3>
    <h3><tt>(1, null, null, null),</tt></h3>
    <h3><tt>(2, null, null, null),</tt></h3>
    <h3><tt>(3, null, null, null),</tt></h3>
    <h3><tt>(333, null, null, null);</tt></h3>
    <h3><tt>select * from new_table;</tt></h3>
</h3>
<br>

|id |name    |division_id    |division_name    |
|---|--------|---------------|-----------------|
|  1|NULL    |NULL           |NULL             |
|  2|NULL    |NULL           |NULL             |
|  3|NULL    |NULL           |NULL             |
|333|NULL    |NULL           |NULL             |

<h3>
Заполним таблицу данными из таблицы <tt>df_teams</tt> через оператор <tt>UPDATE</tt>:
    <h3><tt>with subquery AS (select "id", "name", "division.id" FROM df_teams)</tt></h3>
    <h3><tt>update new_table</tt></h3>
    <h3><tt>set "name" = subquery."name",</tt></h3>
    <h3><tt>"division_id" = subquery."division.id"</tt></h3>
    <h3><tt>from subquery</tt></h3>
    <h3><tt>where new_table."id" = subquery."id"</tt></h3>
    <h3><tt>returning *;</tt></h3>
</h3>
<br>

<h3>
  Получаем следующую таблицу:
</h3>
<br>

|id |name              |division_id|division_name    |
|---|------------------|-----------|-----------------|
|  1|New Jersey Devils |         18|NULL             |
|  2|New York Islanders|         18|NULL             |
|  3|New York Rangers  |         18|NULL             |
|333|new team          |       NULL|NULL             |

<h3>  
  Завершаем наполнение таблицы, добавляя данные из таблицы <tt>df_division</tt> через оператор <tt>UPDATE</tt>:
  <h3><tt>update new_table</tt></h3>
  <h3><tt>set "division_name" = df_division."division.name"</tt></h3>
  <h3><tt>from df_division</tt></h3>
  <h3><tt>where new_table.division_id = df_division."division.id"</tt></h3>
  <h3><tt>returning *;</tt></h3>
</h3>
<br>

<h3>
  Получаем следующую таблицу:
</h3>
<br>

|id |name              |division_id|division_name|
|---|------------------|-----------|-------------|
|  1|New Jersey Devils |         18|Metropolitan |
|  2|New York Islanders|         18|Metropolitan |
|  3|New York Rangers  |         18|Metropolitan |
|333|new team          |       NULL|NULL         |

<hr>


<br>
<h2><A name="delete-using-join">6. Запрос для удаления данных с оператором <tt>DELETE</tt> используя <tt>JOIN</tt> с другой таблицей с помощью <tt>USING</tt></A></h2>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>
<h3><A href="#delete-join">6.1. <tt>DELETE + JOIN</tt></A></h3>
<h3><A href="#delete-using">6.2. <tt>DELETE + USING</tt></A></h3>
<h3><A href="#delete-using-join">6.3. <tt>DELETE + USING + JOIN</tt></A></h3>
<br>
<h3>
  Во всех примерах используется созданная в предыдущем пункте таблица <tt>new_table</tt>
</h3>
<br>

<h3><A name="delete-join">6.1. <tt>DELETE + JOIN</tt></A></h3>
<h3><tt>delete from new_table where "name" in </tt></h3>
<h3><tt>(select new_table."name" </tt></h3>
<h3><tt>from new_table left join df_teams on new_table."name" = df_teams."name" </tt></h3>
<h3><tt>where df_teams."name" like '%Jersey%');</tt></h3>
<h3><tt>select * from new_table ;</tt></h3>
<br>
<h3>Получаем таблицу, из которой удалены строки, где значение в стобце <tt>name</tt> содержит строку <tt>Jersey</tt>:</h3>
<br>

|id |name              |division_id|division_name|
|---|------------------|-----------|-------------|
|333|new team          |       NULL|NULL         |
|  2|New York Islanders|         18|Metropolitan |
|  3|New York Rangers  |         18|Metropolitan |
<br>

<h3><A name="#elete-using">6.2. <tt>DELETE + USING</tt></A></h3>
<h3><tt>delete from new_table </tt></h3>
<h3><tt>using df_teams </tt></h3>
<h3><tt>where df_teams."name" = new_table."name" and df_teams."name" like '%Jersey%';</tt></h3>
<h3><tt>select * from new_table;</tt></h3>
<br>
<h3>Также получаем таблицу, из которой удалены строки, где значение в стобце <tt>name</tt> содержит строку <tt>Jersey</tt>:</h3>
<br>

|id |name              |division_id|division_name|
|---|------------------|-----------|-------------|
|333|new team          |       NULL|NULL         |
|  2|New York Islanders|         18|Metropolitan |
|  3|New York Rangers  |         18|Metropolitan |
<br>


<h3><A name="#delete-using-join">6.3. <tt>DELETE + USING + JOIN</tt></A></h3>
<h3>
  Попытка построить запрос оказалась неудачной. При выполнении удаляются все строки таблицы.
</h3>
<h3><tt>delete from new_table </tt></h3>
<h3><tt>using new_table as nt inner join df_teams on nt."name" = df_teams."name" </tt></h3>
<h3><tt>where df_teams."name" like '%team%';</tt></h3>
<h3><tt>select * from new_table;</tt></h3>
<br>

|id        |name         |division_id         |division_name          |
|----------|-------------|--------------------|-----------------------|
|empty row |empty row    |empty row		        |empty row			        |

<hr>

<br>
<h2><A name="утилита-copy">7. Пример использования утилиты <tt>COPY</tt></A></h2>
<h6><A href="#содержание">назад в содержание</A></h6>
<br>
<h3>В данном примере <tt>COPY</tt> использовалась для копирования данных из  <a href="https://github.com/SolonnikovDV/otusDbProject/tree/master/task_5/csv_tables">таблиц</a>: <tt>df_teams, df_conference, df_teame, df_person, new_table, </tt> в <tt>CSV</tt> файлы через <tt>psql shell</tt>:<a></h3>
<h3><tt>\copy [db-table] to [destination path] csv header;</tt></h3>
<img src="https://github.com/SolonnikovDV/otusDbProject/blob/master/task_5/copy_table_to_csv.png">