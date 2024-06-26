---EX_01
SELECT NAME FROM CITY
WHERE CITY.POPULATION > 120000
AND CITY.COUNTRYCODE = 'USA'
---EX_02
SELECT * FROM CITY
WHERE COUNTRYCODE = 'JPN'
---EX_03
SELECT CITY, STATE FROM STATION
---EX_04
SELECT DISTINCT CITY FROM STATION
WHERE CITY LIKE 'A%' OR CITY LIKE 'E%' OR CITY LIKE 'I%' OR CITY LIKE 'O%' OR CITY LIKE 'U%' OR
      CITY LIKE 'a%' OR CITY LIKE 'e%' OR CITY LIKE 'i%' OR CITY LIKE 'o%' OR CITY LIKE 'u%';
--EX_05
SELECT DISTINCT CITY FROM STATION
WHERE CITY LIKE '%A' OR CITY LIKE '%E' OR CITY LIKE '%I' OR CITY LIKE '%O' OR CITY LIKE '%U' OR
      CITY LIKE '%a' OR CITY LIKE '%e' OR CITY LIKE '%i' OR CITY LIKE '%o' OR CITY LIKE '%u';
--EX_06
SELECT DISTINCT CITY FROM STATION
WHERE NOT (CITY LIKE 'A%' OR CITY LIKE 'E%' OR CITY LIKE 'I%' OR CITY LIKE 'O%' OR CITY LIKE 'U%' OR
      CITY LIKE 'a%' OR CITY LIKE 'e%' OR CITY LIKE 'i%' OR CITY LIKE 'o%' OR CITY LIKE 'u%')
--EX_07
SELECT NAME FROM EMPLOYEE
ORDER BY NAME ASC
--EX_08
SELECT NAME FROM EMPLOYEE
WHERE SALARY > 2000 AND MONTHS <10
ORDER BY EMPLOYEE_ID ASC
--EX_09
SELECT PRODUCT_ID FROM PRODUCTS
WHERE LOW_FATS='Y' AND RECYCLABLE='Y'
--EX_10
SELECT NAME FROM CUSTOMER
WHERE REFEREE_ID != 2 OR REFEREE_ID IS NULL
--EX_11
SELECT NAME, POPULATION, AREA FROM WORLD
WHERE AREA > 300000 AND POPULATION > 25000000
--EX_12
SELECT DISTINCT AUTHOR_ID AS ID FROM VIEWS
WHERE AUTHOR_ID=VIEWER_ID
ORDER BY AUTHOR_ID ASC
--EX_13
SELECT PART, ASSEMBLY_STEP FROM parts_assembly
WHERE FINISH_DATE IS NULL
--EX_14
SELECT * FROM LYFT_DRIVERS
WHERE YEARLY_SALARY NOT BETWEEN 30000 AND 70000
--EX_15
SELECT ADVERTISING_CHANNEL FROM UBER_ADVERTISING
WHERE MONEY_SPENT >= 100000 AND YEAR = 2019

