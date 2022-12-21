BEGIN;
--
--CHECK: product_balance = product_balance + supply_order.order_count - purchase_order.order_count
--
-- CREATE TABLE "stock" ----------------------------------------
CREATE TABLE "public"."stock" (
	"stock_id" Integer NOT NULL,
	"location_f_key" Integer NOT NULL,
	"product_balance" Double Precision NOT NULL,
	"product_id_f_key" Integer NOT NULL,
	"product_name_f_key" Character Varying NOT NULL,
	"transaction_in_f_key" Integer NOT NULL,
	"transaction_out_f_key" Integer NOT NULL,
	PRIMARY KEY ( "stock_id" ),
	CONSTRAINT "unique_stock_transaction_out_f_key" UNIQUE( "transaction_out_f_key" ),
	CONSTRAINT "check_prod_balance" CHECK(product_balance >= 0) );
 ;
-- -------------------------------------------------------------

-- CREATE INDEX "index_location_f_key" -------------------------
-- location sort
CREATE INDEX "index_location_f_key" ON "public"."stock" USING btree( "location_f_key" );
-- -------------------------------------------------------------

-- CREATE INDEX "index_product_id_f_key" -----------------------
-- search product name + also searching by id
CREATE INDEX "index_product_id_name_f_key"
	ON "public"."stock" USING btree( "product_id_f_key" Asc NULLS Last, "product_name_f_key" Asc NULLS Last;
-- -------------------------------------------------------------

-- CREATE INDEX "index_transaction_in_f_key" -------------------
-- find transaction with all attributes are comming to a storage place
CREATE INDEX "index_transaction_in_f_key" ON "public"."stock" USING btree( "transaction_in_f_key" );
-- -------------------------------------------------------------

-- CREATE FOREIGN KEYS -----------------------------------------
alter table public.stock
    add constraint product_id_f_key
        foreign key (product_id_f_key) references public.product;

alter table public.stock
    add constraint stock_location_location_id_fk
        foreign key (location_f_key) references public.location;

alter table public.stock
    add constraint transaction_in_f_key
        foreign key (transaction_in_f_key) references public.supply_order;

alter table public.stock
    add constraint transaction_out_f_key
        foreign key (transaction_out_f_key) references public.purchase_order;
-- -------------------------------------------------------------

COMMIT;