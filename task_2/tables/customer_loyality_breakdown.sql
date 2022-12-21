BEGIN;

-- CREATE TABLE "customer_loyality_breakdown" ------------------
CREATE TABLE "public"."customer_loyality_breakdown" (
	"loyality_breakdown_id" Integer NOT NULL,
	"loyality_breakdown_value" Integer,
	"loyality_breakdown_program" Character Varying,
	"customer_id_f_key" Integer NOT NULL,
	PRIMARY KEY ( "loyality_breakdown_id" ),
	CONSTRAINT "unique_customer_breakdown_customer_id_f_key" UNIQUE( "loyality_breakdown_id" ),
	CONSTRAINT "unique_customer_loyality_breakdown_customer_id" UNIQUE( "customer_id_f_key" ),
	CONSTRAINT "check_breakdown_value" CHECK(loyality_breakdown_value >= 0) );
 ;
-- -------------------------------------------------------------

-- CREATE INDEX "index_loyality_breakdown" ---------------------
--first and second indexes for searching loyality breakdown for customer
CREATE INDEX "index_loyality_breakdown" 
	ON "public"."customer_loyality_breakdown" USING btree( "loyality_breakdown_program" Asc NULLS Last, 
							      "loyality_breakdown_id" Asc NULLS Last, 
							      "loyality_breakdown_value" Asc NULLS Last );
-- -------------------------------------------------------------

-- CREATE INDEX "index_loyality_breakdown_value" ---------------
CREATE INDEX "index_loyality_breakdown_value" ON "public"."customer_loyality_breakdown" USING btree( "loyality_breakdown_value" );
-- -------------------------------------------------------------

-- CREATE FOREIGN KEYS -----------------------------------------
alter table public.customer
    add constraint customer_type_id_key
        foreign key (customer_type_id_key) references public.agent_type;
 -- -------------------------------------------------------------

COMMIT;