BEGIN;

-- CREATE TABLE "location" -------------------------------------
CREATE TABLE "public"."location" (
	"location_id" Integer NOT NULL,
	"country" Character Varying NOT NULL,
	"state" Character Varying,
	"city" Character Varying NOT NULL,
	"street" Character Varying NOT NULL,
	"place" Character Varying NOT NULL,
	"office" Character Varying,
	"zip_code" Integer,
	PRIMARY KEY ( "location_id" ),
	CONSTRAINT "unique_storage_location_stok_f_key" UNIQUE( "location_id" ),
	CONSTRAINT "unique_stock_location_zip_code" UNIQUE( "zip_code" ) );
 ;
-- -------------------------------------------------------------

-- CREATE INDEX "index_stock_address" --------------------------
--conposite index, all fields use mostly together in a search queries
CREATE INDEX "index_stock_address" ON "public"."location" USING btree( "country" Asc NULLS Last, "state" Asc NULLS Last, "city" Asc NULLS Last, "street" Asc NULLS Last, "place" Asc NULLS Last, "office" Asc NULLS Last );
-- -------------------------------------------------------------

COMMIT;