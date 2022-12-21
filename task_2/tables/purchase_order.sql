BEGIN;

-- CREATE TABLE "purchase_order" -------------------------------
CREATE TABLE "public"."purchase_order" (
	"product_id_f_key" Integer NOT NULL,
	"price_id_f_key" Integer NOT NULL,
	"order_count" Double Precision NOT NULL,
	"customer_id_f_key" Integer NOT NULL,
	"order_date" Timestamp With Time Zone NOT NULL,
	"pick_point_id_f_key" Integer NOT NULL,
	"order_id" Integer NOT NULL,
	"delivery_id_f_key" Integer,
	PRIMARY KEY ( "order_id" ),
	CONSTRAINT "unique_order_pick_point_if_f_key" UNIQUE( "pick_point_id_f_key" ),
	CONSTRAINT "unique_order_delivery_id_f_key" UNIQUE( "delivery_id_f_key" ),
	CONSTRAINT "check_order_count" CHECK(order_count >= 0),
	CONSTRAINT "check_order_date" CHECK(order_date >= '2022-12-19 00:00:00'::timestamp) );
	;
-- -------------------------------------------------------------

-- CREATE INDEX "index_order_date" --------------------
-- sort by order date::timestamp
CREATE INDEX "index_order_date" ON "public"."purchase_order" USING btree( "order_date" );
-- -------------------------------------------------------------

-- CREATE FOREIGN KEYS -----------------------------------------
alter table public.purchase_order
    add constraint customer_id_f_key
        foreign key (customer_id_f_key) references public.customer;

alter table public.purchase_order
    add constraint delivery_id_f_key
        foreign key (delivery_id_f_key) references public.delivery;

alter table public.purchase_order
    add constraint pick_point_id_f_key
        foreign key (pick_point_id_f_key) references public.pick_point;

alter table public.purchase_order
    add constraint price_id_f_key
        foreign key (price_id_f_key) references public.price;

alter table public.purchase_order
    add constraint product_id_f_key
        foreign key (product_id_f_key) references public.product;
-- -------------------------------------------------------------

COMMIT;