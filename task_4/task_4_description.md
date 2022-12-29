<h1>Task 4</h1>
<br>


<h1><A name="содержание">Содержание:</A></h1>
<h2><A href="#создание-базы-данных">1. Создание базы данных</A></h2>
<h2><A href="#создание-табличных-пространств-и-ролей">2. Создание табличных пространств и ролей</A></h2>
<h2><A href="#создание-схемы-данных">3. Создание схемы данных</A></h2>
<h2><A href="#распределение-таблиц-по-схемам">4. Распределение таблиц по схемам табличным пространствам</A></h2>
<h2><A href="#скрипт-создания-таблиц">5. Скрипт создания таблиц</A></h2>
<hr>

<br>
<h2><a name="создание-базы-данных">1. Создание базы данных</a></h2>
<h6><a href="#содержание">назад в содержание</a></h6>
<br>

<h3>Создана база данных <tt>ddl-task</tt> в табличном пространстве <tt>pg_default</tt>:</h3>
<h3><tt># create database "ddl-task" with owner="pg-user" encoding='UTF-8' tablespace=pg_default;</tt></h3>
<img src="https://github.com/SolonnikovDV/otusDbProject/blob/master/task_4/1_create_db.png">
<hr>

<br>
<h2><a name="создание-табличных-пространств-и-ролей">2. Создание табличных пространств и ролей</a></h2>
<h6><a href="#содержание">назад в содержание</a></h6>
<br>

<h3>Создано табличное пространство <tt>my_tablespase</tt> в разделе <tt>/home/my_table_space_subtask</tt>:</h3>
<h3><tt># create tablespace my_tablespace owner "pg-user" location '/home/my_table_space_subtask/';</tt></h3>
<img src="https://github.com/SolonnikovDV/otusDbProject/blob/master/task_4/2_create_tablespace.png">
<hr>

<br>
<h2><a name="создание-схемы-данных">3. Создание схемы данных</a></h2>
<h6><a href="#содержание">назад в содержание</a></h6>
<br>

<h3>Создана схема <tt>my_new_schema</tt>:</h3>
<h3><tt># create schema if not exists my_new_schema authorization "pg-user";</tt></h3>
<img src="https://github.com/SolonnikovDV/otusDbProject/blob/master/task_4/3_create_new_schema.png">
<hr>


<br>
<h2><a name="распределение-таблиц-по-схемам">4. Распределение таблиц по схемам табличным пространствам</a></h2>
<h6><a href="#содержание">назад в содержание</a></h6>

<br>
<h3>Распределение таблиц:</h3>
<table>
  <colgroup span="2"></colgroup>
  <tr>
    <th>Таблица</th>
    <th>Тип</th>
    <th>Схема</th>
    <th>Табличное пространство</th>
  </tr>
  <tr>
    <td>category</td>
    <td>table</td>
    <td>public</td>
    <td>my_tablespace</td>
  </tr>
  <tr>
    <td>product</td>
    <td>table</td>
    <td>public</td>
    <td>my_tablespace</td>
  </tr>
  <tr>
    <td>vendor</td>
    <td>partition table</td>
    <td>my_new_schema</td>
    <td>default</td>
  </tr>
  <tr>
    <td>vendor_a</td>
    <td>table</td>
    <td>my_new_schema</td>
    <td>default</td>
  </tr>
  <tr>
    <td>vendor_h</td>
    <td>table</td>
    <td>my_new_schema</td>
    <td>default</td>
  </tr>
  <tr>
    <td>vendor_l</td>
    <td>table</td>
    <td>my_new_schema</td>
    <td>default</td>
  </tr>
  <tr>
    <td>vendor_s</td>
    <td>table</td>
    <td>my_new_schema</td>
    <td>default</td>
  </tr>
</table>
<br>

<h3>Распредение по схемам</h3>
<img src="https://github.com/SolonnikovDV/otusDbProject/blob/master/task_4/4_1_tables_in_user_schemas.png">
<br>

<h3>Распредение по табличным пространствам</h3>
<img src="https://github.com/SolonnikovDV/otusDbProject/blob/master/task_4/4_2_moving_table_to_tablespace.png">
<hr>

<br>
<h2><a name="скрипт-создания-страниц">5. Скрипт создания страниц</a></h2>
<h6><a href="#содержание">назад в содержание</a></h6>
<br>
<h3>Скрипт создания страниц доступен по <a href="https://github.com/SolonnikovDV/otusDbProject/blob/master/task_4/sql_script_table_create.sql">ссылке</h3>