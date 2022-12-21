BEGIN;

-- CREATE TABLE "price" ----------------------------------------
CREATE TABLE "public"."price" (
	"product_Id_f_key" Integer NOT NULL,
	"base_price" Integer,
	"sale_price" Integer,
	"base_promo_price" Integer,
	"is_final_price" Boolean,
	"price_id" Integer NOT NULL,
	PRIMARY KEY ( "price_id" ),
	CONSTRAINT "unique_price_product_Id" UNIQUE( "product_Id_f_key" ),
	CONSTRAINT "check_price_base_price" CHECK(base_price >= 0),
	CONSTRAINT "check_price_promo_price" CHECK(base_promo_price >= 0),
	CONSTRAINT "check_price_sale_price" CHECK(sale_price >= 0) );
 ;
-- -------------------------------------------------------------

-- CREATE INDEX "index_base_price" -----------------------------
-- searching for all types of prices
CREATE INDEX "index_base_price" ON "public"."price" USING btree( "base_price" Asc NULLS Last, "base_promo_price" Asc NULLS Last, "sale_price" Asc NULLS Last );
-- -------------------------------------------------------------

-- CREATE FOREIGN KEYS -----------------------------------------
alter table public.price
    add constraint price_product_product_id_fk
        foreign key ("product_Id_f_key") references public.product;
-- -------------------------------------------------------------

COMMIT;
