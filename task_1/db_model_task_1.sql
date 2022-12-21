-- CREATE TABLE "categories" -----------------------------------
--
CREATE TABLE categories (
	category_id VARCHAR NOT NULL,
	category_name VARCHAR NOT NULL,
	PRIMARY KEY(category_id),
	CONSTRAINT "unique_categories_category_id" UNIQUE(category_id));
-- CREATE TABLE "providers" -----------------------------------
--
CREATE TABLE providers (
 	provider_id VARCHAR NOT NULL,
	provider_name VARCHAR NOT NULL,
	PRIMARY KEY(provider_id),
	CONSTRAINT "unique_providers_provider_id" UNIQUE(provider_id));
-- CREATE TABLE "goods" -----------------------------------
--
 CREATE TABLE goods (
	goods_id VARCHAR NOT NULL,
	goods_name VARCHAR NOT NULL,
	provider_id VARCHAR NOT NULL,
	category_id VARCHAR NOT NULL,
	primary key(goods_id),
	--add link from goods to providers
	CONSTRAINT fk_goods_providers FOREIGN KEY (provider_id) REFERENCES providers(provider_id),
	--add link from goods to providers
	CONSTRAINT fk_goods_categories FOREIGN KEY (category_id) REFERENCES categories(category_id),
	--add data representation limitation (UNIQUE attribute)
	CONSTRAINT "unique_goods_goods_id" UNIQUE(goods_id),
	CONSTRAINT "unique_goods_provider_id" UNIQUE(provider_id),
	CONSTRAINT "unique_goods_category_id" UNIQUE(category_id));
-- CREATE TABLE "price" -----------------------------------
--
CREATE TABLE price (
	goods_id VARCHAR NOT NULL,
	price_datetime Timestamp With Time Zone NOT NULL,
	price_on_date Double Precision NOT NULL,
	--add link from price to goods
	CONSTRAINT fk_price_goods FOREIGN KEY (goods_id) REFERENCES goods(category_id),
	--add data representation limitation (UNIQUE attribute)
	CONSTRAINT "unique_price_goods_id" UNIQUE(goods_id));
-- CREATE TABLE "deliveries" -----------------------------------
--
CREATE TABLE deliveries (
	goods_id VARCHAR NOT NULL,
	delivery_date Timestamp With Time Zone NOT NULL,
	goods_unit Double Precision NOT NULL,
	goods_count Double Precision NOT NULL,
	--add link from deliveries to goods
	CONSTRAINT fk_deliveries_goods FOREIGN KEY (goods_id) REFERENCES goods(goods_id),
	--add data representation limitation (UNIQUE attribute)
	CONSTRAINT "unique_deliveries_goods_id" UNIQUE(goods_id));
-- CREATE TABLE "customers" ------------------------------------
--
CREATE TABLE customers (
	customer_id VARCHAR NOT NULL,
	customer_last_name Text NOT NULL,
	customer_first_name Text NOT NULL,
	PRIMARY KEY(customer_id),
	--add data representation limitation (UNIQUE attribute)
	CONSTRAINT "unique_customers_customer_id" UNIQUE(customer_id));
-- CREATE TABLE "purchases" ------------------------------------
--
CREATE TABLE purchases (
	purchase_id VARCHAR NOT NULL,
	customer_id VARCHAR NOT NULL,
	purchase_date Timestamp With Time Zone NOT NULL,
	PRIMARY KEY (purchase_id),
	--add link from deliveries to goods
	CONSTRAINT fk_purchase_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
	--add data representation limitation (UNIQUE attribute)
	CONSTRAINT "unique_purchases_purchase_id" UNIQUE(purchase_id),
	CONSTRAINT "unique_purchases_customer_id" UNIQUE( customer_id));
-- CREATE TABLE "purchase_item" --------------------------------
--
CREATE TABLE purchase_item (
	purchase_id VARCHAR NOT NULL,
	goods_id VARCHAR NOT NULL,
	goods_count Double Precision NOT NULL,
	purchase_price Double Precision NOT NULL,
	--add link from deliveries to goods
	CONSTRAINT fk_purchase_item_purchase FOREIGN KEY (purchase_id) REFERENCES purchases(purchase_id),
	CONSTRAINT fk_purchase_item_goods FOREIGN KEY (goods_id) REFERENCES goods(goods_id),
	--add data representation limitation (UNIQUE attribute)
	CONSTRAINT "unique_purchase_item_goods_id" UNIQUE(goods_id),
	CONSTRAINT "unique_purchase_item_purchase_id" UNIQUE(purchase_id));