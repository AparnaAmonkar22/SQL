/*Data Cleaning & Preprocessing*/
/*How can you identify null values in your dataset?*/
SELECT * FROM customers
WHERE customer_name IS NULL OR
	city_id IS NULL;
    
SELECT * FROM products
WHERE product_name IS NULL OR
	price IS NULL;
    
SELECT * FROM city
WHERE city_name IS NULL OR
	population IS NULL OR
    estimated_rent IS NULL OR
    city_rank IS NULL;

SELECT * FROM sales
WHERE sale_date IS NULL OR
product_id IS NULL OR
quantity IS NULL OR
customer_id IS NULL OR
total_amount IS NULL OR
rating IS NULL;
/******************************************/

/*How can you check for duplicate entries in the customers table?*/
SELECT product_name, price, COUNT(*)
FROM products
GROUP BY product_name, price
HAVING COUNT(*) > 1;

SELECT city_name, population, estimated_rent, city_rank, COUNT(*)
FROM city 
GROUP BY city_name, population, estimated_rent, city_rank
HAVING COUNT(*) > 1;

SELECT customer_name, city_id, COUNT(*)
FROM customers
GROUP BY customer_name, city_id
HAVING COUNT(*) >1;

SELECT sale_date, product_id, quantity, customer_id, total_amount, rating, COUNT(*)
FROM sales
GROUP BY  sale_date, product_id, quantity, customer_id, total_amount, rating
HAVING COUNT(*) >1;

/*Remove Duplicates*/
DELETE S1 FROM sales S1
JOIN sales S2 ON S1.product_id = S2.product_id
AND S1.sale_id > S2.sale_id;

DELETE FROM sales S1
WHERE ( 
	SELECT sale_id FROM sales S2
    WHERE S1.product_id = S2.product_id
    AND S1.sale_id > S2.sale_id
);
/******************************************/

/*How do you check for mismatches between total_amount and the calculated value of price × quantity?*/
SELECT sale_id, quantity, P.price, total_amount, P.price*S.quantity AS priceXquantity
FROM sales S
JOIN products P ON P.product_id = S.product_id
WHERE total_amount <> P.price*S.quantity;

/*CORRECT THE MISMATCH*/
UPDATE sales S
JOIN products P ON P.product_id = S.product_id 
SET total_amount = P.price*S.quantity
WHERE total_amount <> P.price*S.quantity;
/******************************************/


/*Data Transformation & Integration*/
/*How do you create a comprehensive sales report with customer and product details?*/
SELECT sale_id, sale_date, 
	C.customer_id, customer_name, 
    city_name, 
    P.product_id, product_name, price, 
    quantity, 
    quantity*price AS total_amont
FROM sales S
JOIN customers C ON C.customer_id = S.customer_id
JOIN city ON city.city_id = C.city_id
JOIN products P ON P.product_id = S.product_id
ORDER BY  sale_date DESC, sale_id;
/******************************************/


/*Data Analysis & Aggregation*/
/*(a) Total Sales per City*/
SELECT  city_name, SUM(quantity*price) AS Total_Sale 
FROM sales S
JOIN products P ON P.product_id = S.product_id
JOIN customers CUST ON CUST.customer_id = S.customer_id
JOIN city C ON CUST.city_id = C.city_id
GROUP BY city_name
ORDER BY city_name;
/******************************************/

/*(b) Total Transactions per City
● How many total transactions occurred per city?*/
SELECT city_name, COUNT(sale_id) AS Total_Transactions
FROM sales S
JOIN customers CUST ON CUST.customer_id = S.customer_id
JOIN city C ON C.city_id = CUST.city_id
GROUP BY city_name
ORDER BY city_name;
/******************************************/

/*(c) Unique Customers per City
● How many unique customers are there in each city?*/
SELECT COUNT(DISTINCT city_id) FROM city;
/******************************************/

/*(d) Average Order Value per City
● What is the average order value per city?*/
SELECT city_name, ROUND(AVG(total_amount), 2) AS Avg_Order
FROM sales S
JOIN customers CUST ON CUST.customer_id = S.customer_id
JOIN city C ON C.city_id = CUST.city_id
GROUP BY city_name
ORDER BY city_name;
/******************************************/

/*(e) Product Demand per City
● What is the demand for each product in different cities?*/
SELECT city_name, product_name, COUNT(P.product_id) AS Product_Demand
FROM sales S
JOIN customers CUST ON CUST.customer_id = S.customer_id
JOIN products P ON P.product_id = S.product_id
JOIN city C ON C.city_id = CUST.city_id
GROUP BY city_name, product_name
ORDER BY city_name, Product_Demand DESC;
/******************************************/

/*(f) Monthly Sales Trend
● What is the monthly sales trend?*/
SELECT sale_date, 
MONTHNAME(STR_TO_DATE(sale_date, '%m/%d/%Y')) AS _Month, 
total_amount AS Total_Sale_Per_Month
FROM sales S
ORDER BY  sale_date, _month;
/******************************************/

/*(g) Customer Rating Analysis
● What is the average product rating per city based on customer purchases?*/
SELECT city_name, product_name, ROUND(AVG(rating),2) AS Rating
FROM sales S
JOIN products P ON P.product_id = S.product_id
JOIN customers CUST ON CUST.customer_id = S.customer_id
JOIN city C ON C.city_id = CUST.city_id
GROUP BY city_name, product_name
ORDER BY city_name, product_name, Rating DESC;
/******************************************/

/*Decision-Making & Recommendations*/
/*(a) Top Cities Selection
● How do you identify the top 3 cities based on sales, unique customers, and order count?*/
SELECT  city_name, COUNT(sale_id) AS Order_Count
FROM sales S
JOIN customers CUST ON CUST.customer_id = S.customer_id
JOIN city C ON C.city_id = CUST.city_id
GROUP BY city_name
ORDER BY Order_Count DESC
LIMIT 3;
/******************************************/


/*(b) Final Recommendations
● What are the final recommendations for expanding Monday Coffee shops?*/
SELECT DAYNAME(STR_TO_DATE(sale_date, '%m/%d/%Y')) AS Day,
	COUNT(DAYNAME(STR_TO_DATE(sale_date, '%m/%d/%Y'))) AS Top_5_Sale_Days 
FROM sales
/*WHERE DAYNAME(STR_TO_DATE(sale_date, '%m/%d/%Y')) = 'Monday'*/
GROUP BY DAYNAME(STR_TO_DATE(sale_date, '%m/%d/%Y'))
ORDER BY Top_5_Sale_Days DESC
LIMIT 5;
/******************************************/
