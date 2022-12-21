BEGIN;

-- CREATE TABLE "rating" ---------------------------------------
CREATE TABLE "public"."rating" (
	"star" Integer,
	"count" Integer,
	"percent" Integer,
	"rating_id" Integer NOT NULL,
	PRIMARY KEY ( "rating_id" ),
	CONSTRAINT "ckeck_rating_count" CHECK(count >= 0),
	CONSTRAINT "check_rating_percent" CHECK(percent >= 0),
	CONSTRAINT "check_rating_star" CHECK(star >= 0) );
 ;
-- -------------------------------------------------------------

COMMIT;