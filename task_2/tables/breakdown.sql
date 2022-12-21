BEGIN;

-- CREATE TABLE "breakdown" ------------------------------------
CREATE TABLE "public"."breakdown" ( 
	"promo_name" Character Varying,
	"bonus_type" Character Varying,
	"total_breakdown" Money,
	"breakdown_id" Integer NOT NULL,
	PRIMARY KEY ( "breakdown_id" ),
	CONSTRAINT "check_breakdown_total_breakdown" CHECK(total_breakdown >=0) );
 ;
-- -------------------------------------------------------------

-- CREATE INDEX "index_promo_name_bonus_type_breakdown" --------
CREATE INDEX "index_promo_name_bonus_type_breakdown"
	ON "public"."breakdown" USING btree( "promo_name" Asc NULLS Last, "bonus_type" Asc NULLS Last, "total_breakdown" Asc NULLS Last );
-- -------------------------------------------------------------

COMMIT;