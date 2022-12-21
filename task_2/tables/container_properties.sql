-- CREATE TABLE "container_properties" -------------------------
create table public.container_properties
(
    container_id          integer          not null
        primary key,
    container_type        varchar          not null,
    unit_properties_f_key integer          not null
        constraint container_properties_unit_properties_unit_properties_id_fk
            references public.unit_properties,
    container_volume      double precision not null
        constraint check_unit
            check (container_volume > (0)::double precision)
);

-- CREATE INDEX "index_unit_properties_f_key" ------------------
create index index_unit_properties_f_key
    on public.container_properties (unit_properties_f_key);

create index index_container_attribute
    on public.container_properties (container_volume, container_type);

-- CREATE FOREIGN KEYS -----------------------------------------
alter table public.container_properties
    add unit_properties_f_key integer not null;