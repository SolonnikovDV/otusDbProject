BEGIN;

-- CREATE TABLE "company_attribute" ----------------------------
CREATE TABLE "public"."company_attribute" (
	"agent_type_f_key" Integer NOT NULL,
	"company_name_short" Character Varying NOT NULL,
	"company_name_full" Character Varying NOT NULL,
	"inn" Character Varying NOT NULL,
	"location_id_f_key" Integer NOT NULL );
 ;
-- -------------------------------------------------------------

-- CREATE INDEX "index_location_id_f_key2" ---------------------
--search by company name
create index company_attribute_company_name_short_index
    on company_attribute (company_name_short);

create index company_attribute_inn_index
    on company_attribute (inn);
-- -------------------------------------------------------------

-- CREATE FOREIGN KEYS -----------------------------------------
alter table public.company_attribute
    add constraint company_attribute_agent_type_agent_type_id_fk
        foreign key (agent_type_f_key) references public.agent_type;

alter table public.company_attribute
    add constraint company_attribute_location_location_id_fk
        foreign key (location_id_f_key) references public.location;
-- -------------------------------------------------------------

COMMIT;