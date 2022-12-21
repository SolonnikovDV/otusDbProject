BEGIN;

-- CREATE TABLE "agent_type" -----------------------------------
CREATE TABLE "public"."agent_type" (
	"agent_type_id" Integer NOT NULL,
	"agent_type_name" Character Varying NOT NULL,
	PRIMARY KEY ( "agent_type_id" ) );
 ;
-- -------------------------------------------------------------

-- CREATE INDEX "index_agent" ----------------------------------
--Need to fast find types of agents
CREATE INDEX "index_agent" ON "public"."agent_type" USING btree( "agent_type_name" Asc NULLS Last, "agent_type_id" Asc NULLS Last );
-- -------------------------------------------------------------

COMMIT;
