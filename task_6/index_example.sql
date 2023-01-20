-- docker exec -it sql-outs-project /bin/bash
-- psql -U pg-user -W dml-task
-- password

-- CREATE DATABASE 'index-task' ----
-- dml-task=# create database "index-task" with owner="pg-user" encoding='UTF-8' tablespace=pg_default;
-- CREATE DATABASE
------------------------------------

-- CREATE TABLES from CSV files ----

-- index-task=# create table books_data (title varchar, description varchar, authors varchar, image varchar, prewiewLlink varchar, publisher varchar, publisherDate varchar, infoLink varchar, categories varchar, ratingsCount float);CREATE TABLE
-- index-task=# \copy books_data from '/home/books_data.csv' csv header;
-- COPY 212404

-- index-task=# create table books_rating (id varchar, title varchar, price float, user_id varchar, prifileName varchar, "review/helpfulness"  varchar, "review/score" float, "review/time" bigint, "review/summary" varchar, "review/text" varchar);
-- CREATE TABLE
-- index-task=# \copy books_rating from '/home/Books_rating.csv' csv header;
-- COPY 3000000
------------------------------------

-- lookup tables
select * from books_rating limit(5);
--|id        |title                           |price|user_id       |prifilename                       |review/helpfulness|review/score|review/time|review/summary                                          |review/text                                                                                                                                                                                                                                                    |
--|----------|--------------------------------|-----|--------------|----------------------------------|------------------|------------|-----------|--------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
--|B00089ARQK|A wonder-book for girls and boys|     |AXRZ96K8TSEKC |Colleen R. Yeany "dream135"       |9/11              |         5.0| 1011225600|A little-known gem of thrills for all ages              |One day last week, I could not, even after hours of deliberation (the snow had made engagements scarce), decide what book to read next. I finally came upon this little volume on the end of my parent's bookshelf and decided to give it try. How could I have|
--|B00089ARQK|A wonder-book for girls and boys|     |A1MG6ZQ5IDB14T|K. K. Adams                       |3/3               |         5.0| 1243987200|Must-Have for Children's Library                        |I ordered this book as part of a third grade curriculum for my son. These Everyman titles are really wonderful-- beautiful binding, heavy pages, amazing illustrations. I was not disappointed with this book. It is the kind of book we will read again and ag|
--|B00089ARQK|A wonder-book for girls and boys|     |A1CHM200OEN65X|Eric Wilson "novelist"            |2/2               |         5.0| 1302393600|Magical Energy                                          |If you've read Hawthorne's longer works, you might be surprised by the storytelling fun and energy he puts into this shorter book aimed at boys and girls of all ages, 8 to 80, who love a good yarn. Imagine yourself on a whispery, wintery day, sledding on |
--|B00089ARQK|A wonder-book for girls and boys|     |A1KXRSUWH6NFZ |A Kid "a kid"                     |1/4               |         1.0| 1252281600|Unreadable!                                             |As good as this book may be, the print quality is so bad that I cannot read it. Zero stars would have been more appropriate.                                                                                                                                   |
--|B000H264AG|The Glass Bees                  |     |A3MHGGHQOCH11U|Jonathan Armstrong "enantidromian"|37/40             |         5.0| 1081814400|Top Ten ? Definitely in the Top 100 for the 20th Century|How do you even begin to do justice to a novel like this? I would imagine that this could very well be a polarizing novel. (Keep in mind my personal philosophy is largely derived from Rene Guenon, et al.) However, I don't think anyone could doubt the qual|

