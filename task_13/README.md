## TASK 13 
### DML: sorting, aggregation

### Using DB model:

<img src="/Users/dmitrysolonnikov/PycharmProjects/otusDbProject/task_13/ecom_events_db_model.png">


### Selection with most expansive and cheapest product (```max()```, ```min()```)
* First of all check dataset on NULL using ```CASE```:

```mysql
SELECT COUNT(
               CASE
                   WHEN brand IS NULL THEN 1
                   ELSE 0
                   END) AS is_NULL
FROM df_prod
WHERE length(brand) IS NULL
GROUP BY brand;
```

| is_NULL |
|:--------|
| 46877   |

* So on a next query we should keep in mind ```NULL``` objects in a ```brand``` field and skip them in a next selections
* Let's get the greatest and cheapest price grouped by brand:
    * get ```min()``` and ```max()``` values of the brand price:
  
```mysql
SELECT brand, min(price), max(price)
FROM df_prod
WHERE brand IS NOT NULL
GROUP BY brand
-- execution: 31 ms, fetching: 21 ms;
```
* or

```mysql
SELECT brand, min(price), max(price)
FROM df_prod
# WHERE brand IS NOT NULL
GROUP BY brand
HAVING brand IS NOT NULL
-- execution: 75 ms, fetching: 15 ms;
```

| brand   | min(price) | max(price) |
|:--------|:-----------|:-----------|
| a-case  | 1.26       | 154.44     |
| a-derma | 5.15       | 21.88      |
| a-elita | 8.49       | 73.28      |
| a-mega  | 41.19      | 218.8      |
| ...     | ...        | ...        |

* * *

* max and min price and total count of offers ```max(price)```, ```min(price)```, ```count(purchase)```:
  * In actual case under 'offer' we should mean event with status == 'purchase'
    * var with ```CTE``` and ```JOIN``` under hub table:

```mysql
WITH cte_prod AS (SELECT product_id, brand, price
                  FROM df_prod
                  WHERE brand IS NOT NULL),
     cte_event AS (SELECT event_id, event_type
                   FROM df_event
                   WHERE event_type IN ('purchase'))
SELECT cte_prod.brand,
       max(cte_prod.price)         AS max_price,
       min(cte_prod.price)         AS min_price,
       -- the most expensive operation in that query 'count()'
       count(cte_event.event_type) AS total_purchases
FROM df_hub
         JOIN cte_prod ON cte_prod.product_id = df_hub.product_id
         JOIN cte_event ON cte_event.event_id = df_hub.event_id
GROUP BY cte_prod.brand;
-- execution: 16 s 503 ms for 29M rows
```

| brand   | max_price | min_price | total_purchases |
|:--------|:----------|:----------|:----------------|
| bertoni | 176.28    | 7.84      | 48              |
| samsung | 2574.04   | 1.26      | 75090           |
| nokian  | 363.72    | 35.75     | 3405            |
| xiaomi  | 2033.51   | 1.29      | 23194           |
| phantom | 15.44     | 15.44     | 26              |
| ...     | ...       | ...       | ...             |

  * Let's try to change ```WHERE event_type IN ('purchase'))``` in ```cte_event``` on ```HAVING event_type IN ('purchase'))```

```mysql
WITH cte_prod AS (SELECT product_id, brand, price
                  FROM df_prod
                  WHERE brand IS NOT NULL),
     cte_event AS (SELECT event_id, event_type
                   FROM df_event
                   HAVING event_type IN ('purchase'))
SELECT cte_prod.brand,
       max(cte_prod.price)         AS max_price,
       min(cte_prod.price)         AS min_price,
       # the most expensive operation in that query 'count()'
       count(cte_event.event_type) AS total_purchases
FROM df_hub
         JOIN cte_prod ON cte_prod.product_id = df_hub.product_id
         JOIN cte_event ON cte_event.event_id = df_hub.event_id
GROUP BY cte_prod.brand;
```

  * It will be works, but a little bit longer

```text
execution: 19 s 219 ms, fetching: 18 ms
```

* * *

### Cheapest and expensive product in category:
* Using ```CTE```, ```JOIN```, ```JSON``` as output format of information about price and product id:

```mysql
WITH cte_min AS (SELECT a.brand, a.product_id, a.price
                 FROM df_prod a
                          JOIN
                      (SELECT b.brand, min(b.price) as maxPrice
                       FROM df_prod b
                       GROUP BY b.brand) b ON a.brand = b.brand AND
                                              a.price = b.maxPrice),
     cte_max AS (SELECT a.brand, a.product_id, a.price
                 FROM df_prod a
                          JOIN
                      (SELECT b.brand, max(b.price) as minPrice
                       FROM df_prod b
                       GROUP BY b.brand) b ON a.brand = b.brand AND
                                              a.price = b.minPrice)
SELECT cte_min.brand,
       JSON_OBJECT(
               'min', JSON_OBJECT('product_id', cte_min.product_id, 'price', cte_min.price),
               'max', JSON_OBJECT('product_id', cte_max.product_id, 'price', cte_max.price)
           ) AS max_min_price_of_product
FROM cte_min
         JOIN cte_max ON cte_min.brand = cte_max.brand;
```

