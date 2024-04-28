--1. Số lượng đơn hàng và số lượng khách hàng mỗi tháng

select 
format_date('%Y-%m',o.delivered_at) as month_year,
COUNT(DISTINCT o.user_id) as total_user,
COUNT(o.order_id) as total_order
from bigquery-public-data.thelook_ecommerce.orders o
join bigquery-public-data.thelook_ecommerce.order_items oi using (order_id)
where oi.status ='Complete' and 
o.delivered_at between '2019-01-01 00:00:00' and '2022-05-01 00:00:00'
group by month_year
order by month_year
--Tìm outlier
WITH cte_total AS (
  SELECT 
    FORMAT_DATE('%Y-%m', o.delivered_at) AS month_year,
    COUNT(DISTINCT o.user_id) AS total_user,
    COUNT(o.order_id) AS total_order
  FROM 
    bigquery-public-data.thelook_ecommerce.orders o
  JOIN 
    bigquery-public-data.thelook_ecommerce.order_items oi USING (order_id)
  WHERE 
    oi.status ='Complete' AND 
    o.delivered_at BETWEEN '2019-01-01 00:00:00' AND '2022-05-01 00:00:00'
  GROUP BY 
    month_year
  ORDER BY 
    month_year
),
z_scores AS (
  SELECT 
    c.*,
    (c.total_user - AVG(c.total_user) OVER()) / STDDEV(c.total_user) OVER() AS z_score
  FROM 
    cte_total c
)
SELECT 
  *
FROM 
  z_scores
WHERE 
  ABS(z_score) > 2
--insight: 
-- 1. Số lượng người mua hàng và đơn hàng tăng dần theo mỗi tháng từng năm
-- 2. Vào những khoảng thời gian tháng 11,12 của các năm tăng vọt lên khá đột biến có thể do các khách hàng
-- chuẩn bị cho lễ giáng sinh và Tết Dương lịch.
-- 3. 4 tháng đầu của năm 2022 số lượng người mua và đơn hàng tăng đột biến so với cùng kì các năm
-- 4. Tháng 7/2021 ghi nhận lượng mua hàng tăng bất thường, trái ngược với lượng mua giảm sút so với cùng kì năm 2020

-- 2. Giá trị đơn hàng trung bình (AOV) và số lượng khách hàng mỗi tháng
