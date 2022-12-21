BEGIN;

-- CREATE TABLE "brand" ----------------------------------------
CREATE TABLE "public"."brand" (
	"brand_id" Integer,
	"brand_name" Character Varying,
	PRIMARY KEY ( "brand_id" ),
	CONSTRAINT "unique_brand_brand_id" UNIQUE( "brand_id" ) );
 ;
-- -------------------------------------------------------------

-- CREATE INDEX "index_brand_name" -----------------------------
----allow fast search by brand
CREATE INDEX "index_brand_name" ON "public"."brand" USING btree( "brand_name" Asc NULLS Last, "brand_id" Asc NULLS Last );
-- -------------------------------------------------------------

COMMIT;
