/*
                                     DATA CLEANING

IN This Data cleaning:

-.Examine the table structure
-.create a new table for cleaning
-.Standardization of data types.
-.Handling missing values.
-.Remove duplicates if any.




--Examine the table structure
                                                                                     */
SELECT *
FROM [Sales.csv]

/*

create a new table where I can manipulate and restructure the data without altering the original.     
 
 */

 SELECT*
 INTO Sales_cleaned
 FROM [Sales.csv]
 WHERE 1 = 0;
 
 --Fill in the data
 INSERT INTO Sales_cleaned
 SELECT *
 FROM [Sales.csv];

 SELECT *
 FROM Sales_cleaned
 
 
 --.Standardization of data types.
UPDATE Sales_cleaned
SET order_date = CONVERT(DATE,Order_Date,101),
    ship_date = CONVERT(DATE,Ship_Date,101);


--.Handling missing values.
SELECT
  COUNT(*) AS total_rows
FROM Sales_cleaned;
UPDATE Sales_cleaned
SET Postal_Code = 0
WHERE Postal_Code IS NULL;




--.Remove duplicates if any.

SELECT 
Order_ID, Product_ID,
COUNT(*)
FROM Sales_cleaned
GROUP BY Order_ID,Product_ID
HAVING COUNT(*) > 1;

--Verify whether there is duplicates
SELECT *
FROM Sales_cleaned
WHERE Order_ID = 'US-2017-123750'
AND Product_ID = 'TEC-AC-10004659';
--No duplicates found