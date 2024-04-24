-- create table SALES_DATASET_RFM_PRJ
-- (
--   ordernumber VARCHAR,
--   quantityordered VARCHAR,
--   priceeach        VARCHAR,
--   orderlinenumber  VARCHAR,
--   sales            VARCHAR,
--   orderdate        VARCHAR,
--   status           VARCHAR,
--   productline      VARCHAR,
--   msrp             VARCHAR,
--   productcode      VARCHAR,
--   customername     VARCHAR,
--   phone            VARCHAR,
--   addressline1     VARCHAR,
--   addressline2     VARCHAR,
--   city             VARCHAR,
--   state            VARCHAR,
--   postalcode       VARCHAR,
--   country          VARCHAR,
--   territory        VARCHAR,
--   contactfullname  VARCHAR,
--   dealsize         VARCHAR
-- ) 
select * from  SALES_DATASET_RFM_PRJ
-- 1. Chuyển đổi kiểu dữ liệu phù hợp cho các trường ( sử dụng câu lệnh ALTER) 
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN ordernumber TYPE integer USING (trim(ordernumber)::integer)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN quantityordered TYPE integer USING (trim(quantityordered)::integer)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN priceeach TYPE numeric USING (priceeach::numeric)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN orderlinenumber TYPE integer USING (trim(orderlinenumber)::integer)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN sales TYPE numeric USING (sales::numeric)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN orderdate TYPE timestamp USING (orderdate::timestamp)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN status TYPE text USING (status::text)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN productline TYPE text USING (productline::text)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN msrp TYPE integer USING (msrp::integer)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN productcode TYPE varchar USING (productcode::varchar)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN customername TYPE text  USING (customername::text)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN phone TYPE text  USING (phone::text)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN addressline1 TYPE text  USING (addressline1::text)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN addressline2 TYPE text  USING (addressline2::text)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN city TYPE text  USING (city::text)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN state TYPE text  USING (state::text)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN postalcode TYPE Integer  USING (postalcode::Integer)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN country TYPE text  USING (country::text)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN territory TYPE varchar  USING (territory::varchar)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN contactfullname TYPE varchar  USING (contactfullname::varchar)
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN dealsize TYPE varchar  USING (dealsize::varchar)
-- 2. Check NULL/BLANK (‘’)  ở các trường: 
-- ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, 
-- SALES, ORDERDATE.
SELECT *
FROM SALES_DATASET_RFM_PRJ
WHERE 
  ordernumber IS NULL OR "ordernumber"::text = '' OR
  quantityordered IS NULL OR "quantityordered"::text = '' OR
  priceeach IS NULL OR "priceeach"::text = '' OR
  orderlinenumber IS NULL OR "orderlinenumber"::text = '' OR
  sales IS NULL OR "sales"::text = '' OR
  orderdate IS NULL OR "orderdate"::text = '';
-- 3. Thêm cột CONTACTLASTNAME, CONTACTFIRSTNAME được tách ra 
-- từ CONTACTFULLNAME . 
-- Chuẩn hóa CONTACTLASTNAME, CONTACTFIRSTNAME theo định dạng chữ 
-- cái đầu tiên viết hoa, chữ cái tiếp theo viết thường.
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN CONTACTFIRSTNAME  VARCHAR;
ADD COLUMN CONTACTLASTNAME  VARCHAR;
-- select CONCAT(UPPER(LEFT(left(contactfullname,position('-' in contactfullname)-1),1)), LOWER(RIGHT(left(contactfullname,position('-' in contactfullname)-1), length(left(contactfullname,position('-' in contactfullname)-1))-1)))
--  as contactlastname1 from SALES_DATASET_RFM_PRJ
-- select CONCAT(UPPER(LEFT(right(contactfullname,-position('-' in contactfullname)),1)), LOWER(RIGHT(right(contactfullname,-position('-' in contactfullname)), length(right(contactfullname,-position('-' in contactfullname)))-1))) as contactfirsrname1 from SALES_DATASET_RFM_PRJ
-- select contactfullname from SALES_DATASET_RFM_PRJ
UPDATE SALES_DATASET_RFM_PRJ
SET contactlastname=CONCAT(UPPER(LEFT(left(contactfullname,position('-' in contactfullname)-1),1)), 
						   LOWER(RIGHT(left(contactfullname,position('-' in contactfullname)-1), 
									   length(left(contactfullname,position('-' in contactfullname)-1))-1))),
	contactfirstname =CONCAT(UPPER(LEFT(right(contactfullname,-position('-' in contactfullname)),1)), 
							 LOWER(RIGHT(right(contactfullname,-position('-' in contactfullname)), 
										 length(right(contactfullname,-position('-' in contactfullname)))-1)))
