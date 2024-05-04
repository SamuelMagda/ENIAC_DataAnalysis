/* Business Questions*/

USE magist;

/*=========================================================================================================*/
/*What categories of tech products does Magist have?*/
SELECT 
	product_category_name_english AS Product_Category, 
    ROUND(SUM(order_item_id), 2) AS Ordered_Items, 
    ROUND(SUM(price), 2) AS Price, 
    COUNT(DISTINCT products.product_id) AS Products_by_ID
FROM orders

LEFT JOIN 
	order_items ON 
    orders.order_id = order_items.order_id

LEFT JOIN
	products ON
    order_items.product_id = products.product_id

LEFT JOIN
	product_category_name_translation ON
	products.product_category_name = product_category_name_translation.product_category_name
    
WHERE product_category_name_english IN ('audio', 'computers', 'computers_accessories', 'consoles_games', 'electronics', 'pc_gamer', 'telephony', 'signaling_and_security')
GROUP BY product_category_name_english 
ORDER BY Price DESC;

/*=========================================================================================================*/
/*How many products of these tech categories have been sold (within the time window of the database snapshot)? What percentage does that represent from the overall number of products sold?*/
SELECT 
	product_category_name_english AS Product_Category, 
    COUNT(DISTINCT products.product_id) AS Total_Products,
    ROUND(100 * COUNT(DISTINCT products.product_id) / SUM(COUNT(DISTINCT products.product_id)) OVER (), 2) AS Grand_Total_Products
FROM products

LEFT JOIN
	product_category_name_translation ON
	products.product_category_name = product_category_name_translation.product_category_name
GROUP BY Product_Category
ORDER BY Total_Products DESC;

/*=========================================================================================================*/

SELECT 
    pct.product_category_name_english AS Product_Category,
    COUNT(DISTINCT oi.product_id) AS Distinct_Products_sold,
    ROUND(
        100 * COUNT(DISTINCT oi.product_id) / 
        (SELECT COUNT(DISTINCT product_id) FROM order_items), 
        2
    ) AS Percentage_of_total_distinct_Products
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation pct
    ON p.product_category_name = pct.product_category_name
WHERE pct.product_category_name_english IN (
    'audio', 
    'computers', 
    'computers_accessories', 
    'consoles_games', 
    'electronics', 
    'pc_gamer', 
    'telephony', 
    'signaling_and_security'
)
GROUP BY Product_Category
ORDER BY Distinct_Products_sold DESC;

/*=========================================================================================================*/

SELECT 
    SUM(Percentage_of_total_distinct_Products) AS Total_Percentage
FROM (SELECT ROUND(100 * COUNT(DISTINCT oi.product_id) / 
            (SELECT COUNT(DISTINCT product_id) FROM order_items), 2) AS Percentage_of_total_distinct_Products
    FROM products p
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    LEFT JOIN product_category_name_translation pct
        ON p.product_category_name = pct.product_category_name
    WHERE pct.product_category_name_english IN (
        'audio', 
        'computers', 
        'computers_accessories', 
        'consoles_games', 
        'electronics', 
        'pc_gamer', 
        'telephony', 
        'signaling_and_security'
    )
    GROUP BY pct.product_category_name_english
) AS subquery;

/*=========================================================================================================*/

SELECT 
	product_category_name_english AS Product_Category, 
    COUNT(DISTINCT products.product_id) AS Total_Products,
    SUM(COUNT(DISTINCT products.product_id)) OVER () AS Grand_Total_Products
FROM products

LEFT JOIN
	product_category_name_translation ON
	products.product_category_name = product_category_name_translation.product_category_name
    
GROUP BY Product_Category;

/*=========================================================================================================*/
/* What’s the average price of the products being sold? */
SELECT 
    pct.product_category_name_english AS Product_Category, 
    ROUND(AVG(oi.price), 2) AS Average_Price
FROM order_items oi

LEFT JOIN 
    products p ON oi.product_id = p.product_id

