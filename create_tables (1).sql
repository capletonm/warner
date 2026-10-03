-- WARNER BROS. MOVIES DATABASE — CREATE TABLES SCRIPT

-- This script makes the 13 empty tables from our ERD. The data is added
-- later by importing our cleaned CSV files in pgAdmin.

-- PRIMARY KEY gives every row its own unique number, it can never be empty.
-- FOREIGN KEY points to the primary key of another table, the database checks that this number really exists there.
-- VARCHAR(n) is text with a maximum of n characters, INT is a whole number, FLOAT is a number with decimals, DATE is a date without a time.

-- INT vs SERIAL: all IDs are made in Python during the cleaning, because
-- we need them there to fill the foreign keys.
-- SERIAL would let the database make its own numbers, and then our foreign keys could point to the wrong rows. So every ID is INT PRIMARY KEY.



-- STEP 1: TABLES WITH NO FOREIGN KEYS
-- A foreign key can only point to a table that already exists.
-- Other tables point to director, actor and genre, so we make these first.
-- We use a number as ID and not the name, because two directors can have the same name.
-- NOT NULL on the names, because a director or actor without a name has no use.
-- UNIQUE on genre, so the same genre is never stored twice.
-- Author: Capleton

CREATE TABLE director (
    director_id     INT PRIMARY KEY,
    director_name   VARCHAR(255) NOT NULL
);

CREATE TABLE actor (
    actor_id        INT PRIMARY KEY,
    actor_name      VARCHAR(255) NOT NULL
);

CREATE TABLE genre (
    genre_id        INT PRIMARY KEY,
    genre           VARCHAR(100) UNIQUE NOT NULL
);



-- STEP 2: MOVIE — the main table that most other tables link to
-- One director makes many movies, but every movie has one director (1:N in the ERD).
-- The foreign key goes on the "many" side, so director_id goes in movie.
-- We need it for sub-question 2. actor_id is added as in the ERD, the full list of actors per movie is in actor_connect.
-- url gets 500 characters because URLs can be long, rating gets 20 because codes like "PG-13" are short.
-- rel_date is DATE, sub-question 5 uses the month for the release season.
-- Author: Capleton

CREATE TABLE movie (
    movie_id        INT PRIMARY KEY,
    director_id     INT,
    actor_id        INT,
    url             VARCHAR(500),
    title           VARCHAR(255) NOT NULL,
    studio          VARCHAR(255),
    rating          VARCHAR(20),
    runtime_meta    INT,
    runtime_sales   INT,
    metascore       FLOAT,
    userscore       FLOAT,
    rel_date        DATE,
    FOREIGN KEY (director_id) REFERENCES director (director_id),
    FOREIGN KEY (actor_id) REFERENCES actor (actor_id)
);



-- STEP 3: AWARD TABLES
-- Each row is one Oscar that was won.
-- We use three tables instead of one. In one shared table, director_id would always be empty for an acting Oscar,
-- and actor_id would always be empty for a directing Oscar. Empty columns like that go against normalization.
-- Every award table has its own primary key name, the same as in the ERD.
-- The winner's name is stored once, in name_nominee.
-- A separate director_name or actor_name would be duplicate data.
-- We do not store "winner" (every row is a winner) or year_film (it is always year_ceremony minus 1).
-- Author: Capleton

CREATE TABLE award_movie (
    movie_award_id  INT PRIMARY KEY,
    movie_id        INT NOT NULL,
    year_ceremony   INT,
    ceremony        VARCHAR(255),
    category        VARCHAR(255),
    name_nominee    VARCHAR(255),
    film_title      VARCHAR(255),
    FOREIGN KEY (movie_id) REFERENCES movie (movie_id)
);

CREATE TABLE award_director (
    director_award_id INT PRIMARY KEY,
    director_id     INT NOT NULL,
    movie_id        INT NOT NULL,
    year_ceremony   INT,
    ceremony        VARCHAR(255),
    category        VARCHAR(255),
    name_nominee    VARCHAR(255),
    film_title      VARCHAR(255),
    FOREIGN KEY (director_id) REFERENCES director (director_id),
    FOREIGN KEY (movie_id) REFERENCES movie (movie_id)
);

