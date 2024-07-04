USE magist;

/* About Magist
## Service they offered
## - after-wales service (stock, warehouse management, product shipment, customer service)

## main concerns
## 1. not clear that Magist is a good partner for these high-end tech products (Appple-compatible accessories)
## 2. The delivery fees with the public Post office might be cheap. check cost and if it's fast enough

## purpose of the presentation
##  Whether or not to sign the deal with Magist
## based on the given dataset of Magist and your own research about the Brazilian market, (like current trends, business opportunities, and competitors)
## Aim: 3-4 mins presentation, max 5 mins 
*/

## note
## - each order can contatin multiple products
## all prices are in euros

## 1. How many orders are there in the dataset? 99441
SELECT COUNT(*) AS orders_count
FROM orders;

## 2. Are orders actually delivered? 
SELECT order_status, COUNT(*) AS orders
FROM orders
GROUP BY order_status;

## 3. Is Magist having user growth?
SELECT 
    YEAR(order_purchase_timestamp) AS year_,
    MONTH(order_purchase_timestamp) AS month_,
    COUNT(customer_id)
FROM
    orders
GROUP BY year_ , month_
ORDER BY year_ , month_;

## 4. How many products are there on the 'products' table? 32951
SELECT COUNT(DISTINCT product_id) as total_products
FROM products;

## 5. Which are the categories with the most products?
SELECT product_category_name_english, count(DISTINCT product_id) as total_products
FROM products
JOIN product_category_name_translation USING(product_category_name)
GROUP BY product_category_name
ORDER BY total_products DESC;


## 6. How many of those products were present in actual transactions? all items are involved
SELECT COUNT(DISTINCT product_id)
FROM order_items;

## 7. What’s the price for the most expensive and cheapest products?
SELECT MIN(price) AS cheapest,
MAX(price) AS most_expensive
 FROM order_items;

## 8. What are the highest and lowest payment values?
## Highest and lowest payment values:
SELECT MAX(payment_value) as highest,
	   MIN(payment_value) as lowest
FROM order_payments;

## Maximum someone has paid for an order:
SELECT
    SUM(payment_value) AS highest_order
FROM
    order_payments
GROUP BY
    order_id
ORDER BY
    highest_order DESC
LIMIT
    1;
    
    
/*
What categories of tech products does Magist have?
computers_accessories
electronics
computers

*/

SELECT o.order_id, p_eng.product_category_name_english, oi.order_item_id, o.order_status, oi.price
FROM orders AS o
JOIN order_items AS oi USING (order_id)
JOIN products AS p USING (product_id)
JOIN product_category_name_translation AS p_eng USING (product_category_name);

## orders

SELECT o.order_id, o.order_item_id, pt.product_category_name_english, o.price
FROM order_items AS o
JOIN products AS p
ON o.product_id = p.product_id
JOIN product_category_name_translation AS pt
ON pt.product_category_name = p.product_category_name;

## Sales overview by category
SELECT pt.product_category_name_english AS category, COUNT(o.order_item_id) AS total_qty, ROUND(SUM(o.price)) AS sales
FROM order_items AS o
JOIN products AS p
USING (product_id)
JOIN product_category_name_translation AS pt
USING (product_category_name)
WHERE pt.product_category_name_english IN ('audio', 'computers_accessories', 'electronics', 'computers')
GROUP BY category
ORDER BY total_qty DESC;


## Sales overview by tech categories with ratio
SELECT pt.product_category_name_english AS category, COUNT(oi.order_item_id) AS total_qty, ROUND(SUM(oi.price)) as sales,
	   ROUND(COUNT(oi.order_item_id) /
       (SELECT COUNT(order_item_id)
		FROM order_items
        ) * 100, 2) AS 'ratio by qty',
	   ROUND(SUM(oi.price) / 
       (SELECT SUM(price)
        FROM order_items) * 100, 2) AS 'ratio by sales'
FROM order_items AS oi
JOIN products AS p USING (product_id)
JOIN product_category_name_translation AS pt USING (product_category_name)
JOIN orders AS o USING (order_id)
WHERE pt.product_category_name_english IN ('computers_accessories', 'electronics', 'computers')
AND o.order_status = 'delivered'
GROUP BY category
ORDER BY Total_qty DESC;

SELECT pt.product_category_name_english AS category, COUNT(oi.order_item_id) AS total_qty, ROUND(SUM(oi.price)) as sales,
	   ROUND(COUNT(oi.order_item_id) /
       (SELECT COUNT(order_item_id)
		FROM order_items
        ) * 100, 2) AS 'ratio by qty',
	   ROUND(SUM(oi.price) / 
       (SELECT SUM(price)
        FROM order_items) * 100, 2) AS 'ratio by sales'
FROM order_items AS oi
JOIN products AS p USING (product_id)
JOIN product_category_name_translation AS pt USING (product_category_name)
JOIN orders AS o USING (order_id)
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY Total_qty DESC;


