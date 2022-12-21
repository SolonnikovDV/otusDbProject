BEGIN;

-- CREATE TABLE "product_properties" ---------------------------
CREATE TABLE "public"."product_properties" (
	"product_spec_id_f_key" Integer,
	"product_properties_id" Integer NOT NULL,
	"unit_properties_id_f_key" Integer,
	PRIMARY KEY ( "product_properties_id" ) );
 ;
-- -------------------------------------------------------------

-- CREATE INDEX "index_unit_properties_id_f_key" ---------------
-- search by unit mesuare
CREATE INDEX "index_unit_properties_id_f_key" ON "public"."product_properties" USING btree( "unit_properties_id_f_key" );
-- -------------------------------------------------------------

-- CREATE INDEX "index_product_spec_id_f_key" ------------------
-- search by specification position
CREATE INDEX "index_product_spec_id_f_key" ON "public"."product_properties" USING btree( "product_spec_id_f_key" );
-- -------------------------------------------------------------

-- CREATE FOREIGN KEYS -----------------------------------------
alter table public.product_properties
    add constraint product_spec_id_f_key
        foreign key (product_spec_id_f_key) references public.product_spec;

alter table public.product_properties
    add constraint unit_properties_id_f_key
        foreign key (unit_properties_id_f_key) references public.unit_properties;
-- -------------------------------------------------------------

COMMIT;