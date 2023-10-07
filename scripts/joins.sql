-- 1. Give the name, release year, and worldwide gross of the lowest grossing movie.
-- ** Separate queries from both tables **
SELECT
	film_title,
	release_year
FROM specs;
-------------------------------------
SELECT worldwide_gross
FROM revenue;
-- ** Join revenue (r) with specs (s) **
SELECT 
	film_title,
	release_year,
	worldwide_gross
FROM specs
LEFT JOIN revenue
	USING(movie_id);
-- ** Find lowest gross **
SELECT
	film_title,
	release_year,
	worldwide_gross
FROM specs
LEFT JOIN revenue
	USING(movie_id)
ORDER BY worldwide_gross
LIMIT 1;
-- Answer: Semi-Tough from 1977, with a gross of $37,187,139.

-- 2. What year has the highest average imdb rating?
-- ** Join rating (r) with specs (s) **
SELECT
	film_title,
	release_year,
	imdb_rating
FROM specs
LEFT JOIN rating
	USING(movie_id);
-- ** Find average rating by year **
SELECT
	release_year,
	AVG(imdb_rating)
FROM specs
LEFT JOIN rating
	USING(movie_id)
GROUP BY release_year;
-- ** Find highest average rating **
SELECT
	release_year,
	AVG(imdb_rating)
FROM specs
LEFT JOIN rating
	USING(movie_id)
GROUP BY release_year
ORDER BY AVG(imdb_rating) DESC
LIMIT 1;
-- Answer: 1991: Average IMDB rating = 7.45

-- 3. What is the highest grossing G-rated movie? Which company distributed it?
-- ** Join specs and revenue and find highest grossing G-rated movie **
SELECT
	s.film_title,
	s.mpaa_rating,
	r.worldwide_gross
FROM specs AS s
JOIN revenue AS r
	ON s.movie_id = r.movie_id
WHERE s.mpaa_rating = 'G'
ORDER BY s.mpaa_rating DESC
LIMIT 1;
-- ** Add distributors table **
SELECT
	s.film_title,
	s.mpaa_rating,
	r.worldwide_gross,
	d.company_name
FROM specs AS s
LEFT JOIN revenue AS r
	ON s.movie_id = r.movie_id
LEFT JOIN distributors AS d
	ON s.domestic_distributor_id = d.distributor_id
WHERE s.mpaa_rating = 'G'
ORDER BY s.mpaa_rating DESC
LIMIT 1;
-- Answer: Toy Story 4 - distributed by Walt Disney

-- 4. Write a query that returns, for each distributor in the distributors table, the distributor name and the number of movies associated with that distributor in the movies table. Your result set should include all of the distributors, whether or not they have any movies in the movies table.
-- ** Count movies by distributor ID in specs table **
SELECT
	domestic_distributor_id,
	COUNT(movie_id)
FROM specs
GROUP BY domestic_distributor_id;
-- ** Join distributors table **
SELECT 
	d.company_name,
	COUNT(s.film_title) AS films_distributed
FROM specs AS s
FULL JOIN distributors AS d
	ON d.distributor_id = s.domestic_distributor_id
WHERE company_name IS NOT NULL
GROUP BY d.company_name;

-- 5. Write a query that returns the five distributors with the highest average movie budget.
SELECT 
	d.company_name,
	AVG(r.film_budget) AS avg_budget
FROM distributors AS d
INNER JOIN specs AS s
	ON d.distributor_id = s.domestic_distributor_id
LEFT JOIN revenue AS r
	USING(movie_id)
GROUP BY d.company_name
ORDER BY avg_budget
LIMIT 5;

-- 6. How many movies in the dataset are distributed by a company which is not headquartered in California? Which of these movies has the highest imdb rating?
-- ** Find distributors not headquartered in CA ** 
SELECT *
FROM distributors
WHERE headquarters NOT LIKE '%CA%';
-- ** Find movies distributed by those two companies **
SELECT
	film_title,
	domestic_distributor_id
FROM specs
WHERE
	domestic_distributor_id = 86137
	OR domestic_distributor_id = 86144;
-- ** Put it all together **
SELECT
	s.film_title,
	d.company_name
FROM specs AS s
JOIN distributors AS d
	ON d.distributor_id = s.domestic_distributor_id
WHERE domestic_distributor_id IN
	(SELECT distributor_id
	FROM distributors
	WHERE headquarters NOT LIKE '%CA%');

-- 7. Which have a higher average rating, movies which are over two hours long or movies which are under two hours?
-- ** Count movies over 2 hours long and find their average rating **
SELECT
	COUNT(s.film_title),
	AVG(r.imdb_rating) AS avg_rating
FROM specs AS s
JOIN rating AS r
	USING(movie_id)
WHERE length_in_min IN
	(SELECT length_in_min
	FROM specs
	WHERE length_in_min > 120);
-- ** Count movies under 2 hours long and find their average rating **
SELECT
	COUNT(s.film_title),
	AVG(r.imdb_rating) AS avg_rating
FROM specs AS s
JOIN rating AS r
	USING(movie_id)
WHERE length_in_min IN
	(SELECT length_in_min
	FROM specs
	WHERE length_in_min < 120);
-- Answer: Movies OVER 2 hours have higher ratings