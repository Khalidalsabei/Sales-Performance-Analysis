/*
=====================================================================================================================
                               EXPLORATORY DATA ANALYSIS (EDA)
=====================================================================================================================

-Objective-
Understanding:

Where do sales come from?
When?Who?
What sells the most?
Examining total customers,product.
Total revenue and sales for each Category,Customer,Segment,State,Region,City,Year and Month.
What is PRODUCTS or CUSTOMER GENERATE HIGHEST REVENUE.
What is WORST PERFORMING PRODUCT.
---------------------------------------------------------------------------------------------------------------------

                                                                              */
 
 


--Examining the data and its contents.
SELECT *
FROM Sales_cleaned
  




  --Examining the dimensions of columns and their contents.
SELECT DISTINCT country,category,sub_category,product_name 
FROM Sales_cleaned
order by 1,2,3





--Review the date columns for the first and last orders, and the difference between them. 

SELECT order_date FROM Sales_cleaned
--the difference between them.
SELECT 
    min(order_date)first_order_date,
    max(order_date)last_order_date,
    DATEDIFF(YEAR,min(order_date),max(order_date)) AS Order_Range_Year
FROM Sales_cleaned 





--Examining the measure columns.
SELECT
    SUM(sales) AS Total_Sales,
    AVG(Sales) AS avg_sales,
     COUNT(DISTINCT Order_ID)AS Total_orders, 
     COUNT(DISTINCT Product_ID) AS Total_products, 
     COUNT(Customer_ID)AS Total_customers
 FROM Sales_cleaned





 --Preparing a report that displays all key business indicators.
SELECT 'Total_sales' AS measure_name,SUM(sales)AS measure_value FROM Sales_cleaned
UNION ALL
SELECT 'Total_orders' , COUNT(DISTINCT Order_ID) FROM Sales_cleaned
UNION ALL
SELECT 'Total_products' ,COUNT(DISTINCT Product_ID) FROM Sales_cleaned
UNION ALL
SELECT 'Total_customers' , COUNT(Customer_ID) FROM Sales_cleaned





--total customers by country.

SELECT City,count(Customer_ID)AS total_customer
FROM Sales_cleaned
GROUP BY City
ORDER BY total_customer DESC





--total product by category.
SELECT category,
COUNT(DISTINCT Product_ID)AS total_product
FROM Sales_cleaned
GROUP BY category
ORDER BY total_product DESC





--total revenue for each category. 
SELECT
category,
SUM(sales) as total_revenue
FROM Sales_cleaned 
GROUP BY category
ORDER BY total_revenue DESC





--total revenue by each customer. 
SELECT
customer_id,customer_name,
SUM(sales) as total_revenue
FROM Sales_cleaned  
GROUP BY customer_id,customer_name
ORDER BY total_revenue DESC





--Sales per customer segment.
SELECT
  Segment,
  SUM(Sales) AS total_sales
FROM Sales_cleaned 
GROUP BY Segment;





--Sales distribution by state, region, city. 
SELECT
[state],
COUNT(DISTINCT Product_ID) as total_sold_item
FROM Sales_cleaned 
GROUP BY [state]
ORDER BY total_sold_item DESC




SELECT
Region,
SUM(sales) as total_sales
FROM Sales_cleaned 
GROUP BY Region
ORDER BY total_sales DESC




SELECT
  City,
  SUM(Sales) AS total_sales
FROM Sales_cleaned
GROUP BY City
ORDER BY total_sales DESC





--Sales by year and month.
SELECT
  YEAR(order_date) AS year,
  MONTH(order_date) AS month,
  SUM(Sales) AS total_sales
FROM Sales_cleaned
GROUP BY year(order_date), month(order_date)
ORDER BY year(order_date), month(order_date);





--5 PRODUCTS GENERATE HIGHEST REVENUE.
SELECT TOP 5
Product_Name,
SUM(sales) as total_revenue
FROM Sales_cleaned 
GROUP BY  Product_Name
ORDER BY total_revenue DESC





--5 WORST PERFORMING PRODUCT IN TERMS OF SALES.
SELECT TOP 5
product_name,
SUM(sales) as total_revenue
FROM Sales_cleaned 
GROUP BY product_name
ORDER BY total_revenue 

--OR BY USING ROW NUMBER. 
SELECT*
FROM(
SELECT
product_name,
SUM(sales)  total_revenue,
ROW_NUMBER() OVER( ORDER BY SUM(sales) DESC) AS RANK_Products
FROM Sales_cleaned 
GROUP BY product_name)t
WHERE  RANK_Products <=5





--10 CUSTOMER WHO HAVE GENERATED THE HIGHEST REVENUE.
SELECT TOP 10
customer_id,customer_name,
SUM(sales) as total_revenue
FROM Sales_cleaned 
GROUP BY customer_id,customer_name
ORDER BY total_revenue DESC





--3 CUSTOMER WITH THE FEWEST ORDERS PLAESD.
SELECT TOP 3
customer_id,customer_name,
COUNT(DISTINCT Order_ID) as total_orders
FROM Sales_cleaned
GROUP BY customer_id,customer_name
ORDER BY total_orders 

