--EX01
SELECT DISTINCT CITY FROM STATION
WHERE ID%2=0
--EX02
SELECT  COUNT(CITY) - COUNT(DISTINCT CITY) FROM STATION
--EX03
SELECT CEIL(AVG(salary) - AVG(REPLACE(salary, '0', '')))
FROM employees;
--EX04
SELECT ROUND(SUM(order_occurrences*item_count::DECIMAL)/SUM(order_occurrences),1) as mean FROM items_per_order;
--EX05
SELECT candidate_id
FROM candidates
WHERE skill IN ('Python','Tableau','PostgreSQL')
GROUP BY candidate_id
HAVING COUNT(skill) =3
ORDER BY candidate_id ASC
--EX06
SELECT user_id, 
MAX(post_date::DATE) - MIN(post_date::DATE) as days_between
FROM posts
WHERE post_date BETWEEN '2021-01-01' AND '2022-01-01'
GROUP BY user_id
HAVING COUNT(post_id)>1
--EX07
SELECT card_name, MAX(issued_amount)- MIN(issued_amount) as difference
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY difference DESC
--EX08
SELECT manufacturer, 
COUNT(drug) as drug_count ,
ABS(SUM(cogs-total_sales)) as total_loss
FROM pharmacy_sales
WHERE cogs > total_sales
GROUP BY manufacturer
ORDER BY total_loss DESC
--EX09
SELECT id, movie, description, rating  FROM CINEMA
WHERE id % 2 != 0 AND description NOT LIKE '%boring%'
ORDER BY rating desc
--EX10
SELECT teacher_id, COUNT(DISTINCT subject_id) as cnt
FROM TEACHER
GROUP BY teacher_id
--EX11
SELECT user_id, COUNT(follower_id) as followers_count
FROM Followers
GROUP BY user_id
ORDER BY user_id
--EX12
SELECT CLASS FROM COURSES
GROUP BY CLASS
HAVING COUNT(STUDENT) >4

