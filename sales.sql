--CREATE A TABLE
create table sales_store(
transaction_id VARCHAR(15),
customer_id	VARCHAR(15),
customer_name VARCHAR(20),
customer_age INT,
gender VARCHAR(15),
product_id VARCHAR(15),
product_name VARCHAR(15),
product_category VARCHAR(15),
quantiy INT,
prce FLOAT,
payment_mode VARCHAR(15),
purchase_date DATE,
time_of_purchase TIME,
status VARCHAR(15));

--SELECT THE TABLE
SELECT*FROM sales_store

--COLUMN SUMMARY
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sales_store';

--Increase size of customer_name
ALTER TABLE sales_store
ALTER COLUMN customer_name VARCHAR(100);

--CHANGE THE DATE FORMAT
Set DATEFORMAT dmy

--INSERT DATASET BY BULK INSERT METHOD
BULK INSERT sales_store
from 'C:\Users\rajur\Downloads\archive\sales.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
     ROWTERMINATOR = '\n'
);
 ----COPY ORIGINAL DATA IN NEW DB NAME STORE
 SELECT *FROM sales_store
 SELECT*INTO Sales from sales_store
 SELECT*FROM Sales

   --DATA CLEANING

---STEP 1:- CHECK THE DUPLICATES
SELECT transaction_id, COUNT(*) AS cnt
FROM sales
GROUP BY transaction_id
HAVING COUNT(*) > 2;

---check the duplicates while it is or not
WITH CTE AS(
SELECT *,
       ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS Row_Num
FROM sales
)
SELECT *FROM CTE
WHERE transaction_id IN ('TXN855235','TXN981773','TXN240646','TXN342128');

---delete the duplicates
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY transaction_id
               ORDER BY transaction_id
           ) AS Row_Num
    FROM sales
)
DELETE
FROM CTE
WHERE Row_Num > 1;


---STEP 2:-CORRECT THE HEADERS
SELECT*FROM Sales

EXEC sp_rename 'dbo.sales.quantiy', 'quantity', 'COLUMN';
EXEC sp_rename 'dbo.sales.prce', 'price', 'COLUMN';


---STEP 3:-CHECK THE DATATYPES
SELECT COLUMN_NAME,DATA_TYPE
FrOM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME ='Sales'

