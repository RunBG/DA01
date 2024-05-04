  WITH monthly_summary AS (
  SELECT 
    FORMAT_DATE('%m', oi.delivered_at) AS Month,
    FORMAT_DATE('%Y', oi.delivered_at) AS Year,
    p.category AS Product_category,
    SUM(oi.sale_price) AS TPV,
    COUNT(DISTINCT oi.order_id) AS TPO
  FROM 
    bigquery-public-data.thelook_ecommerce.order_items oi
  JOIN 
    bigquery-public-data.thelook_ecommerce.products p ON oi.product_id = p.id
  JOIN 
    bigquery-public-data.thelook_ecommerce.orders o ON oi.order_id = o.order_id
  WHERE 
    oi.status ='Complete'
  GROUP BY
    Month, Year, Product_category
  ORDER BY 
    Year, Month
),
lagged_summary AS (
  SELECT 
    month,
    year,
    Product_category,
    TPV,
    TPO,
    LAG(TPV) OVER(PARTITION BY Product_category ORDER BY year, month) AS Lagged_TPV,
    LAG(TPO) OVER(PARTITION BY Product_category ORDER BY year, month) AS Lagged_TPO
  FROM 
    monthly_summary
)
SELECT 
  month,
  year,
  Product_category,
  TPV,
  TPO,
  Lagged_TPV,
  Lagged_TPO,
  ROUND((TPV - Lagged_TPV) / NULLIF(Lagged_TPV, 0) * 100, 2) AS Revenue_growth,
  ROUND((TPO - Lagged_TPO) / NULLIF(Lagged_TPO, 0) * 100, 2) AS Order_growth,
  ROUND(SUM(p.cost), 2) AS Total_cost,
  ROUND(TPV - SUM(p.cost), 2) AS Total_profit,
  ROUND(TPV / NULLIF(SUM(p.cost), 0) * 100, 2) AS Profit_to_cost_ratio
FROM 
  lagged_summary ls
JOIN 
  bigquery-public-data.thelook_ecommerce.products p ON ls.Product_category = p.category 
GROUP BY 
  month, year, Product_category, TPV, TPO, Lagged_TPV, Lagged_TPO;
--retention cohort analysis
with a as(
  select
    user_id,
    format_date('%Y-%m',first_purchase_date) as cohort_date,
    created_at,
    (extract(year from created_at)-extract(year from first_purchase_date ))*12
    + (extract(month from created_at)-extract(month from first_purchase_date))+1 as index
  from (
  select
    user_id,
    min(created_at) over(partition by user_id) as first_purchase_date,
    created_at,
    from bigquery-public-data.thelook_ecommerce.order_items
  ) b
),
xxx as (
  select 
        cohort_date,
        index,
        count(distinct user_id) as total_user,
  from a 
  group by cohort_date, index
), user_cohort as(
select
  cohort_date,
  sum(case when index=1 then total_user else 0 end) as index_0,
  sum(case when index=2 then total_user else 0 end) as index_1,
  sum(case when index=3 then total_user else 0 end) as index_2,
  sum(case when index=4 then total_user else 0 end) as index_3,
  
from xxx
group by cohort_date
order by cohort_date)
--retention_cohort
select cohort_date,

round(100.00*index_0/index_0,2) || '%' as Zero,
round(100.00*index_1/index_0,2) || '%' as First,
round(100.00*index_2/index_0,2) || '%' as Second,
round(100.00*index_3/index_0,2) || '%' as Third,
from user_cohort
--insight:
-- Nhìn chung số khách hàng quay trở lại sẽ tập trung những tháng cuối năm
-- Có sự tiến triển theo từng năm số khách hàng quay trở lại


