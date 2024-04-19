--EX01
SELECT name FROM STUDENTS
WHERE marks > 75
ORDER BY RIGHT(name,3) , id ASC
--EX02
SELECT user_id, 
CONCAT(UPPER(LEFT(name,1)), LOWER(RIGHT(name, length(NAME)-1))) AS name
FROM Users
--EX03
SELECT manufacturer, CONCAT('$',ROUND(sum(total_sales)/1000000) ,' million') as sale
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY sum(total_sales) DESC, manufacturer
--EX04
SELECT EXTRACT(month from submit_date) as mnth,
product_id,
ROUND(AVG(stars),2)
FROM reviews
GROUP BY mnth,product_id
ORDER BY mnth, product_id
--EX05
SELECT sender_id,
COUNT(message_id) AS message_count
FROM messages
WHERE EXTRACT(month FROM sent_date ) = '8'
  AND    EXTRACT(year FROM sent_date) = '2022'
GROUP BY sender_id
ORDER BY message_count DESC
LIMIT 2
--EX06
SELECT tweet_id FROM Tweets
WHERE LENGTH(content)>15
--EX07
SELECT activity_date AS day, COUNT(DISTINCT user_id) AS active_users
FROM Activity
WHERE (activity_date > "2019-06-27" AND activity_date <= "2019-07-27")
GROUP BY activity_date;
--EX08
select COUNT(id) AS number_of_employee
from employees
where extract(month from joining_date) between 1 and 7
and extract(year from joining_date) ='2022'
--EX09
select position('a' in first_name) as positon
from worker
--EX10
select substring(title, length(winery)+1,5)
from winemag_p2;
