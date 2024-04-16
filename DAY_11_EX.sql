--EX01
WITH duplicate_jd AS(
SELECT company_id, title, description, COUNT(job_id) AS count_duplicate
FROM job_listings
GROUP BY company_id, title, description
)

SELECT COUNT(DISTINCT company_id) AS duplicate_companies
FROM duplicate_jd
WHERE count_duplicate >1
--EX02
WITH rank_product_cte AS (
SELECT category, product, SUM(spend) AS total_spend ,
    RANK() OVER (
      PARTITION BY category 
      ORDER BY SUM(spend) DESC) AS ranking 
FROM product_spend
WHERE EXTRACT(year FROM transaction_date) ='2022'
GROUP BY category,product)

SELECT 
  category, 
  product, 
  total_spend 
FROM rank_product_cte 
WHERE ranking <= 2 
ORDER BY category, ranking;
--EX03
SELECT COUNT(policy_holder_id) AS member_count
FROM (SELECT policy_holder_id, 
COUNT(case_id) AS call_count
FROM callers
GROUP BY policy_holder_id
HAVING COUNT(case_id) >= 3 )AS call_records
--EX04
SELECT a.page_id
FROM pages as a
LEFT JOIN page_likes as b
ON a.page_id = b.page_id
WHERE b.liked_date IS NULL
ORDER BY  a.page_id
--EX05
WITH CurrentMonth AS (
    SELECT 
        user_id, 
        EXTRACT(MONTH FROM event_date) AS month 
    FROM user_actions 
    WHERE EXTRACT(MONTH FROM event_date) = 7
      AND EXTRACT(YEAR FROM event_date) = 2022
),
PreviousMonth AS (
    SELECT 
        user_id, 
        EXTRACT(MONTH FROM event_date) AS month 
    FROM user_actions 
    WHERE EXTRACT(MONTH FROM event_date) = 6
      AND EXTRACT(YEAR FROM event_date) = 2022
)
SELECT 
    cm.month AS mth, 
    COUNT(DISTINCT cm.user_id) AS monthly_active_users 
FROM CurrentMonth cm
WHERE EXISTS (
    SELECT user_id
    FROM PreviousMonth pm
    WHERE pm.user_id = cm.user_id
)
GROUP BY cm.month;
--EX06
WITH MonthlyTransactions AS (
    SELECT 
        TO_CHAR(trans_date, 'YYYY-MM') AS month,
        country,
        COUNT(*) AS trans_count,
        SUM(amount) AS trans_total_amount
    FROM transactions
    GROUP BY TO_CHAR(trans_date, 'YYYY-MM'), country
),
ApprovedTransactions AS (
    SELECT 
        TO_CHAR(trans_date, 'YYYY-MM') AS month,
        country,
        SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END) AS approved_count,
        SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total_amount
    FROM transactions
    GROUP BY TO_CHAR(trans_date, 'YYYY-MM'), country
)
SELECT 
    mt.month,
    mt.country,
    mt.trans_count,
    at.approved_count,
    mt.trans_total_amount,
    at.approved_total_amount
FROM MonthlyTransactions mt
JOIN ApprovedTransactions at ON mt.month = at.month AND mt.country = at.country
ORDER BY mt.month, mt.country;
--EX07
 WITH first_year_sales as
 (
    SELECT product_id, MIN(year) AS minyear 
    FROM sales 
    GROUP BY product_id 
 )
 select s.product_id,
 f.minyear as first_year,
 s.quantity,
 s.price
 from Sales s
 inner join first_year_sales f 
 on f.product_id=s.product_id
 and f.minyear = s.year
--EX08
select customer_id
from customer
group by customer_id
having count(distinct product_key) = (select count(product_key) from product)
--EX09

SELECT employee_id
FROM employees
WHERE salary < 30000 AND manager_id NOT IN (SELECT employee_id FROM employees) 
ORDER BY employee_id;
--EX10 giống EX01
--EX11
(SELECT name AS results
FROM MovieRating
JOIN Users USING(user_id)
GROUP BY name
ORDER BY COUNT(*) DESC, name
LIMIT 1)

UNION ALL

(SELECT title AS results
FROM MovieRating
JOIN Movies USING(movie_id)
WHERE EXTRACT(MONTH FROM created_at) = '02' AND EXTRACT(YEAR FROM created_at) = '2020'
GROUP BY title
ORDER BY AVG(rating) DESC, title
LIMIT 1)
--EX12

WITH all_ids AS (
   SELECT requester_id AS id 
   FROM RequestAccepted
   UNION ALL
   SELECT accepter_id AS id
   FROM RequestAccepted
  )
SELECT id, 
COUNT(id) AS num
FROM all_ids
GROUP BY id
ORDER BY COUNT(id) DESC
LIMIT 1

