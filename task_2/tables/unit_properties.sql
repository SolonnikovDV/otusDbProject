BEGIN;

-- CREATE TABLE "unit_properties" ------------------------------
CREATE TABLE "public"."unit_properties" (
	"unit_properties_id" Integer NOT NULL,
	"unit_short_name" Character Varying NOT NULL,
	"unit_full_name" Character Varying NOT NULL,
	PRIMARY KEY ( "unit_properties_id" ),
	CONSTRAINT "unique_unit_properties_unit_properties_id" UNIQUE( "unit_properties_id" ) );
 ;
-- -------------------------------------------------------------

COMMIT;