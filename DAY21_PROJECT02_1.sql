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
select 
format_date('%Y-%m',created_at) as month_year,
COUNT(DISTINCT user_id) as distinct_users,
round(sum(sale_price)/count(order_id),2) as average_order_value
from bigquery-public-data.thelook_ecommerce.order_items 
where 
created_at between '2019-01-01 00:00:00' and '2022-05-01 00:00:00'
group by month_year
order by month_year
--Tính sự chênh lệch giữa các tháng
with cte_table as(
  select 
  format_date('%Y-%m',created_at) as month_year,
  COUNT(DISTINCT user_id) as distinct_users,
  round(sum(sale_price)/count(order_id),2) as average_order_value
  from bigquery-public-data.thelook_ecommerce.order_items 
  where 
  created_at between '2019-01-01 00:00:00' and '2022-05-01 00:00:00'
  group by month_year
  order by month_year
)

SELECT 
    month_year,
    distinct_users - lag(distinct_users) OVER (ORDER BY month_year) AS diff_value_user,
    average_order_value - lag(average_order_value) over (order by month_year) as diff_value_avg_order
FROM 
    cte_table
order by month_year
--Insight:
-- Giai đoạn năm 2019 do số lượng người dùng ít khiến giá trị đơn hàng trung bình 
-- qua các tháng có tỷ lệ biến động cao
-- Nhìn chung giá trị chung bình của những lần order nằm ở vùng 60-70, ít sự thay đổi nhiều qua từng năm
-- 06-2020 có lượng người khách hàng thấp đột biến
-- Mùa xuân năm 2022 bắt đầu có nhiều lượng khách hàng lớn mua hàng ở The Look, có thể đã sử dụng chiến dịch
-- đặc biệt để hút khách hàng
--3. Nhóm khách hàng theo độ tuổi
With female_age as
(
select min(age) as min_age, max(age) as max_age
from bigquery-public-data.thelook_ecommerce.users
Where gender='F' and created_at BETWEEN '2019-01-01 00:00:00' AND '2022-05-01 00:00:00'
),
male_age as
(
select min(age) as min_age, max(age) as max_age
from bigquery-public-data.thelook_ecommerce.users
Where gender='M' and created_at BETWEEN '2019-01-01 00:00:00' AND '2022-05-01 00:00:00'
),
young_old_group as
(
Select t1.first_name, t1.last_name, t1.gender, t1.age
from bigquery-public-data.thelook_ecommerce.users as t1
Join female_age as t2 on t1.age=t2.min_age or t1.age=t2.max_age
Where t1.gender='F'and created_at BETWEEN '2019-01-01 00:00:00' AND '2022-05-01 00:00:00' UNION ALL
Select t3.first_name, t3.last_name, t3.gender, t3.age
from bigquery-public-data.thelook_ecommerce.users as t3
Join female_age as t4 on t3.age=t4.min_age or t3.age=t4.max_age
Where t3.gender = 'M' and created_at BETWEEN '2019-01-01 00:00:00' AND '2022-05-01 00:00:00'
),
age_tag as
(
Select *,
Case
when age in (select min(age) as min_age
from bigquery-public-data.thelook_ecommerce.users
Where gender='F' and created_at BETWEEN '2019-01-01 00:00:00' AND '2022-05-01 00:00:00') then 'Youngest' when age in (select min(age) as min_age
from bigquery-public-data.thelook_ecommerce.users
Where gender='M' and created_at BETWEEN '2019-01-01 00:00:00' AND '2022-05-01 00:00:00') then 'Youngest' Else 'Oldest'
END as tag
from young_old_group
)
Select gender, tag, count(*) as user_count
from age_tag
group by gender, tag
--Insight:
-- Giới tính Female: lớn tuổi nhất là 70 tuổi (504 người người dùng); nhỏ tuổi nhất là 12 tuổi (498 người dùng)
-- Giới tính Male: lớn tuổi nhất là 70 tuổi (484 người người dùng); nhỏ tuổi nhất là 12 tuổi (525 người dùng)
-- 4.Top 5 sản phẩm mỗi tháng
select * from
(with rank_product_profit as 
(
  select 
      format_date('%Y-%m',t1.delivered_at) as month_year,
      t1.product_id, t2.name as product_name,
      round(sum(t1.sale_price),2) as sales,
      round(sum(t2.cost),2) as cost,
      round(sum(t1.sale_price)-sum(t2.cost),2) as profit
from bigquery-public-data.thelook_ecommerce.order_items t1
JOIN bigquery-public-data.thelook_ecommerce.products t2
ON t1.product_id=t2.id
where t1.status = 'Complete'
group by month_year, t1.product_id, t2.name
)
select *,
        dense_rank() over (partition by month_year order by month_year, profit) as rank
from rank_product_profit
) as rank_table
where rank_table.rank <= 5 
order by rank_table.month_year
-- 5.Doanh thu tính đến thời điểm hiện tại trên mỗi danh mục
SELECT 
      format_date('%Y-%m-%d',t1.delivered_at) as dates,
      category as product_categories,
      round(sum(sale_price),2) as revenue
FROM bigquery-public-data.thelook_ecommerce.order_items t1
JOIN bigquery-public-data.thelook_ecommerce.products t2
ON t1.product_id=t2.id
WHERE 
    t1.status ='Complete' AND 
    t1.delivered_at BETWEEN '2019-01-01 00:00:00' AND CURRENT_TIMESTAMP
GROUP BY dates, product_categories
ORDER BY dates

