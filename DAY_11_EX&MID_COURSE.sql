--EX01
select b.Continent,
FLOOR(avg(a.population))
from city as a
inner join country as b 
on a.COUNTRYCODE =b.CODE
group by b.Continent
--EX02
SELECT 
  ROUND(COUNT(texts.email_id)::DECIMAL
    /COUNT(DISTINCT emails.email_id),2) AS activation_rate
FROM emails
LEFT JOIN texts
  ON emails.email_id = texts.email_id
  AND texts.signup_action = 'Confirmed';
--EX03
--EX04
SELECT a.page_id
FROM pages as a
LEFT JOIN page_likes as b
ON a.page_id = b.page_id
WHERE b.liked_date IS NULL
ORDER BY  a.page_id
--EX05
  
-----------------------------------MID---------COURSE----------TESTING---------------------------
--EX01:
SELECT distinct film_id, sum(replacement_cost) as total_replacement_cost
FROM film
group by film_id
order by sum(replacement_cost)
--EX02
SELECT 
	sum(CASE
		WHEN replacement_cost BETWEEN  9.99 and 19.99 then 1 else 0 
	END) as low,
	sum(CASE
		WHEN replacement_cost BETWEEN  20.00 and 24.99 then 1 else 0 
	END) as medium,
	sum(CASE
		WHEN replacement_cost BETWEEN  25.00 and 29.99 then 1 else 0 
	END)as high
FROM FILM
--EX03
SELECT a.title, a.length, c.name
FROM film as a
INNER JOIN public.film_category AS b
ON a.film_id = b.film_id
INNER JOIN public.category AS c
ON b.category_id= c.category_id
WHERE c.name in ('Drama','Sports')
ORDER BY a.length DESC
--EX04
SELECT c.name, 
count(*) as number_titles,
FROM film as a
INNER JOIN public.film_category AS b
ON a.film_id = b.film_id
INNER JOIN public.category AS c
ON b.category_id= c.category_id
GROUP BY  c.name
ORDER BY number_titles DESC
--EX05
SELECT a.first_name, a.last_name, count(c.film_id) as number_of_films
FROM actor AS a
INNER JOIN film_actor AS b
ON a.actor_id = b.actor_id
INNER JOIN film AS c
ON c.film_id = b.film_id
GROUP BY a.first_name, a.last_name
ORDER BY number_of_films DESC
--EX06
SELECT b.address
FROM customer AS a
RIGHT JOIN address AS b
ON a.address_id  = b.address_id
WHERE a.address_id IS NULL
--EX07
SELECT a.city, sum(d.amount) as total_city
FROM city as a
JOIN address as b 
ON a.city_id = b.city_id
JOIN customer as c
ON b.address_id = c.address_id
JOIN payment as d
ON c.customer_id = d.customer_id
GROUP BY a.city
ORDER BY total_city DESC
--EX08
SELECT CONCAT(a.city,', ',e.country) as city_country,
sum(d.amount) as total_amount
FROM city as a
JOIN country as e
ON e.country_id= a.country_id
JOIN address as b 
ON a.city_id = b.city_id
JOIN customer as c
ON b.address_id = c.address_id
JOIN payment as d
ON c.customer_id = d.customer_id
GROUP BY city_country
ORDER BY total_amount DESC
