# **Task 2: Логические ограничения и индексирование**

# **Содержание:**
## 1. [**1. Структура базы данных**](#1-структура-базы-данных)
## 2. [**2. Определена кардинальность полей**](#2-определена-кардинальность-полей)
## 3. [**3. Индексы**](#3-индексы)
## 4. [**4. Логические ограничения**](#4-логические-ограничения)
## 5. [**5. Ссылка на скрипт**](#5-ссылка-на-скрипт)
<br>


# **1. Структура базы данных** 

[Модель БД](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/db_model_screen.png) представляет собой 26 связанных таблиц:

<br>

| N   | Table name                    |
|-----|-------------------------------|
|1. |[`container_properties`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/container_properties.sql)|
|2. |[`stock`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/stock.sql)|
|3. |[`price`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/price.sql)|
|4. |[`customer_loyality_breakdown`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/customer_loyality_breakdown.sql)|
|5. |[`bonus_rubles`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/bonus_rubles.sql)|
|6. |[`rating`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/rating.sql)|
|7. |[`brand`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/brand.sql)|
|8. |[`location`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/location.sql)|
|9. |[`breakdown`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/breakdown.sql)|
|10. |[`status`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/status.sql)|
|11. |[`to_pick_point_transaction`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/to_pick_point_transaction.sql)|
|12. |[`product_spec`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/product_spec.sql)|
|13. |[`category`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/category.sql)|
|14. |[`pick_point`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/pick_point.sql)|
|15. |[`agent_type`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/agent_type.sql)|
|16. |[`product`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/product.sql)|
|17. |[`customer`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/customer.sql)|
|18. |[`individual_attribute`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/individual_attribute.sql)|
|19. |[`container`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/container.sql)|
|20. |[`unit_properties`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/unit_properties.sql)|
|21. |[`product_properties`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/product_properties.sql)|
|22. |[`company_attribute`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/company_attribute.sql)|
|23. |[`vendor`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/vendor.sql)|
|24. |[`delivery`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/delivery.sql)|
|25. |[`supply_order`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/supply_order.sql)|
|26. |[`purchase_order`](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/tables/purchase_order.sql)|

<br>

Визуализация модели БД:
![Визуализация модели БД](https://github.com/SolonnikovDV/database_modeling/blob/main/task_2/db_model_screen.png?raw=true)

<br>

[# назад в оглавление](#содержание) 
- - -
<br>
<br>


# **2. Определена кардинальность полей**
<br>

## Определены поля ключевые / уникальные поля:
Таким полями выступают:

|Type   |Dectription  |Code       |
|-------|-------------|-----------|
|первичный ключ|натуральное число, последующее значение всегда больше предыдущего, отвечает требования уникальности| `PRIMARY KEY()`| 
|уникальное поле|определяет ограничение поля по признаку уникальности, работает со всеми типами данных|`CONSTRAINT <set_name> UNIQUE(<your_field>)`|
|внешний ключ|ссылка на поле внешней таблицы, типы данных для `<your_field>` и `<field_of_external_table>` должны совпадать|`FOREIGN KEY (<your_field>) REFERENCES <external_table_name> (<field_of_external_table>)`|
<br>

[# назад в оглавление](#содержание) 
- - -
<br>
<br>

# **3. Индексы**
<br>

## Добавлены простые и композитные индексы с описанием. Перечень таблиц с индексами:
<br>

| N   | Table name                       |Indexes                            |
|-----|----------------------------------|-----------------------------------|
| 1.  |`agent_type`                      |1 single index                     |
| 2.  |`bonus_rubles`                    |1 single index                     |
| 3.  |`brand`                           |1 composite index                  |
| 4.  |`category`                        |1 single index                     |
| 5.  |`company_attribute`               |2 single index                     |
| 6.  |`containers_on_pick_point`        |1 single index                     |
| 7.  |`container_properties`            |1 coposite index, 2 single indexes |
| 8.  |`customer`                        |1 single index                     |
| 9.  |`customer_loyality_breakdown`     |1 coposite index, 1 single index   |
| 10. |`delivery`                        |1 single index                     |
| 11. |`individual_attribute`            |3 single indexes                   |
| 12. |`location`                        |1 composite index                  |
| 13. |`pick_point`                      |2 single indexes                   |
| 14. |`price`                           |1 composite index                  |
| 15. |`product_properties`              |2 single indexes                   |
| 16. |`product_spec`                    |1 single index                     |
| 17. |`product`                         |1 coposite index, 3 single indexes |
| 18. |`purchase_order`                  |1 single index                     |
| 19. |`stock`                           |1 single index                     |
| 18. |`supply_order`                    |3 single indexes                   |
| 19. |`vendor`                          |1 composite index                  |
| 20. |`to_pick_point_transaction`       |1 single index                     |

<br>

[# назад в оглавление](#содержание) 
- - -
<br>
<br>

# **4. Логические ограничения** 
<br>
### Добавлены ограничения слудующего вида
<br>

|Type    |Descritption   |Code    |
|--------|---------------|--------|
|количество|ограничивает параметры вводимых значений, значение может находиться в диапазоне больше, либо равно нулю;<br>ограничение распространаятеся на количественные показатели в том числе цену|`CONSTRAINT "enter_your_check_procedure_name" CHECK(<field_for_check> >= 0)`|
|дата|отсекает значение поля в формате `timestamp` , если оно хронологически ниже текущей даты|`CONSTRAINT "enter_your_check_procedure_name" CHECK(<field_for_check> >= NOW()::timestamp)`|
|пустое значение|проверка на пустое значение `NULL`, поля для которых включена такая проверка не могут принимать значения `NULL`|`<field_name> NOT NULL`|

<br>

[# назад в оглавление](#содержание) 
- - -
<br>
<br>

# **5. Ссылка на скрипт**
[Скрипты со сценариями создания таблиц](https://github.com/SolonnikovDV/database_modeling/tree/main/task_2/tables)

<br>

[# назад в оглавление](#содержание) 
- - -
<br>
<br>