CREATE TABLE award_actor (
    actor_award_id  INT PRIMARY KEY,
    actor_id        INT NOT NULL,
    movie_id        INT NOT NULL,
    year_ceremony   INT,
    ceremony        VARCHAR(255),
    category        VARCHAR(255),
    name_nominee    VARCHAR(255),
    film_title      VARCHAR(255),
    FOREIGN KEY (actor_id) REFERENCES actor (actor_id),
    FOREIGN KEY (movie_id) REFERENCES movie (movie_id)
);



-- STEP 4: JUNCTION TABLE MOVIE <-> ACTOR
-- One movie has many actors, and one actor plays in many movies (many to many).
-- A list of actors in one cell breaks the first normal form.
-- Every row in actor_connect is one pair: this actor plays in this movie.
-- This splits it into two 1:N links, like the ERD shows.
-- The primary key is movie_id and actor_id together, so the same pair can never be stored twice.
-- Author: Capleton

CREATE TABLE actor_connect (
    movie_id    INT NOT NULL,
    actor_id    INT NOT NULL,
    PRIMARY KEY (movie_id, actor_id),
    FOREIGN KEY (movie_id) REFERENCES movie (movie_id),
    FOREIGN KEY (actor_id) REFERENCES actor (actor_id)
);



-- STEP 5: REVIEW TABLES
-- Consumer reviews have thumbs_up and total_thumbs, expert reviews do not.
-- In one shared table these columns would be empty for every expert review, so we use two tables.
-- One movie has many reviews (1:N), so movie_id is the foreign key here.
-- Author: Capleton

CREATE TABLE consumer_review (
    review_id       INT PRIMARY KEY,
    movie_id        INT NOT NULL,
    url             VARCHAR(500),
    review_score    FLOAT,
    pos_emotion_pct FLOAT,
    neg_emotion_pct FLOAT,
    thumbs_up       INT,
    total_thumbs    INT,
    FOREIGN KEY (movie_id) REFERENCES movie (movie_id)
);

CREATE TABLE expert_review (
    expert_review_id INT PRIMARY KEY,
    movie_id         INT NOT NULL,
    url              VARCHAR(500),
    review_score     FLOAT,
    pos_emotion_pct  FLOAT,
    neg_emotion_pct  FLOAT,
    FOREIGN KEY (movie_id) REFERENCES movie (movie_id)
);



-- STEP 6: SALES + JUNCTION TABLE MOVIE <-> SALES
-- sales holds the money numbers of a movie, FLOAT because the amounts can be very large.
-- Normally a movie_id foreign key in sales would be enough, because one sales record belongs to one movie.
-- We keep the junction table because it is in our ERD and keeps sales separate from movie.
-- Author: Capleton

CREATE TABLE sales (
    sales_id                  INT PRIMARY KEY,
    production_budget         FLOAT,
    international_box_office  FLOAT,
    domestic_box_office       FLOAT,
    opening_weekend           FLOAT,
    theatre_count             INT,
    avg_run_per_theatre       FLOAT,
    creative_type             VARCHAR(100)
);

CREATE TABLE movie_sales (
    movie_id    INT NOT NULL,
    sales_id    INT NOT NULL,
    PRIMARY KEY (movie_id, sales_id),
    FOREIGN KEY (movie_id) REFERENCES movie (movie_id),
    FOREIGN KEY (sales_id) REFERENCES sales (sales_id)
);



-- STEP 7: JUNCTION TABLE MOVIE <-> GENRE
-- One movie can have many genres, and one genre covers many movies (many to many), the same as movie and actor in STEP 4.
-- In the original data the genres are in one cell, like "Action,Comedy".
-- movie_genre stores one pair per row: this movie has this genre.
-- Author: Capleton

CREATE TABLE movie_genre (
    movie_id    INT NOT NULL,
    genre_id    INT NOT NULL,
    PRIMARY KEY (movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES movie (movie_id),
    FOREIGN KEY (genre_id) REFERENCES genre (genre_id)
);



-- END OF SCRIPT
-- We now have 13 tables:
-- director, actor, genre, movie, award_movie, award_director, award_actor,
-- actor_connect, consumer_review, expert_review, sales, movie_sales,
-- movie_genre
