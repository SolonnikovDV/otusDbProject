-- CREATE TABLE "vendor" in 'my_new_schema' schema using partition with expression --------------
CREATE TABLE my_new_schema.vendor (
	"id" serial,
	"name" varchar not null,
	"address" json not null)
-- expression returns first lit of vendors name in lower case
partition by list (left(lower(name), 1));

-- CREATE INDEX ----------------------------------------------
CREATE INDEX ON my_new_schema.vendor (name);

-- CREATE TABLES SECTIONS of master partition table ----------
CREATE TABLE my_new_schema.vendor_a
PARTITION OF my_new_schema.vendor FOR VALUES IN ('a');

CREATE TABLE my_new_schema.vendor_s
PARTITION OF my_new_schema.vendor FOR VALUES IN ('s');

CREATE TABLE my_new_schema.vendor_h
PARTITION OF my_new_schema.vendor FOR VALUES IN ('h');

CREATE TABLE my_new_schema.vendor_l
PARTITION OF my_new_schema.vendor FOR VALUES IN ('l');

-- INSERT VALUES into mastertable 'vandor' --------------------
insert into my_new_schema.vendor (name, address)
values
('apple', '{"country": "USA", "city": "Cupretino", "phone": "123-444-55-66"}'),
('samsung', '{"country": "South Korea", "city": "Seul", "phone": "12-333-333-333"}'),
('huawei', '{"country": "China", "city": "Shenzhen", "phone": "852-800-931-122"}'),
('honor', '{"country": "China", "city": "Shenzhen", "phone": "111-222-333-444"}'),
('lenovo', '{"country": "China", "city": "Hong-Kong", "phone": "111-222-333-444"}'),
('specialized', '{"country": "USA", "city": "Morgan Hill", "phone": "111-222-333-444"}'),
('sanday bmx', '{"country": "USA", "city": "New_York", "phone": "111-222-333-444"}')
;

-- -------------------------------------------------------------

-- CREATE TABLE "category" -------------------------------------
CREATE TABLE public.category (
	"id" serial primary key,
	"name" varchar not null);

-- MOVE TABLE TO NEW TABLESPACE 'my_tablespace' ----------------
alter table public.category SET TABLESPACE my_tablespace;

-- INSERT VALUES into table 'category' -------------------------
insert into public.category (name)
values ('smartphone'), ('tablet'), ('mounting bike'), ('bmx bike');
;
-- -------------------------------------------------------------


-- CREATE TABLE 'product' --------------------------------------
CREATE TABLE public.product (
	"id" serial primary key,
	"name" varchar not null,
	"vendor_id" integer not null,
	"category_id" integer not null,
	"price" integer not null,
	CONSTRAINT "check_price_value" CHECK(price >= 0),
	CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES public.category (id));
	;

-- INSERT VALUES into table 'product' --------------------------
insert into public.product (name, vendor_id, category_id, price)
values
('iphone-44', 1, 1, 100000),
('honor xx', 4, 1, 50000),
('honor xx+1', 4, 1, 70000),
('huawei tablet', 3, 2, 60000),
('spesialized meta', 6, 3, 190000),
('sunday street', 7, 4, 60000);
;
-- -------------------------------------------------------------

-- MOVE TABLE TO TABLESPACE 'my_tablespace' --------------------
ALTER TABLE public.product SET TABLESPACE my_tablespace;
;
-- -------------------------------------------------------------