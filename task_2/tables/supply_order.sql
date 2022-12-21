BEGIN;

-- CREATE TABLE "supply_order" ---------------------------------
CREATE TABLE "public"."supply_order" (
	"supply_order_id" Integer NOT NULL,
	"vendor_id_f_key" Integer NOT NULL,
	"product_name" Character Varying NOT NULL,
	"price_id_f_key" Integer NOT NULL,
	"order_date" Timestamp With Time Zone NOT NULL,
	"unit_properties_f_key" Integer NOT NULL,
	"order_count" Double Precision NOT NULL,
	PRIMARY KEY ( "supply_order_id" ),
	CONSTRAINT "check_order_count" CHECK(order_count >= 0),
	CONSTRAINT "check_order_date" CHECK(order_date >= '2022-12-19 00:00:00'::timestamp) );
 ;
-- -------------------------------------------------------------

-- CREATE INDEX "index_order_date" -----------------------------
-- sort by date of order
CREATE INDEX "index_order_date" ON "public"."supply_order" USING btree( "order_date" );
-- -------------------------------------------------------------

-- CREATE INDEX "index_product_name" ---------------------------
-- allow fast search y name of product into supply order or stock
CREATE INDEX "index_product_name" ON "public"."supply_order" USING btree( "product_name" );
-- -------------------------------------------------------------

-- CREATE INDEX "index_vendor_id_f_key" ------------------------
-- allow fast searching by vendor name
CREATE INDEX "index_vendor_id_f_key" ON "public"."supply_order" USING btree( "vendor_id_f_key" );
-- -------------------------------------------------------------

-- CREATE FOREIGN KEYS -----------------------------------------
alter table public.supply_order
    add constraint supply_order_price_price_id_fk
        foreign key (price_id_f_key) references public.price;

alter table public.supply_order
    add constraint supply_order_unit_properties_unit_properties_id_fk
        foreign key (unit_properties_f_key) references public.unit_properties;

alter table public.supply_order
    add constraint supply_order_vendor_vendor_id_fk
        foreign key (vendor_id_f_key) references public.vendor;
-- -------------------------------------------------------------

COMMIT;