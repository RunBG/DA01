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