SELECT contactlastname, contactfirstname SELECT SALES_DATASET_RFM_PRJ
-- 4. Thêm cột QTR_ID, MONTH_ID, YEAR_ID lần lượt là Qúy, tháng, năm 
-- được lấy ra từ ORDERDATE 

-- SELECT EXTRACT (QUARTER FROM ORDERDATE) AS QTR_ID,
-- 		EXTRACT (MONTH FROM ORDERDATE) AS MONTH_ID,
-- 		EXTRACT (YEAR FROM ORDERDATE) AS YEAR_ID
-- FROM SALES_DATASET_RFM_PRJ
SELECT QTR_ID, MONTH_ID, YEAR_ID FROM SALES_DATASET_RFM_PRJ
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN QTR_ID INTEGER,
ADD COLUMN MONTH_ID  INTEGER,
ADD COLUMN YEAR_ID  INTEGER;
UPDATE SALES_DATASET_RFM_PRJ
SET QTR_ID = EXTRACT (QUARTER FROM ORDERDATE),
	MONTH_ID = EXTRACT (MONTH FROM ORDERDATE),
	YEAR_ID = EXTRACT (YEAR FROM ORDERDATE)
-- 5.Hãy tìm outlier (nếu có) cho cột QUANTITYORDERED 
--   và hãy chọn cách xử lý cho bản ghi đó (2 cách)
--Cách 1 (Dùng Boxplot)
-- with cte_min_max_value as
-- (
-- 	SELECT 	Q1-1.5*IQR AS min_value,
-- 			Q3+1.5*IQR AS max_value
-- 	from(
-- 		 SELECT 
--         PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY QUANTITYORDERED) AS Q1,
--         PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY QUANTITYORDERED) AS Q3,
-- 		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY QUANTITYORDERED) - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY QUANTITYORDERED) as IQR
-- 		FROM SALES_DATASET_RFM_PRJ
-- 	) AS a
-- )
-- select QUANTITYORDERED from SALES_DATASET_RFM_PRJ
-- where QUANTITYORDERED < (select min_value from cte_min_max_value) 
-- or 		QUANTITYORDERED > (select max_value from cte_min_max_value) 
WITH Quartiles AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY QUANTITYORDERED) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY QUANTITYORDERED) AS Q3,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY QUANTITYORDERED) - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY QUANTITYORDERED) as IQR

    FROM 
        SALES_DATASET_RFM_PRJ
),
OutlierBounds AS (
    SELECT 
        Q1 - 1.5 * (Q3 - Q1) AS LowerBound,
        Q3 + 1.5 * (Q3 - Q1) AS UpperBound
    FROM 
        Quartiles
)

SELECT 
    quantityordered
FROM 
    SALES_DATASET_RFM_PRJ
WHERE 
    quantityordered  < (SELECT LowerBound FROM OutlierBounds) OR
    quantityordered  > (SELECT UpperBound FROM OutlierBounds)

UPDATE SALES_DATASET_RFM_PRJ
SET quantityordered = Null
WHERE quantityordered in (select quantityordered from outlier_new )
--cách 2: Dùng Z-score
-- select avg(quantityordered),
-- stddev(quantityordered)
-- from SALES_DATASET_RFM_PRJ

with cte as
(
	select quantityordered,
	(select avg(quantityordered)
	from SALES_DATASET_RFM_PRJ ) as avg,
	(select stddev(quantityordered)
	 from SALES_DATASET_RFM_PRJ) as stddev
	from SALES_DATASET_RFM_PRJ
)
select quantityordered, (quantityordered-avg)/stddev as z_score
from cte
where abs((quantityordered-avg)/stddev)>3
order by quantityordered

select * from SALES_DATASET_RFM_PRJ
where 
-- 6. Sau khi làm sạch dữ liệu, hãy lưu vào bảng mới  tên là SALES_DATASET_RFM_PRJ_CLEAN

create table SALES_DATASET_RFM_PRJ_CLEAN as (select * from SALES_DATASET_RFM_PRJ);