LEFT JOIN
    product_category_name_translation pct ON p.product_category_name = pct.product_category_name

WHERE pct.product_category_name_english IN (
    'audio', 
    'computers', 
    'computers_accessories', 
    'consoles_games', 
    'electronics', 
    'pc_gamer', 
    'telephony', 
    'signaling_and_security'
)

GROUP BY pct.product_category_name_english 
ORDER BY Average_Price DESC;

/*=========================================================================================================*/

SELECT 
    ROUND(AVG(subquery.Average_Price), 2) AS Average_Tech_Price
FROM (
    SELECT 
        pct.product_category_name_english AS Product_Category, 
        ROUND(AVG(oi.price), 2) AS Average_Price
    FROM order_items oi
    LEFT JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation pct ON p.product_category_name = pct.product_category_name
    WHERE pct.product_category_name_english IN (
        'audio', 
        'computers', 
        'computers_accessories', 
        'consoles_games', 
        'electronics', 
        'pc_gamer', 
        'telephony', 
        'signaling_and_security'
    )
    GROUP BY pct.product_category_name_english 
) AS subquery;

/*=========================================================================================================*/
/*Are expensive tech products popular? */
SELECT 
	SUM(oi.order_item_id) AS Products_Sold,
    pcat.product_category_name_english AS Product_Category,
	MAX(oi.price) AS Max_Price,

CASE
	WHEN SUM(oi.order_item_id) > 5000 THEN "Very Popular"
	WHEN SUM(oi.order_item_id) BETWEEN 2000 AND 4999 THEN "Popular"
    WHEN SUM(oi.order_item_id) BETWEEN 1000 AND 1999 THEN "Medium Popular"
    ELSE "Not Popular"
    END AS "Popularity_by_Sales"

FROM order_items oi

LEFT JOIN
	products AS p ON
	oi.product_id = p.product_id
    
LEFT JOIN
	product_category_name_translation AS pcat ON
	p.product_category_name = pcat.product_category_name

WHERE product_category_name_english IN (
	'audio', 
	'computers', 
	'computers_accessories', 
	'consoles_games', 
	'electronics', 
	'pc_gamer', 
	'telephony', 
	'signaling_and_security'
)
GROUP BY Product_Category
ORDER BY Products_Sold DESC;

/*=========================================================================================================*/
/* Calculate the average order price for specified tech product categories */
SELECT 
    pct.product_category_name_english AS Product_Category,
    ROUND(AVG(oi.price), 2) AS Average_Order_Price
FROM order_items oi

LEFT JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pct ON p.product_category_name = pct.product_category_name

WHERE pct.product_category_name_english IN (
    'audio', 
    'computers', 
    'computers_accessories', 
    'consoles_games', 
    'electronics', 
    'pc_gamer', 
    'telephony', 
    'signaling_and_security'
)

GROUP BY pct.product_category_name_english 
ORDER BY Average_Order_Price DESC;

/*=========================================================================================================*/
/* Calculate the average price of all orders */
SELECT 
    ROUND(AVG(total_order_price)) AS Average_Order_Price
FROM (
    SELECT 
        orders.order_id,
        SUM(order_items.price) AS total_order_price
    FROM orders
    LEFT JOIN order_items ON orders.order_id = order_items.order_id
    GROUP BY orders.order_id
) AS order_prices;

/*=========================================================================================================*/
/* Average montlhy payments*/
SELECT ROUND(AVG(Monthly_Payment_Value), 0) AS Average_Monthly_Payments
FROM (
SELECT 
	YEAR(order_purchase_timestamp) AS Purchase_Year,
	MONTH(order_purchase_timestamp) AS Purchase_Month,
    ROUND(SUM(payment_value), 0) AS Monthly_Payment_Value 
FROM order_items AS oi

LEFT JOIN
	products AS p ON
	oi.product_id = p.product_id
    
LEFT JOIN
	product_category_name_translation AS pcat ON
    p.product_category_name = pcat.product_category_name
    
LEFT JOIN
	orders AS o ON
    oi.order_id = o.order_id

LEFT JOIN
	order_payments AS op ON
    o.order_id = op.order_id
    
WHERE order_status = "delivered"
GROUP BY Purchase_Year, Purchase_Month
ORDER BY Purchase_Year, Purchase_Month
) AS Subquery;

