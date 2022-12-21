BEGIN;

-- CREATE TABLE "vendor" ---------------------------------------
CREATE TABLE "public"."vendor" (
	"vendor_id" Integer NOT NULL,
	"vendor_name" Character Varying NOT NULL,
	"location_id_f_key" Integer NOT NULL,
	"vendor_type_id_f_key" Integer NOT NULL,
	PRIMARY KEY ( "vendor_id" ),
	CONSTRAINT "unique_vendor_location_id_f_key" UNIQUE( "location_id_f_key" ),
	CONSTRAINT "unique_vendor_vendor_type_id_f_key" UNIQUE( "vendor_type_id_f_key" ) );
 ;
-- -------------------------------------------------------------

-- CREATE INDEX "index_vendor_name" ----------------------------
-- fast search info about vendor in one query
CREATE INDEX "index_vendor_name"
	ON "public"."vendor" USING btree( "vendor_name" Asc NULLS Last, "location_id_f_key" Asc NULLS Last, "vendor_type_id_f_key" Asc NULLS Last );
-- -------------------------------------------------------------

-- CREATE FOREIGN KEYS -----------------------------------------
alter table public.vendor
    add constraint vendor_agent_type_agent_type_id_fk
        foreign key (vendor_type_id_f_key) references public.agent_type;

alter table public.vendor
    add constraint vendor_location_location_id_fk
        foreign key (location_id_f_key) references public.location;
-- -------------------------------------------------------------

COMMIT;