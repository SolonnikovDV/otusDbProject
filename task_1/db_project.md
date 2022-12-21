# **Task 1: Спроектировать базу данных**

## 1. [**1. Схема БД и документация**](#1-схема-бд-и-документация)
## 2. [**2. Бизнес задачи БД**](#2-бизнес-задачи-бд)
## 3. [**3. Рекомендации к репликации**](#3-рекомендации-к-репликации)
## 4. [**4. Требования к резервному копированию**](#4-требования-к-резервному-копированию)
## 5. [**5. Ссылка на скрипт**](#5-ссылка-на-скрипт)
<br>


# **1. Схема БД и документация**

[Модель БД](https://github.com/SolonnikovDV/database_modeling/blob/main/task_1/db_model_screen.png) представляет собой 8 связанных таблиц:

   1. [Таблица `categories`:](#таблица-categories)
   2. [Таблица `price`:](#таблица-price)
   3. [Таблица `providers`:](#таблица-providers)
   4. [Таблица `deliveries`:](#таблица-deliveries)
   5. [Таблица `purchases`:](#таблица-purchases)
   6. [Таблица `purchase_item`:](#таблица-purchase_item)
   7. [Таблица `customers`:](#таблица-customers)
   8. [Таблица `goods`:](#таблица-goods)


Визуализация модели БД:
![Визуализация модели БД](https://github.com/SolonnikovDV/database_modeling/blob/main/task_1/db_model_screen.png?raw=true)
<br>
<br>

<!-- categories -->
## Таблица `categories`:
* * *
Описывает категории товаров и включает в себя 2 поля `category_id` и `category_name`.
<br> 
Где `category_id` является ключевым полем `PRIMARY KEY`.

<br>

Схема таблицы `Categories`:
| table_name |  column_name  |     data_type     |
|:-----------|:--------------|:------------------|
| categories | category_id   | character varying |
| categories | category_name | character varying |

<br>

<!-- price -->
## Таблица `price`:
* * *
Описывает динамику изменения стоимости товара и включает в себя 3 поля `goods_id`, `price_datetime` и `price_on_date`.
<br>
Где `goods_id` является внешним ключем `FOREIGN KEY` таблицы `goods`.
Проле `price_on_date` отражает величину стоимости товара на дату `price_datetime`.
Таблица отражает изменение цены на товар в течение времени и корректирует стоимость на заданную дату.

<br>

Схема таблицы `price`:
|table_name|column_name   |data_type               |
|----------|--------------|------------------------|
|price     |price_datetime|timestamp with time zone|
|price     |price_on_date |double precision        |
|price     |goods_id      |character varying       |

<br>

<!-- providers -->
## Таблица `providers`:
* * *
Описывает производителей товаров и включает в себя 2 поля `provider_id` и `provider_name`.
<br>
Где `provider_id` является ключевым полем `PRIMARY KEY`.

<br>

Схема таблицы `providers`:
|table_name|column_name   |data_type               |
|----------|--------------|------------------------|
|providers |provider_id   |character varying       |
|providers |provider_name |character varying       |

<br>

<!-- deliveries -->
## Таблица `deliveries`:
* * *
Описывает какой товар, в каком количестве и на какую даты был поставлен провайдером (производителем/поставщиком) и включает в себя 4 поля `delivery_date`, `goods_unit`, `goods_count` и `goods_id`.
<br>
Где `goods_id` является внешним ключем `FOREIGN KEY` таблицы `goods`.

<br>

Схема таблицы `deliveries`:
|table_name|column_name   |data_type               |
|----------|--------------|------------------------|
|deliveries|delivery_date |timestamp with time zone|
|deliveries|goods_unit    |double precision        |
|deliveries|goods_count   |double precision        |
|deliveries|goods_id      |character varying       |

<br>

<!-- purchases -->
## Таблица `purchases`:
* * *
Описывает какие товары и кем (какие покупателем) были выкуплен и включает в себя 3 поля `purchase_date`, `purchase_id` и `customer_id`.
<br>
Где `purchase_id` является лючевым полем `PRIMARY KEY` таблицы, а поле `customer_id` является внешним ключем `FOREIGN KEY` таблицы `customers`.

<br>

Схема таблицы `purchases`:
|table_name|column_name      |data_type               |
|----------|-----------------|------------------------|
|purchases |purchase_date    |timestamp with time zone|
|purchases |purchase_id      |character varying       |
|purchases |customer_id      |character varying       |

<br>

<!-- purchase_item -->
## Таблица `purchase_item`:
* * *
Описывает какой товар, в каком количестве и на какую даты был выкуплен и включает в себя 4 поля `goods_count`, `purchase_price`, `purchase_id` и `goods_id`.
<br>
Где `goods_id` является внешним ключем `FOREIGN KEY` таблицы `goods`, а поле `purchase_id` является внешним ключем `FOREIGN KEY` таблицы `purchases`.

<br>

Схема таблицы `purchase_item`:
|table_name|column_name      |data_type               |
|----------|-----------------|------------------------|
|purchase_item|goods_count   |double precision        |
|purchase_item|purchase_price|double precision        |
|purchase_item|purchase_id   |character varying       |
|purchase_item|goods_id      |character varying       |

<br>

<!-- customers -->
## Таблица `customers`:
* * *
Описывает покупателя и включает в себя 3 поля `customer_id`, `customer_last_name` и `customer_first_name`.
<br>
Где `customer_id` является лючевым полем `PRIMARY KEY` таблицы,.

<br>

Схема таблицы `customers`:
|table_name|column_name        |data_type               |
|----------|-------------------|------------------------|
|customers |customer_id        |character varying       |
|customers |customer_last_name |text                    |
|customers |customer_first_name|text                    |

<br>

<!-- goods -->
## Таблица `goods`:
* * *
Описывает продукт, его название, категорию, а также указывает его производителя и включает в себя 4 поля `goods_id`, `goods_name`, `provider_id` и `category_id`.
<br>
Где `goods_id` является лючевым полем `PRIMARY KEY` таблицы, а поле`provider_id` является внешним ключем `FOREIGN KEY` таблицы `providers`, поле `category_id` является внешним ключем `FOREIGN KEY` таблицы `categories`.

<br>

Схема таблицы `goods`:
|table_name|column_name        |data_type               |
|----------|-------------------|------------------------|
|goods     |goods_id           |character varying       |
|goods     |goods_name         |character varying       |
|goods     |provider_id        |character varying       |
|goods     |category_id        |character varying       |

<br>
<br>

<!--cases-->
# **2. Бизнес задачи БД**

Данная БД управляет движением товара от его закупки до реализации.
<br>
Связи между таблицами позволяют регистровать состояние сущности товара на каждом жизненного цикла этапе:
<br>
1. Количество закупленного проданного наименования товара, товара группы производителя
2. Сумма затраченных/вырученных денежных средств
3. Динамика изменения стоимости товара по наименованию, по группе производителя в разрезе временного промежутка
4. Косвенно позволяет определить сезонность товара (в случае, когда наблюдается высокая конверсия по категории/наименованию)
5. Определяет частоту покупок по покупателю
6. Определяет частоту поставок по производителю/провайдеру

<br>

Перспектива:
<br>
1. Реализация таблицы возвратов `returns` (поля: `goods_id`, `customer_id`, `purchase_id`, `id_cause_of_return`) и таблицы причин возвратов `causes_of_returns` (поля:  `cause_of_return_id`, `cause_describe`) позволит вести статистику причина возврата (брак/дефект, размер, иные потребительсие свойства не удовлетворившие покупаателя), а также статистику по поставщику продукции, включая разработку скоринговой модели оценки привлекательности поставщика.
2. Разработка скоринговой модели оценки привлекательности покупателя и расчет персональной скидки покупаателю.<br>
Для это должна быть разработана таблица `discount`  с полями `goods_id` (связб с таблицей `goods`), `customer_id` (связь с таблицей `customers`), `personal_discount`.
<br>
<br>
<!--replicate-->

# **3. Рекомендации к репликации**

Для обеспечения отказоустойчивости инфраструктуры предлагаем испольховать физический тип репликации.
<br>
Частота выполнения репликаций не определена.
<br>
<br>
<!--copy-->

# **4. Требования к резервному копированию**

В качестве способа резервного копирования базыд данных предлагаем использовать "горячее" копирование без остановки базы данных. Перспектива разватия - инкрементальное копирование базы данных. 
<br>
Частота резервного копирования не определена. Однако, в случае реализиации инкреметального копирования, вохможно установить почасовую частоту.
<br>
<br>

# **5. Ссылка на скрипт**
[Скрипт сценария создания таблиц](https://github.com/SolonnikovDV/database_modeling/blob/main/task_1/script_table_creation.sql)