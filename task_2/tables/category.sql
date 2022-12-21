BEGIN;

-- CREATE TABLE "category" -------------------------------------
CREATE TABLE "public"."category" (
	"name" Character Varying NOT NULL,
	"category_id" Integer NOT NULL,
	"category_describe" Character Varying,
	PRIMARY KEY ( "category_id" ) );
 ;
-- -------------------------------------------------------------

-- CREATE INDEX "index_name" -----------------------------------
--search by category
CREATE INDEX "index_name" ON "public"."category" USING btree( "name" );
-- -------------------------------------------------------------

COMMIT;