## average price of the products
SELECT pt.product_category_name_english AS category, ROUND(AVG(oi.price),2) As avg_price
FROM order_items AS oi
JOIN products AS p USING (product_id) 
JOIN product_category_name_translation AS pt USING (product_category_name)
JOIN orders AS o USING (order_id)
WHERE pt.product_category_name_english IN ('audio', 'computers_accessories', 'electronics', 'computers')
AND o.order_status = 'delivered'
GROUP BY category
ORDER BY avg_price DESC;

SELECT pt.product_category_name_english AS category, ROUND(AVG(oi.price),2) As avg_price, AVG(oi.freight_value)
FROM order_items AS oi
JOIN products AS p USING (product_id) 
JOIN product_category_name_translation AS pt USING (product_category_name)
JOIN orders AS o USING (order_id)
WHERE pt.product_category_name_english IN ('audio', 'computers_accessories', 'electronics', 'computers')
AND o.order_status = 'delivered'
GROUP BY category
ORDER BY avg_price DESC;

SELECT MAX(price), MIN(price), AVG(price)
FROM order_items;

## Are expensive tech products popular? 
SELECT product_category_name_english, count(*)/(SELECT COUNT(*) FROM order_items) * 100
FROM order_items oi
JOIN products USING (product_id)
JOIN product_category_name_translation USING (product_category_name)
WHERE product_category_name_english IN ('computers_accessories', 'electronics', 'computers', 'pc_gamers')
AND
PRICE > 120.65
GROUP BY product_category_name_english;

SELECT * FROM order_items;

## How many months of data are included in the magist database? 25 months

SELECT *
FROM orders
ORDER BY order_purchase_timestamp;

SELECT
	MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)
FROM orders;

SELECT (TIMESTAMPDIFF(month, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp))) + 1,
TIMESTAMPDIFF(day, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp))
FROM orders;


## How many sellers are there?
SELECT COUNT(*)
FROM sellers;


## How many Tech sellers are there?

SELECT COUNT(DISTINCT seller_id) tech_sellers
FROM order_items oi
JOIN products p USING (product_id)
JOIN product_category_name_translation pt USING (product_category_name)
WHERE pt.product_category_name_english IN ('computers_accessories', 'electronics', 'computers', 'pc_game');


## What percentage of overall sellers are Tech sellers?
SELECT COUNT(DISTINCT seller_id) /
(SELECT COUNT(*) FROM sellers) * 100 AS '%_of_tech_sellers'
FROM order_items oi
JOIN products p USING (product_id)
JOIN product_category_name_translation pt USING (product_category_name)
WHERE pt.product_category_name_english IN ('computers_accessories', 'electronics', 'computers', 'pc_game');


## What is the total amount earned by all sellers? 
SELECT SUM(price)/1000000 total_sales_millions
FROM order_items;

## What is the total amount earned by all Tech sellers?
SELECT SUM(price)/1000000 total_sales_millions
FROM order_items oi
JOIN products p USING (product_id)
JOIN product_category_name_translation pt USING (product_category_name)
WHERE pt.product_category_name_english IN ('computers_accessories', 'electronics', 'computers', 'pc_game');


## Can you work out the average monthly income of all sellers? 
SELECT SUM(price)/26
FROM order_items;

## Can you work out the average monthly income of Tech sellers?
SELECT SUM(price)/26
FROM order_items oi
JOIN products p USING (product_id)
JOIN product_category_name_translation pt USING (product_category_name)
WHERE pt.product_category_name_english IN ('computers_accessories', 'electronics', 'computers', 'pc_game');


## What’s the average time between the order being placed and the product being delivered?
SELECT order_purchase_timestamp, order_delivered_customer_date, timestampdiff(day, order_purchase_timestamp, order_delivered_customer_date)
FROM orders;

SELECT AVG(timestampdiff(day, order_purchase_timestamp, order_delivered_customer_date))
FROM orders;

## How many orders are delivered on time vs orders delivered with a delay? 88649 vs 7827 (
SELECT COUNT(*)
FROM orders
WHERE order_delivered_customer_date <= order_estimated_delivery_date
AND order_delivered_customer_date != NULL;

SELECT COUNT(*)
FROM orders
WHERE order_delivered_customer_date > order_estimated_delivery_date;



## Is there any pattern for delayed orders, e.g. big products being delayed more often?
SELECT *
FROM orders
WHERE order_delivered_customer_date > order_estimated_delivery_date;

SELECT p_eng.product_category_name_english, o.order_status, p.price, p.freight_value, p.product_weight_g
FROM orders o
JOIN order_items oi USING (order_id)
JOIN products p USING (product_id)
JOIN product_category_name_translation p_eng USING (product_category_name)
WHERE order_delivered_customer_date > order_estimated_delivery_date;




