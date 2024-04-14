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
-----------------------------------MID---------COURSE----------TESTING---------------------------
--EX01:
SELECT distinct film_id, sum(replacement_cost) as total_replacement_cost
FROM film
group by film_id
order by sum(replacement_cost)
--EX02