select * from books_data limit(5);
--|title                                                                               |description                                                                                                                                                                                                                                                    |authors                                                |image                                                                                                          |prewiewllink                                                                                                                                                 |publisher                    |publisherdate|infolink                                                                                                                                                |categories                     |ratingscount|
--|------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------|---------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------|-------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------|------------|
--|The press and the cold war                                                          |This is a study of the British state's generation, suppression and manipulation of news to further foreign policy goals during the early Cold War. Bribing editors, blackballing &quote;unreliable&quote; journalists, creating instant media experts through p|['John Jenks']                                         |http://books.google.com/books/content?id=_c-qBgAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api|http://books.google.com/books?id=_c-qBgAAQBAJ&printsec=frontcover&dq=The+press+and+the+cold+war&hl=&cd=1&source=gbs_api                                      |Edinburgh University Press   |2006-04-19   |https://play.google.com/store/books/details?id=_c-qBgAAQBAJ&source=gbs_api                                                                              |['Political Science']          |            |
--|Insight Pocket Guide Quebec (Insight Guides)                                        |Insight Guides Explore Québec Travel made easy. Ask local experts. Focused travel guide featuring the very best routes and itineraries. Discover the best of Québec with this unique travel guide, packed full of insider information and stunning images. From|['Insight Guides']                                     |http://books.google.com/books/content?id=-zhCEAAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api|http://books.google.com/books?id=-zhCEAAAQBAJ&printsec=frontcover&dq=Insight+Pocket+Guide+Quebec+(Insight+Guides)&hl=&cd=1&source=gbs_api                    |Apa Publications (UK) Limited|2021-11-02   |https://play.google.com/store/books/details?id=-zhCEAAAQBAJ&source=gbs_api                                                                              |['Travel']                     |            |
--|Effects of long-run demographic changes in a multi-country model (IMF working paper)|The macroeconomic effects of population aging are explored using data for the G-7 countries and Australia. The link between changes in birth and mortality rates on the one hand, and dependency ratios on the other, is first discussed, then empirical eviden|['Paul R. Masson']                                     |                                                                                                               |http://books.google.com/books?id=h4PpzgEACAAJ&dq=Effects+of+long-run+demographic+changes+in+a+multi-country+model+(IMF+working+paper)&hl=&cd=1&source=gbs_api|                             |2006         |http://books.google.com/books?id=h4PpzgEACAAJ&dq=Effects+of+long-run+demographic+changes+in+a+multi-country+model+(IMF+working+paper)&hl=&source=gbs_api|                               |            |
--|English literature: modern (The home university library of modern knowledge)        |Trieste Publishing has a massive catalogue of classic book titles. Our aim is to provide readers with the highest quality reproductions of fiction and non-fiction literature that has stood the test of time. The many thousands of books in our collection ha|['G. H. Mair']                                         |http://books.google.com/books/content?id=gJQTtAEACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api          |http://books.google.com/books?id=gJQTtAEACAAJ&dq=English+literature:+modern+(The+home+university+library+of+modern+knowledge)&hl=&cd=1&source=gbs_api        |Trieste Publishing           |2017-09-15   |http://books.google.com/books?id=gJQTtAEACAAJ&dq=English+literature:+modern+(The+home+university+library+of+modern+knowledge)&hl=&source=gbs_api        |                               |            |
--|Writing, Reading, and Research                                                      |Broadening the traditional notion of undergraduate research, WRITING, READING, AND RESEARCH thoroughly covers the essential skills for developing a research paper: analytical reading, synthesizing, paraphrasing, and summarizing. Presenting the process of |['Richard Veit', 'Christopher Gould', 'Kathleen Gould']|http://books.google.com/books/content?id=dSEKzgEACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api          |http://books.google.com/books?id=dSEKzgEACAAJ&dq=Writing,+Reading,+and+Research&hl=&cd=1&source=gbs_api                                                      |Cengage Learning             |2013-08-23   |http://books.google.com/books?id=dSEKzgEACAAJ&dq=Writing,+Reading,+and+Research&hl=&source=gbs_api                                                      |['Language Arts & Disciplines']|            |


-- CREATE INDEXES ------------------
-- multi-field index
CREATE INDEX "books_rating_title" ON books_rating USING btree( id, title);
CREATE INDEX "books_rating_prifilename" ON books_rating USING btree( User_id, prifilename);
-- simple index
CREATE INDEX "books_rating_review/score" ON books_rating USING btree( "review/score");
CREATE INDEX "books_data_title" ON books_data USING btree(title);
CREATE INDEX "books_data_author" ON books_data USING btree(authors);
------------------------------------

-- CREATE full text search INDEX ---
-- change type of column "review/summary", "review/text" to TEXT
alter table books_rating ALTER COLUMN "review/summary" TYPE TEXT;
alter table books_rating ALTER COLUMN "review/text" TYPE TEXT;

-- create extension trgm, btree_gin
CREATE EXTENSION pg_trgm;
CREATE EXTENSION btree_gin;

-- create index
create index text_trgm_idx on books_rating using gin("review/summary" gin_trgm_ops);
------------------------------------

