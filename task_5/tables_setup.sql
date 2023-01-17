-- delete pandas dataframe autoincrement column 'index'
alter table df_person drop column "index";
alter table df_teams  drop column "index";
alter table df_division  drop column "index";
alter table df_conference  drop column "index";

-- set primary keys
ALTER TABLE df_person ADD PRIMARY KEY ("id");
alter table df_division add primary key ("division.id");
alter table df_teams add primary key ("id");
alter table df_conference add primary key ("conference.id");

-- set foreign keys
alter table df_person add constraint fk_person_teams
FOREIGN KEY ("team.id") REFERENCES df_teams (id);
;
alter table df_teams  add constraint fk_teams_conference
FOREIGN KEY ("conference.id") REFERENCES df_conference ("conference.id");
;
alter table df_teams  add constraint fk_teams_division
FOREIGN KEY ("division.id") REFERENCES df_division ("division.id");

-- set indexes
CREATE INDEX "index_persons_id_name" ON df_person USING btree( "id", "fullName" );
CREATE INDEX "index_persons_position" ON df_person USING btree( "position.name", "position.type");