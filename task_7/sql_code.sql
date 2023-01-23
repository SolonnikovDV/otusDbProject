-- TASK 7 -----------------------
CREATE TABLE statistic(
player_name VARCHAR(100) NOT NULL,
player_id INT NOT NULL,
year_game SMALLINT NOT NULL CHECK (year_game > 0),
points DECIMAL(12,2) CHECK (points >= 0),
PRIMARY KEY (player_name,year_game)
);

INSERT INTO
statistic(player_name, player_id, year_game, points)
VALUES
('Mike',1,2018,18),
('Jack',2,2018,14),
('Jackie',3,2018,30),
('Jet',4,2018,30),
('Luke',1,2019,16),
('Mike',2,2019,14),
('Jack',3,2019,15),
('Jackie',4,2019,28),
('Jet',5,2019,25),
('Luke',1,2020,19),
('Mike',2,2020,17),
('Jack',3,2020,18),
('Jackie',4,2020,29),
('Jet',5,2020,27);

select * from statistic ;
--------------------------------
-- get sum of points by year with simple query ---
select year_game, sum(points)
from statistic s
group by year_game
order by year_game asc ;

-- get sum of points by year with CTE ------------
with total_poins as (
select year_game, sum(points) as total_points
from statistic
group by year_game
order by year_game asc )
select * from total_poins;

-- get sum of points by year with LAG ------------
select player_name , player_id, year_game ,lag(sum(points ), 1) over(partition by year_game  order by points ) as total_points
from statistic
where year_game >= (select (max(year_game)-1) from statistic)
group by player_name , player_id , year_game
order by year_game , player_id ;