-- EXPLAIN INDEX -------------------
-- Call index for a path of table with expression
explain select id, title, user_id, prifilename, "review/score" from books_rating where title like '%lexandra%';
--|QUERY PLAN                                                                       |
--|---------------------------------------------------------------------------------|
--|Gather  (cost=1000.00..296462.66 rows=262 width=87)                              |
--|  Workers Planned: 2                                                             |
--|  ->  Parallel Seq Scan on books_rating  (cost=0.00..295436.46 rows=109 width=87)|
--|        Filter: ((title)::text ~~ '%lexandra%'::text)                            |
--|JIT:                                                                             |
--|  Functions: 4                                                                   |
--|  Options: Inlining false, Optimization false, Expressions true, Deforming true  |

explain select * from books_rating where "review/score" = 1;
--|QUERY PLAN                                                                                      |
--|------------------------------------------------------------------------------------------------|
--|Bitmap Heap Scan on books_rating  (cost=3816.93..303561.39 rows=203419 width=719)               |
--|  Recheck Cond: ("review/score" = '1'::double precision)                                        |
--|  ->  Bitmap Index Scan on "books_rating_review/score"  (cost=0.00..3766.07 rows=203419 width=0)|
--|        Index Cond: ("review/score" = '1'::double precision)                                    |
--|JIT:                                                                                            |
--|  Functions: 2                                                                                  |
--|  Options: Inlining false, Optimization false, Expressions true, Deforming true                 |

explain select * from books_data where title ilike '%writing%';
--|QUERY PLAN                                                                   |
--|-----------------------------------------------------------------------------|
--|Gather  (cost=1000.00..23410.37 rows=21 width=998)                           |
--|  Workers Planned: 2                                                         |
--|  ->  Parallel Seq Scan on books_data  (cost=0.00..22408.27 rows=9 width=998)|
--|        Filter: ((title)::text ~~* '%writing%'::text)                        |

explain select * from books_data where authors ilike '%ford%';
-- |QUERY PLAN                                                                     |
-- |-------------------------------------------------------------------------------|
-- |Gather  (cost=1000.00..23585.07 rows=1768 width=998)                           |
-- |  Workers Planned: 2                                                           |
-- |  ->  Parallel Seq Scan on books_data  (cost=0.00..22408.27 rows=737 width=998)|
-- |        Filter: ((authors)::text ~~* '%ford%'::text)                           |

explain select "review/summary", similarity("review/summary", 'best')from books_rating where title % 'best'
order by similarity desc ;
--|QUERY PLAN                                                                               |
--|-----------------------------------------------------------------------------------------|
--|Gather Merge  (cost=297364.71..300356.02 rows=25638 width=36)                            |
--|  Workers Planned: 2                                                                     |
--|  ->  Sort  (cost=296364.69..296396.74 rows=12819 width=36)                              |
--|        Sort Key: (similarity("review/summary", 'best'::text)) DESC                      |
--|        ->  Parallel Seq Scan on books_rating  (cost=0.00..295490.05 rows=12819 width=36)|
--|              Filter: ((title)::text % 'best'::text)                                     |
--|JIT:                                                                                     |
--|  Functions: 4                                                                           |
--|  Options: Inlining false, Optimization false, Expressions true, Deforming true          |
------------------------------------

-- DDL -----------------------------
-- find all rows of books_rating, books_data
select * from books_rating limit(5);
select * from books_data limit(5);

-- find rows by expression
select * from books_rating where title like '%lexandra%';
select * from books_rating where "review/score" >= 5;
select * from books_data where authors like '%ford%';

-- full text find with pg_trgm extension
select set_limit(0.1); -- set level of similarity on a postgres session (will turn back to a default on session exit)
select "review/summary", similarity("review/summary", 'best')from books_rating where title % 'best'
order by similarity desc ;

explain select "review/summary", similarity("review/summary", 'best')from books_rating where title % 'best'
order by similarity desc ;

-- |QUERY PLAN                                                                               |
-- |-----------------------------------------------------------------------------------------|
-- |Gather Merge  (cost=297364.71..300356.02 rows=25638 width=36)                            |
-- |  Workers Planned: 2                                                                     |
-- |  ->  Sort  (cost=296364.69..296396.74 rows=12819 width=36)                              |
-- |        Sort Key: (similarity("review/summary", 'best'::text)) DESC                      |
-- |        ->  Parallel Seq Scan on books_rating  (cost=0.00..295490.05 rows=12819 width=36)|
-- |              Filter: ((title)::text % 'best'::text)                                     |
-- |JIT:                                                                                     |
-- |  Functions: 4                                                                           |
-- |  Options: Inlining false, Optimization false, Expressions true, Deforming true          |