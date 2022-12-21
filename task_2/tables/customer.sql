BEGIN;

-- CREATE TABLE "customer" -------------------------------------
CREATE TABLE "public"."customer" (
	"customer_id" Integer NOT NULL,
	"customer_type_id_key" Integer NOT NULL,
	"personal_breakdown" Character Varying,
	PRIMARY KEY ( "customer_id" ),
	CONSTRAINT "unique_customer_customer_type_id_key" UNIQUE( "customer_type_id_key" ) );
 ;
-- -------------------------------------------------------------

-- CREATE INDEX "index_personal_breakdown" ---------------------
--look for breakdown value for customer
CREATE INDEX "index_personal_breakdown" ON "public"."customer" USING btree( "personal_breakdown" Asc NULLS Last );
-- -------------------------------------------------------------

-- CREATE FOREIGN KEYS -----------------------------------------
alter table public.customer
    add constraint customer_type_id_key
        foreign key (customer_type_id_key) references public.agent_type;
-- -------------------------------------------------------------

COMMIT;