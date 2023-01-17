-- select with regexp
select "fullName", "position.name" , "link"
from df_person dp
where "position.name"  like 'Left%';
-- returned values by condition %Left in position.name:
--
-- |fullName                |position.name|link                  |
-- |------------------------|-------------|----------------------+
-- |Tomas Tatar             |Left Wing    |/api/v1/people/8475193|
-- |Erik Haula              |Left Wing    |/api/v1/people/8475287|
-- |Ondrej Palat            |Left Wing    |/api/v1/people/8476292|
-- |Miles Wood              |Left Wing    |/api/v1/people/8477425|
-- |Jesper Bratt            |Left Wing    |/api/v1/people/8479407|
-- |...						|			  |						 |


-- insert + returning inserted rows
insert into df_division ("division.id" , "division.name" ) values (666 , 'Hellfire') returning *;
-- returned values:
--
-- |division.id | division.name |
-- |------------|---------------|
-- |666	        |Hellfire       |


insert into df_teams  values (333, 'new team' , 'no link', 'NT', 'nowhereland', now(), null, null);
select * from df_teams dt ;
-- returned values:
--
-- |id |name                 |link            |teamName      |locationName|firstYearOfPlay               |division.id|conference.id|
-- |---|---------------------|----------------|--------------|------------|------------------------------|-----------|-------------|
-- | 1 |New Jersey Devils    |/api/v1/teams/1 |Devils        |New Jersey  |1982                          |         18|            6|
-- | 2 |New York Islanders   |/api/v1/teams/2 |Islanders     |New York    |1972                          |         18|            6|
-- | 3 |New York Rangers     |/api/v1/teams/3 |Rangers       |New York    |1926                          |         18|            6|
-- | 4 |Philadelphia Flyers  |/api/v1/teams/4 |Flyers        |Philadelphia|1967                          |         18|            6|
-- |   |...... 				 |				  |				 |			  |     	 	                 |		     |		   	   |
-- |55 |Seattle Kraken       |/api/v1/teams/55|Kraken        |Seattle     |2021                          |         15|            5|
-- |333|new team             |no link         |NT            |nowhereland |2023-01-16 11:13:11.495434+03 |       NULL|         NULL|


-- use LEFT JOIN
select "name", "teamName" , "division.name"
from df_teams
left join df_division on df_teams."division.id" = df_division."division.id";
-- we got table with teams name and division name joined on division id (33 rows in teams and 32 rows in joined table)
--
-- | # |name                 |teamName      |division.name|
-- |---|---------------------|--------------|-------------|
-- |1  |New Jersey Devils    |Devils        |Metropolitan |
-- |2  |New York Islanders   |Islanders     |Metropolitan |
-- |3  |New York Rangers     |Rangers       |Metropolitan |
-- |4  |Philadelphia Flyers  |Flyers        |Metropolitan |
-- |   |......				 |				|			  |
-- |32 |Seattle Kraken       |Kraken        |Pacific      |
-- |33 |new team             |NT            |NULL         |


-- use RIGHT JOIN
select "name", "teamName" , "division.name"
from df_teams
right join df_division on df_teams."division.id" = df_division."division.id";
-- we got table with teams name and division name joined on division id (32 rows in teams and 33 rows in joined table)
--
-- | # |name                 |teamName      |division.name|
-- |---|---------------------|--------------|-------------|
-- |1  |New Jersey Devils    |Devils        |Metropolitan |
-- |2  |New York Islanders   |Islanders     |Metropolitan |
-- |3  |New York Rangers     |Rangers       |Metropolitan |
-- |4  |Philadelphia Flyers  |Flyers        |Metropolitan |
-- |   |......				 |				|			  |
-- |32 |Seattle Kraken       |Kraken        |Pacific      |
-- |33 |NULL                 |NULL          |Hellfire     |


-- use INNER JOIN
select "name", "teamName" , "division.name"
from df_teams
inner join df_division on df_teams."division.id" = df_division."division.id";
-- inner join returns only equals rows from both tables (32 rows)
--
-- | # |name                 |teamName      |division.name|
-- |---|---------------------|--------------|-------------|
-- |1  |New Jersey Devils    |Devils        |Metropolitan |
-- |2  |New York Islanders   |Islanders     |Metropolitan |
-- |3  |New York Rangers     |Rangers       |Metropolitan |
-- |4  |Philadelphia Flyers  |Flyers        |Metropolitan |
-- |   |......				 |				|			  |
-- |32 |Seattle Kraken       |Kraken        |Pacific      |


-- UPDATE FROM table
drop table new_table;
truncate new_table ;

-- CREATE empty table with id
create table new_table (id bigint, name varchar, division_id int, division_name text);

insert into new_table  values
(1, null, null, null),
(2, null, null, null),
(3, null, null, null),
(333, null, null, null);
select * from new_table nt ;
--
-- |id |name|division_id|division_name|
-- |---|----|-----------|-------------|
-- |  1|    |           |             |
-- |  2|    |           |             |
-- |  3|    |           |             |
-- |333|    |           |             |


-- fill with UPDATE column division_id
WITH subquery AS (
select "id", "name", "division.id"
FROM df_teams
)
UPDATE new_table
set "name" = subquery."name",
"division_id" = subquery."division.id"
FROM subquery
WHERE new_table."id" = subquery."id"
returning *;
-- returning value:
--
-- |id |name              |division_id|division_name|
-- |---|------------------|-----------|-------------|
-- |  1|New Jersey Devils |         18|             |
-- |  2|New York Islanders|         18|             |
-- |  3|New York Rangers  |         18|             |
-- |333|new team          |           |             |


-- fill with secomd UPDATE column division_name
update new_table
set "division_name" = df_division."division.name"
from df_division
where new_table.division_id = df_division."division.id"
returning *;
-- returning value:
--
-- |id |name              |division_id|division_name|
-- |---|------------------|-----------|-------------|
-- |  1|New Jersey Devils |         18|Metropolitan |
-- |  2|New York Islanders|         18|Metropolitan |
-- |  3|New York Rangers  |         18|Metropolitan |
-- |333|new team          |           |             |


-- DELETE with JOIN (using 'new_table')
delete from new_table where "name" in (select new_table."name" from new_table left join df_teams on new_table."name" = df_teams."name" where df_teams."name" like '%Jersey%');
select * from new_table ;
-- DELETE by condition: string 'Jersey' are in column 'name' value
-- returning value:
--
-- |id |name              |division_id|division_name|
-- |---|------------------|-----------|-------------|
-- |333|new team          |           |             |
-- |  2|New York Islanders|         18|Metropolitan |
-- |  3|New York Rangers  |         18|Metropolitan |


-- DELETE with USING (using 'new_table')
delete from new_table using df_teams where df_teams."name" = new_table."name" and df_teams."name" like '%Jersey%';
select * from new_table;
-- DELETE by condition: string 'Jersey' are in column 'name' value
-- returning value:
--
-- |id |name              |division_id|division_name|
-- |---|------------------|-----------|-------------|
-- |333|new team          |           |             |
-- |  2|New York Islanders|         18|Metropolitan |
-- |  3|New York Rangers  |         18|Metropolitan |


-- DELETE USING + JOIN
delete from new_table using new_table as nt inner join df_teams on nt."name" = df_teams."name" where df_teams."name" like '%team%';
select * from new_table;
-- query do not work like expected: deleting all rows even whey do not include the condition
--
-- |id|name|division_id|division_name|
-- |--|----|-----------|-------------|
-- |  |    |		   |			 |