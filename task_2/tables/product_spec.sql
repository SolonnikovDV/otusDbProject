BEGIN;

-- CREATE TABLE "product_spec" ---------------------------------
CREATE TABLE "public"."product_spec" (
	"product_spec_id" Integer NOT NULL,
	"spec_name" Character Varying,
	"spec_name_description" Character Varying,
	"sort_priority" Integer NOT NULL,
	"measure" Character Varying NOT NULL,
	PRIMARY KEY ( "product_spec_id" ),
	CONSTRAINT "check_sort_priority" CHECK(sort_priority > 0) );
 ;
-- -------------------------------------------------------------

-- CREATE INDEX "index_spec_name" ------------------------------
-- find py spec unit name, for example, search spec_name.display == 'LED', or search spec_name.mesuare == 'Gb'
CREATE INDEX "index_spec_name" ON "public"."product_spec" USING btree( "spec_name" );
-- -------------------------------------------------------------

COMMIT;