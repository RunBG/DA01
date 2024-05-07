--1. Doanh thu theo từng ProductLine, Year  và DealSize?
SELECT 
    productline,
    year_id,
    dealsize,
    SUM(sales - (priceeach * quantityordered)) AS revenue
FROM 
    sales_dataset_rfm_prj_clean
GROUP BY 
    productline,
    year_id,
    dealsize
ORDER BY 
    productline,
    year_id,
    dealsize
--2. Đâu là tháng có bán tốt nhất mỗi năm?
WITH MonthlySales AS (
    SELECT 
        year_id,
        month_id,
        SUM(sales - (priceeach * quantityordered)) AS revenue,
        COUNT(ordernumber) AS order_number
    FROM 
        sales_dataset_rfm_prj_clean
    GROUP BY 
        year_id,
        month_id
)
SELECT 
    year_id,
    month_id,
    revenue,
    order_number
FROM 
    MonthlySales
WHERE 
    (year_id, revenue) IN (
        SELECT year_id, MAX(revenue) 
        FROM MonthlySales 
        GROUP BY year_id
    )
ORDER BY 
    year_id
-- 3. Product line nào được bán nhiều ở tháng 11?
WITH NovemberSales AS (
    SELECT 
        month_id,
        productline,
        SUM(sales - (priceeach * quantityordered)) AS revenue,
        COUNT(ordernumber) AS order_number
    FROM 
        sales_dataset_rfm_prj_clean
    WHERE 
        month_id = 11
    GROUP BY 
        month_id,
        productline
)
SELECT 
    month_id,
    revenue,
    order_number
FROM 
    NovemberSales
WHERE 
    (revenue, order_number) IN (
        SELECT MAX(revenue), MAX(order_number) 
        FROM NovemberSales
    )
--4. Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm? 
select 
		year_id,
		productline,
		SUM(sales - (priceeach * quantityordered)) AS revenue,
		rank() over(partition by year_id order by SUM(sales - (priceeach * quantityordered)) desc ) as rank
from 
	sales_dataset_rfm_prj_clean
where country='UK'
group by year_id, productline
--5. Ai là khách hàng tốt nhất, phân tích dựa vào RFM

with cte_revenue as
(
SELECT 
    productline,
    year_id,
    dealsize,
    SUM(sales - (priceeach * quantityordered)) AS revenue
FROM 
    sales_dataset_rfm_prj_clean
GROUP BY 
    productline,
    year_id,
    dealsize
ORDER BY 
    productline,
    year_id,
    dealsize
)
    

WITH MonthlySales AS (
    SELECT 
        year_id,
        month_id,
        SUM(sales - (priceeach * quantityordered)) AS revenue,
        COUNT(ordernumber) AS order_number
    FROM 
        sales_dataset_rfm_prj_clean
    GROUP BY 
        year_id,
        month_id
)
SELECT 
    year_id,
    month_id,
    revenue,
    order_number
FROM 
    MonthlySales
WHERE 
    (year_id, revenue) IN (
        SELECT year_id, MAX(revenue) 
        FROM MonthlySales 
        GROUP BY year_id
    )
ORDER BY 
    year_id
WITH NovemberSales AS (
    SELECT 
        month_id,
        productline,
        SUM(sales - (priceeach * quantityordered)) AS revenue,
        COUNT(ordernumber) AS order_number
    FROM 
        sales_dataset_rfm_prj_clean
    WHERE 
        month_id = 11
    GROUP BY 
        month_id,
        productline
)
SELECT 
    month_id,
    revenue,
    order_number
FROM 
    NovemberSales
WHERE 
    (revenue, order_number) IN (
        SELECT MAX(revenue), MAX(order_number) 
        FROM NovemberSales
    )
select 
		year_id,
		productline,
		SUM(sales - (priceeach * quantityordered)) AS revenue,
		rank() over(partition by year_id order by SUM(sales - (priceeach * quantityordered)) desc ) as rank
from 
	sales_dataset_rfm_prj_clean
where country='UK'
group by year_id, productline
select * from segment_score
select * from sales_dataset_rfm_prj_clean
select 
		current_date-MAX(orderdate) as R,
		count(distinct customername) as F,
		
		