---STEP 4:-CHECK THE NULL VALUES
DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = STRING_AGG(
    'SELECT ''' + COLUMN_NAME + ''' AS ColumnName, 
    COUNT(*) AS NullCount 
    FROM ' + QUOTENAME(TABLE_SCHEMA) + '.sales 
    WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL', 
    ' UNION ALL '
)
WITHIN GROUP (ORDER BY COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'sales';

-- Execute the dynamic SQL
EXEC sp_executesql @SQL;

---Treating Null Values
Select*
from sales
where transaction_id IS NULL
oR customer_id IS NULL
OR customer_name IS NULL
OR customer_age IS NULL
OR gender IS NULL
OR product_id IS NULL
OR product_name IS NULL
OR product_category IS NULL
OR quantity IS NULL
OR price IS NULL
OR payment_mode IS NULL
OR purchase_date IS NULL
OR time_of_purchase IS NULL
OR status IS NULL


delete from Sales
where transaction_id is null

select *from sales 
where customer_name='Ehsaan Ram'

UPDATE Sales
Set customer_id='CUST9494'
where customer_name='Ehsaan Ram'

select *from sales 
where customer_name='Damini Raju'

UPDATE Sales
Set customer_id='CUST1401'
where customer_name='Damini Raju'

select *from sales 
where customer_id='CUST1003'

UPDATE Sales
Set customer_name='Mahika Saini',customer_age=35,gender='Male'
where customer_id='CUST1003'

Select * from Sales

---STEP 5 :  DATA CLEANING

SELECT DISTINCT gender
FROM Sales

UPDATE SALES 
SET gender='M'
where gender='Male'

UPDATE SALES 
SET gender='F'
where gender='Female'

SELECT DISTINCT payment_mode
FROM Sales

UPDATE SALES 
SET payment_mode='Credit Card'
where payment_mode='CC'

Select * from Sales

----DATA ANALYSIS

--Q.1-WHAT ARE THE TOP 5 MOST SELLING PRODUCTS BY QUANTITY

SELECT TOP 5 product_name,SUM(quantity) AS total_quantity_sold
from Sales
WHERE status='Delivered'
group by product_name
order by total_quantity_sold DESC

--Q.2-WHICH PRODUCT WAS MOST FREQUENTLY CANCELLED?
 
 SELECT TOP 5 product_name, COUNT(*) AS total_canceled
from sales
WHERE status='Cancelled'
group by product_name
order by total_canceled DESC

---Q.3--WHAT TIME OF THE DAY HAS HIGHEST NO OF PURCHASES
SELECT * FROM Sales
    SELECT 
         CASE
		 WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
		 WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
		 WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		 WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
	END AS time_of_day,
	COUNT(*) AS total_order
	FROM Sales
	GROUP BY 
	CASE
		 WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
		 WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
		 WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		 WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
	END
	ORDER BY total_order DESC

----Q.4. WHO ARE THE TOP 5 HIGHEST SPENDING CUSTOMERS?
SELECT * FROM Sales   --#CURRENCY IS USED/C0 AND COMMA FOR NO AND en-IN FOR RUPESS SYMBOL
  SELECT TOP 5 customer_name ,
  FORMAT (sum(quantity*price), 'C0','en-IN')  AS total_spend
  from Sales
  group by customer_name 
  order by sum(quantity*price) DESC


  -----Business Problem Solved: I dentify VIP customers.
  -----Business Impact: Personalizd offer, loyalty rewards and retention.
 
  -----------------------------------------------------------------------------------------
  ----Q.5. Which Product Categories generate Highest Revenue?

  Select * from Sales
  Select product_category ,
  FORMAT (sum(quantity*price),'C0','en-IN')  AS Revenue
  from Sales
  group by product_category 
  order by sum(quantity*price) DESC

   -----Business Problem Solved: Identify Top-Performing Product categories
   -----Business Impact: Refine Product strategy , supply chain and promotions.
   --allowing the business to invest more in High-margin or high-demand categories.

  ---------------------------------------------------------------------------------------------
  ----Q.6.What is return / cancellation rate per product category?

   Select * from Sales
   ---CANCELLATION
  Select product_category ,
  FORMAT (count (case when status ='cancelled' THEN 1 END ) *100.0/COUNT (*),'N2')+ '%' AS cancelled_percent
  from sales 
  group by product_category
  order by cancelled_percent DESC

  Select * from Sales
   ---RETURNED
  Select product_category ,
  FORMAT (count (case when status ='returned' THEN 1 END ) *100.0/COUNT (*),'N2')+ '%' AS returned_percent
  from sales 
  group by product_category


  order by returned_percent DESC

 -----Business Problem Solved: Monitor Disatisfaction  trends per category.

 -----Business Impact: Reduce returns, improve product descirptions/expectations.
 ----helps identify and fix product of logistics.

 ------------------------------------------------------------------------------------------------------------
 ----Q.7.What is the most preferred payment mode?

 select *from Sales
 select payment_mode , count(payment_mode) as total_pay
 from sales 
 Group by payment_mode
 order by total_pay desc

 ----Q.8.How does age group affect purchasing behaviour?
  select *from Sales
  --select MIN(customer_age) AS MIN_AGE,MAX(customer_age) AS MAX_AGE
  --FROM SALES
  SELECT 
  CASE 
  WHEN (customer_age) BETWEEN 18 AND 25 THEN '18-25'
  WHEN (customer_age) BETWEEN 26 AND 35 THEN '26-35'
  WHEN (customer_age) BETWEEN 36 AND 50 THEN '36-50'
ELSE '51+'
END AS customer_age,
FORMAT (SUM(price*quantity),'c0','en-IN') AS total_purchase
FROM sales
GROUP BY CASE
  WHEN (customer_age) BETWEEN 18 AND 25 THEN '18-25'
  WHEN (customer_age) BETWEEN 26 AND 35 THEN '26-35'
  WHEN (customer_age) BETWEEN 36 AND 50 THEN '36-50'
  ELSE '51+'
  END
  ORDER BY SUM(price*quantity) DESC

   -----Business Problem Solved:Understand customer Demographics.

   -----Business Impact:Targeted marketing and product recommendations by age group.
------------------------------------------------------------------------------------------------------------

 ----Q.9.What's the Monthly sales trend?

 Select * from Sales
 ----Method 1.

 Select 
 FORMAT(purchase_date,'yyyy-MM') AS Month_year,
FORMAT(SUM(price*quantity),'C0','en-IN') AS total_sales,
SUM(quantity) AS total_quantity
FROM sales
GROUP BY FORMAT (purchase_date,'yyyy-MM')

----Method 2.
Select 
MONTH(purchase_date) AS months,
FORMAT(SUM(price*quantity),'C0','en-IN') AS total_sales,
SUM(quantity) AS total_quantity
FROM sales
GROUP BY MONTH(purchase_date)
ORDER BY months

 -----Business Problem Solved:Sales fluctuations go unnoticed.

 ----Business Impact:Plan inventory and marketing  according to seasonal trends.

 ------------------------------------------------------------------------------------------

 ----Q.10.Are certain gender buying more specific product categories?

 Select * from Sales

 ----Method 1.
 Select gender,product_category ,COUNT(product_category) AS total_purchase
 FROM sales
 GROUP BY gender,product_category
 ORDER BY total_purchase

  ----Method 2.
  SELECT *
  FROM(
  SELECT gender,product_category
  FROM sales
  ) AS source_table
  PIVOT (
   COUNT(gender)
   FOR gender IN ([M],[F])
   ) AS pivot_table
   ORDER BY product_category

   ----Business Problem Solved:Gender based product prefernces.
   ----Business Impact:Personalized ads,gender-focused campaigns.

-------------------------------------------------------------------------------------