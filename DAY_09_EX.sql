--EX01
SELECT 
SUM(CASE
WHEN device_type IN ('laptop') THEN 1 ELSE 0
END) AS laptop_views,
SUM(CASE
  WHEN device_type IN ('tablet','phone') THEN 1 ELSE 0
END) AS mobile_views
FROM viewership;
--EX02
SELECT x,y,z,
CASE
    WHEN x + y > z AND x + z> y AND y + z> x THEN 'Yes' ELSE 'No'
END AS triangle 
FROM Triangle
--EX03
SELECT
ROUND(100.0*SUM(CASE when call_category is NULL OR call_category ='n/a' THEN 1 ELSE 0 END )/COUNT(case_id)) AS call_percentage
FROM callers
--EX04
SELECT name FROM Customer WHERE referee_id!=2 OR referee_id is null;
--EX05
SELECT
    survived,
    SUM(CASE WHEN pclass=1 THEN 1 ELSE 0 END) AS first_class,
    SUM(CASE WHEN pclass=2 THEN 1 ELSE 0 END) AS second_classs,
    SUM(CASE WHEN pclass=3 THEN 1 ELSE 0 END) AS third_class
FROM titanic
GROUP BY 
    survived

