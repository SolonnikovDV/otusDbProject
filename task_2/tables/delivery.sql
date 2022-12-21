BEGIN;

-- CREATE TABLE "delivery" -------------------------------------
CREATE TABLE "public"."delivery" (
	"delivery_id" Integer NOT NULL,
	"delivery_type" Character Varying,
	"delivery_price" Integer,
	"location_id_f_key" Integer NOT NULL,
	PRIMARY KEY ( "delivery_id" ),
	CONSTRAINT "unique_delivery_location_id_f_key" UNIQUE( "location_id_f_key" ),
	CONSTRAINT "check_delivery_price" CHECK(delivery_price >= 0) );
 ;
-- -------------------------------------------------------------

-- CREATE INDEX "index_delivery_type" --------------------------
--searching delivery type: include/disable, to_the_door, to_a_pick_point etc.
CREATE INDEX "index_delivery_type" ON "public"."delivery" USING btree( "delivery_type" );
-- -------------------------------------------------------------

-- CREATE FOREIGN KEYS -----------------------------------------
alter table public.delivery
    add constraint delivery_location_location_id_fk
        foreign key (location_id_f_key) references public.location;
-- -------------------------------------------------------------

COMMIT;