| brand   | max\_min\_price\_of\_product                                                                         |
|:--------|:-----------------------------------------------------------------------------------------------------|
| a-case  | {"max": {"price": 154.44, "product\_id": 18001563}, "min": {"price": 1.26, "product\_id": 18001300}} |
| a-case  | {"max": {"price": 154.44, "product\_id": 18001563}, "min": {"price": 1.26, "product\_id": 18001340}} |
| a-derma | {"max": {"price": 21.88, "product\_id": 17601427}, "min": {"price": 5.15, "product\_id": 17600861}}  |
| a-derma | {"max": {"price": 21.88, "product\_id": 17601428}, "min": {"price": 5.15, "product\_id": 17600861}}  |
| a-elita | {"max": {"price": 73.28, "product\_id": 32900095}, "min": {"price": 8.49, "product\_id": 32900083}}  |
| a-mega  | {"max": {"price": 218.8, "product\_id": 15200062}, "min": {"price": 41.19, "product\_id": 15200028}} |

 * can't find the way to union product_id values under array with the same price

* Using 

* * *

### Selection of products count under brand with using ROLLUP:

```mysql
WITH cte_prod AS (SELECT product_id, brand, price
                  FROM df_prod
                  WHERE brand IS NOT NULL)
SELECT cte_prod.brand,
       count(cte_prod.product_id) AS products_count,
       cte_prod.product_id as product
FROM df_hub
         JOIN cte_prod ON cte_prod.product_id = df_hub.product_id
GROUP BY cte_prod.brand, cte_prod.product_id WITH ROLLUP;
```

| brand   | products\_count | product  |
|:--------|:----------------|:---------|
| ...     | ..              | ...      |
| a-derma | 2               | 21900351 |
| a-derma | 6               | 21900512 |
| a-derma | 185             | null     |
| a-elita | 45              | 32900083 |
| a-elita | 68              | 32900095 |
| a-elita | 113             | null     |

* So as we can see ```ROLLUP``` gived us a ```NULL``` as a subtotal
* To fix that we can do upper selection (```total_cte``` and ```endless_cte```) with grouping by brand and a total count only:

```mysql
WITH endless_cte AS (with total_cte AS (WITH cte_prod AS (SELECT product_id, brand
                                                          FROM df_prod
                                                          WHERE brand IS NOT NULL)
                                        
                                        SELECT cte_prod.brand,
                                               count(cte_prod.product_id) AS products_count,
                                               cte_prod.product_id        as product
                                        FROM df_hub
                                                 JOIN cte_prod ON cte_prod.product_id = df_hub.product_id
                                        GROUP BY cte_prod.brand, cte_prod.product_id
                                        WITH ROLLUP)
                     
                     SELECT total_cte.brand                AS brand,
                            total_cte.products_count       AS products_count,
                            total_cte.product              as product,
                            CASE
                                WHEN total_cte.product IS NULL THEN 'TOTAL'
                                ELSE total_cte.product END AS total_count
                     FROM total_cte)

SELECT endless_cte.brand, endless_cte.products_count
FROM endless_cte
WHERE endless_cte.total_count IN ('TOTAL');
```

| brand     | products\_count |
|:----------|:----------------|
| a-case    | 4252            | 
| a-derma   | 185             | 
| a-elita   | 113             | 
| a-mega    | 343             |
| aardwolf  | 47              | 
| ....      | ....            |

* Works perfectly

* ```ROLLUP``` with ```GROUPING()```

```mysql
WITH cte_prod AS (SELECT product_id, brand
                  FROM df_prod
                  WHERE brand IS NOT NULL)
SELECT IF(
            GROUPING (cte_prod.product_id) = 'TOTAL',
            cte_prod.brand, concat('Total count of products of the brand: ',
            cte_prod.brand)
           ) AS brand,
       IF(
            GROUPING (cte_prod.product_id), '----- >>>',
            cte_prod.product_id
           ) AS product,
       count(cte_prod.product_id) AS products_count
FROM df_hub
         JOIN cte_prod
              ON cte_prod.product_id = df_hub.product_id
GROUP BY cte_prod.brand, cte_prod.product_id
WITH ROLLUP;
```

| brand                                         | product  | products\_count |
|:----------------------------------------------|:---------|:----------------|
| a-derma                                       | 21900351 | 2               |
| a-derma                                       | 21900512 | 6               |
| Total count of products of the brand: a-derma | ----->>> | 185             |
| a-elita                                       | 32900083 | 45              |
| a-elita                                       | 32900095 | 68              |
| Total count of products of the brand: a-elita | ----->>> | 113             |