/*=========================================================================================================*/
/* Total Payment Value*/
SELECT 
	ROUND(SUM(payment_value), 0) AS PaymentValue 
FROM order_items AS oi

LEFT JOIN
	products AS p ON
	oi.product_id = p.product_id
    
LEFT JOIN
	product_category_name_translation AS pcat ON
    p.product_category_name = pcat.product_category_name
    
LEFT JOIN
	orders AS o ON
    oi.order_id = o.order_id

LEFT JOIN
	order_payments AS op ON
    o.order_id = op.order_id
    
WHERE order_status = "delivered";

/*=========================================================================================================*/
/* Montly Payment Value per year*/
SELECT 
	YEAR(order_purchase_timestamp) AS Purchase_Year,
	MONTH(order_purchase_timestamp) AS Purchase_Month,
    ROUND(SUM(payment_value), 0) AS Monthly_Payment_Value 
FROM order_items AS oi

LEFT JOIN
	products AS p ON
	oi.product_id = p.product_id
    
LEFT JOIN
	product_category_name_translation AS pcat ON
    p.product_category_name = pcat.product_category_name
    
LEFT JOIN
	orders AS o ON
    oi.order_id = o.order_id

LEFT JOIN
	order_payments AS op ON
    o.order_id = op.order_id
    
WHERE order_status = "delivered"
GROUP BY Purchase_Year, Purchase_Month
ORDER BY Purchase_Year, Purchase_Month;

/*=========================================================================================================*/
/* Average payment and prive for all products*/
SELECT 
    ROUND(AVG(payment_value), 2) AS Average_Payment_Value, 
    ROUND(AVG(price), 2) AS Average_item_price
FROM order_items AS oi

LEFT JOIN
	products AS p ON
	oi.product_id = p.product_id
    
LEFT JOIN
	product_category_name_translation AS pcat ON
    p.product_category_name = pcat.product_category_name
    
LEFT JOIN
	orders AS o ON
    oi.order_id = o.order_id

LEFT JOIN
	order_payments AS op ON
    o.order_id = op.order_id
    
WHERE order_status = "delivered";

/*=========================================================================================================*/
/* Average payment and prive for TECH products by categories*/
SELECT 
    pcat.product_category_name_english AS Product_Category,
    ROUND(AVG(op.payment_value), 2) AS Average_Payment_Value,
    ROUND(AVG(oi.price), 2) AS Average_Item_Price
FROM order_items oi

LEFT JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pcat ON p.product_category_name = pcat.product_category_name
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_payments op ON o.order_id = op.order_id

WHERE o.order_status = 'delivered'
    AND pcat.product_category_name_english IN (
        'audio', 
        'computers', 
        'computers_accessories', 
        'consoles_games', 
        'electronics', 
        'pc_gamer', 
        'telephony', 
        'signaling_and_security'
    )
GROUP BY pcat.product_category_name_english
ORDER BY Average_Payment_Value DESC;

/*=========================================================================================================*/
/* Total average payment and prive for TECH products*/
SELECT 
    ROUND(AVG(op.payment_value), 2) AS Overall_Average_Payment_Value,
    ROUND(AVG(oi.price), 2) AS Overall_Average_Item_Price
FROM order_items oi

LEFT JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pcat ON p.product_category_name = pcat.product_category_name
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_payments op ON o.order_id = op.order_id

WHERE o.order_status = 'delivered'
    AND pcat.product_category_name_english IN (
        'audio', 
        'computers', 
        'computers_accessories', 
        'consoles_games', 
        'electronics', 
        'pc_gamer', 
        'telephony', 
        'signaling_and_security'
    );
    
/*=========================================================================================================*/
/*=========================================================================================================*/












