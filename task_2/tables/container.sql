BEGIN;
--
--CHECK: container volume = (container_properties.container_volume * container_count)
--
-- CREATE TABLE "container_properties" -------------------------
CREATE TABLE "public"."container_properties" (
	"container_id" Integer NOT NULL,
	"container_type" Character Varying NOT NULL,
	"unit_properties_f_key" Integer NOT NULL,
	"container_volume" Double Precision NOT NULL,
	PRIMARY KEY ( "container_id" ),
	CONSTRAINT "check_unit" CHECK(unit = "m3") );
 ;
-- -------------------------------------------------------------

-- CREATE INDEX "index_unit_properties_f_key" ------------------
--search by volume unit mesuare
CREATE INDEX "index_unit_properties_f_key" ON "public"."container_properties" USING btree( "unit_properties_f_key" );
-- -------------------------------------------------------------

-- CREATE INDEX "index_container_attribute" --------------------
--search by attibutes
CREATE INDEX "index_container_attribute" ON "public"."container_properties" USING btree( "container_volume" Asc NULLS Last, "container_type" Asc NULLS Last );
-- -------------------------------------------------------------

-- CREATE FOREIGN KEYS -----------------------------------------
alter table public.container
    add constraint container_container_properties_container_id_fk
        foreign key (container_properties_id_f_key) references public.container_properties;
-- -------------------------------------------------------------
COMMIT;