first, De cleaning-notebooks.
second, create_tables.sql in pgAdmin.
third, De CSV-bestanden importeren.
fourth, main.py draaien.
The order database

| Step | Table | Why in this position |
|---|---|---|
| 1 | director | references nothing |
| 2 | actor | references nothing |
| 3 | genre | references nothing |
| 4 | sales | references nothing |
| 5 | movie | references director and actor |
| 6 | award_movie | references movie |
| 7 | award_director | references director and movie |
| 8 | award_actor | references actor and movie |
| 9 | consumer_review | references movie |
| 10 | expert_review | references movie |
| 11 | actor_connect | references movie and actor |
| 12 | movie_genre | references movie and genre |
| 13 | movie_sales | references movie and sales |
