USE magist;

/* 1. How many orders are there in the dataset?
*/
SELECT count(*) AS total_orders
FROM orders;


/*2.Are orders actually delivered?
*/
SELECT order_status, COUNT(order_status) AS number_of_orders
FROM orders
GROUP BY order_status;


/*3.Is Magist having user growth?*/
SELECT
	YEAR(order_purchase_timestamp) AS orders_by_year, month(order_purchase_timestamp) AS orders_by_month, /*day(order_purchase_timestamp)*/
    COUNT(customer_id) AS number_of_orders
FROM orders
WHERE order_status = 'delivered'
GROUP by YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp)
ORDER BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp);


/*4.How many products are there on the products table?*/
SELECT
	COUNT(DISTINCT product_id) AS number_of_products
FROM
	products;


/*5.Which are the categories with the most products?*/
SELECT product_category_name_english AS product_category, COUNT(DISTINCT products.product_id) AS number_of_products
FROM products

LEFT JOIN
	order_items ON
    products.product_id = order_items.product_id
    
LEFT JOIN
	product_category_name_translation ON
    products.product_category_name = product_category_name_translation.product_category_name
GROUP BY product_category_name_english
ORDER BY number_of_products DESC;


/*6.How many of those products were present in actual transactions?*/
SELECT Count(DISTINCT product_id) AS number_of_products
FROM order_items;


/*7.What’s the price for the most expensive and cheapest products?*/
SELECT 
	MAX(price) AS most_expensive_product, MIN(price) AS cheapest_product
FROM order_items;


/*8.What are the highest and lowest payment values?*/
SELECT payment_type,
	MAX(payment_value) AS highest_order_payment, MIN(payment_value) AS lowest_order_payment
FROM order_payments
Group BY payment_type;

SELECT
	MAX(payment_value) AS highest_order_payment, MIN(payment_value) AS lowest_order_payment
FROM order_payments
WHERE payment_value > "0";

SELECT
	SUM(payment_value) AS the_highest_order
FROM order_payments
GROUP BY order_id
ORDER BY the_highest_order DESC
Limit 1;
