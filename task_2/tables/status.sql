BEGIN;

-- CREATE TABLE "status" ---------------------------------------
CREATE TABLE "public"."status" (
	"available_In_retail_store" Boolean,
	"sold_out" Boolean,
	"is_cannot_be_exchanged" Boolean,
	"status_id" Integer NOT NULL,
	PRIMARY KEY ( "status_id" ) );
 ;
-- -------------------------------------------------------------

COMMIT;