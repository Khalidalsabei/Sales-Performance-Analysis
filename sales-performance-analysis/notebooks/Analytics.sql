/*
======================================================================================================================
                                     DATA ANALYTICS
======================================================================================================================


-Objective-
1.Which products are the best-selling?
2.Performance Analysis
3.The category achieves the most sales? and in each region?
4.Is there a seasonality in sales?
5.change over time analysis trends
6.cumulative analysis
7.Which segment is the most valuable?
8.What are the fastest shipping methods used and what is their impact?
9.Product Report
----------------------------------------------------------------------------------------------------------------------

                                                                                                             */
 
 





 --1.Which products are the best-selling?
 SELECT TOP 10
  Product_Name,
  SUM(Sales) AS total_sales
FROM Sales_cleaned
GROUP BY Product_Name
ORDER BY total_sales DESC





--2.Performance Analysis--

/* 
the yearly performance of products by comparing their sales 
to both the average sales performance of the product,and the previous year's sales       */


WITH Yearly_product_sales AS (
SELECT 
YEAR(order_date) AS order_year,
product_name,
SUM(sales) AS current_sales
FROM Sales_cleaned
WHERE order_date is not null
GROUP BY YEAR(order_date),product_name
)
SELECT 
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) AS average_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS Diff_average,
CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) >0 THEN 'Above Avg'
WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) <0 THEN 'Below Avg'
ELSE 'Avg'
END average_change,
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) Previous_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) Diff_Previous,
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) >0 THEN 'Increase'
WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) <0 THEN 'Decrease'
ELSE 'No change'
END Previous_change
FROM Yearly_product_sales
ORDER BY product_name,order_year





--3.The category achieves the most sales ?
WITH category_sales AS (
SELECT 
category,
SUM(sales) Total_sales
FROM Sales_cleaned
GROUP BY category)
SELECT 
category,
total_sales,
SUM(total_sales) over () overall_sales,
concat(round((cast (Total_sales as float)/SUM(total_sales) over ()) *100,2),'%') AS percentage_of_total
from category_sales
order by total_sales desc

/*The analysis showed the category(Technology) achieves the most sales with 36%*/ 



--.Which category sells the most in each region?

SELECT
  Region,
  Category,
  total_sales
FROM (
  SELECT
    Region,
    Category,
    SUM(Sales) AS total_sales,
    ROW_NUMBER() OVER (
      PARTITION BY Region
      ORDER BY SUM(Sales) DESC
    ) AS rn
  FROM Sales_cleaned
  GROUP BY Region, Category
) t
WHERE rn = 1;

/*The analysis showed the category(Technology) sells the most in all of the region*/




--4.Is there a seasonality in sales?
SELECT
  YEAR(order_date) AS YEAR,
  MONTH(order_date) AS month,
  SUM(Sales) AS total_sales
FROM Sales_cleaned
GROUP BY MONTH(order_date),YEAR(order_date)
ORDER BY MONTH(order_date),YEAR(order_date);

/*The analysis showed a clear seasonal pattern in sales
with sales rising significantly in the fourth quarter of the year
while declining in the first quarter indicating yearend seasonality.*/



--5.change over time analysis trends
SELECT 
YEAR(order_date) AS Order_Year,
MONTH(order_date) AS Order_Month,
SUM(sales)AS Total_Sales,
COUNT(DISTINCT customer_id) as total_customer
FROM Sales_cleaned
WHERE order_date is not null
GROUP BY YEAR(order_date) ,MONTH(order_date)
ORDER BY YEAR(order_date) ,MONTH(order_date)




--6.cumulative analysis 
--the total sales per month and the running total of sales over time
SELECT
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) AS Running_Total
FROM
(
SELECT 
DATETRUNC(MONTH, order_date)AS order_date ,
SUM(sales) AS total_sales
FROM Sales_cleaned
WHERE order_date is not null
GROUP BY DATETRUNC(MONTH, order_date)
)t




--7.Which segment is the most valuable?
SELECT
  Segment,
  COUNT(DISTINCT Customer_ID) AS customers,
  SUM(Sales) AS total_sales,
  AVG(Sales) AS avg_order,
  SUM(Sales) / COUNT(DISTINCT Customer_ID) AS value_per_customer
FROM Sales_cleaned
GROUP BY Segment
ORDER BY value_per_customer DESC;
/*The highest value segment was determined based on the average customer value
(total sales ÷ number of customers) with Segment (Corporate) showing the highest value per customer
making it the most profitable in the medium term.                                                      */





--8.What are the fastest shipping methods used and what is their impact?

--the shipping time for each order
SELECT
  Order_ID,
  Ship_Mode,
  DATEDIFF(day,ship_date,order_date) AS shipping_days
FROM Sales_cleaned

--the average shipping time for each ship mode.
SELECT
  Ship_Mode,
  AVG(DATEDIFF(day,ship_date, order_date)) AS avg_shipping_days
FROM Sales_cleaned
GROUP BY Ship_Mode
ORDER BY avg_shipping_days ASC;

/*The ship mode:Same Day is the fastest because it has the lowest average number of days */


--Does speed affect sales?
SELECT
  Ship_Mode,
  AVG(DATEDIFF(day,ship_date, order_date)) AS avg_shipping_days,
  SUM(Sales) AS total_sales,
  COUNT(*) AS orders
FROM Sales_cleaned
GROUP BY Ship_Mode
ORDER BY avg_shipping_days;

/* The analysis showed that speed does not affect sales */






--9.Product Report

IF OBJECT_ID('dbo.report_products', 'V') IS NOT NULL
    DROP VIEW dbo.report_products
GO

CREATE VIEW dbo.report_products AS

WITH base_query AS (
    SELECT
	    order_id,
        order_date,
		customer_id,
        sales,
        product_id,
        product_name,
        category,
        sub_category
    FROM Sales_cleaned
    WHERE order_date IS NOT NULL  
),

product_aggregations AS (
SELECT
    product_id,
    product_name,
    category,
    sub_category,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
    MAX(order_date) AS last_sale_date,
    COUNT(DISTINCT order_id) AS total_orders,
	COUNT(DISTINCT customer_id) AS total_customers,
    SUM(sales) AS total_sales,
	AVG(sales) AS avg_sales

FROM base_query

GROUP BY
    product_id,
    product_name,
    category,
    sub_category
)

SELECT 
	product_id,
	product_name,
	category,
	sub_category,
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	CASE
		WHEN total_sales > 500 THEN 'High-Performer'
		WHEN total_sales >= 300 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_customers,
	avg_sales,
	-- Average Order Revenue (AOR)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,

	-- Average Monthly Revenue
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_revenue

FROM product_aggregations 

select*
from dbo.report_products
