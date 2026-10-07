select * from customer limit 20

-- q1 . what is the total revenue generated  by male vs female customers??
select gender , SUM(purchase_amount) as revenue
from customer
group by gender 

-- q2 . which customers used a discount but still spent more than the average purchase amount??
select customer_id , purchase_amount
from customer 
where discount_applied = 'Yes' and purchase_amount >= (select AVG(purchase_amount) from customer)

--q3. which are the top 5 products with the highest review rate ?
select item_purchased , AVG(review_rating) as "average product rating"
from customer 
group by item_purchased
order by AVG(review_rating) desc
limit 5 

--q4 compare average purchase amount between standard and  express shiping 
select shipping_type,
ROUND(AVG(purchase_amount),2)
from customer
where shipping_type in ('Standard','Express')
group by shipping_type

-- Q5. Do subscribed customers spend more?
-- Compare average spend and total revenue
-- between subscribers and non-subscribers.

select subscription_status,
COUNT(customer_id) AS total_customers,
ROUND(AVG(purchase_amount), 2) AS avg_spend,
ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue, avg_spend desc;

-- Q6. Which 5 products have the highest percentage of purchases with discounts applied?

SELECT
    item_purchased,
    ROUND(
        100 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

--q7 segment customers into new ,returning ,and loyal based om their 
--total number of previous purchases , and show  the count of each segment 

with customer_type as (select customer_id , previous_purchases,
CASE 
     when previous_purchases = 1 then 'New'
     when previous_purchases Between 2 and 10 then 'returning'
	 else 'loyal'
	 end as customer_segment
from customer 
)

select customer_segment , count(*) as "number of  customers"
from customer_type
group by customer_segment

--q8 what are the top 3 most purchased products within each category?

-- Q8. What are the top 3 most purchased products within each category?

WITH item_counts AS (
    SELECT
        category,
        item_purchased,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY COUNT(customer_id) DESC
        ) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)

SELECT
    item_rank,
    category,
    item_purchased,
    total_orders
FROM item_counts
WHERE item_rank <= 3;

-- Q9. Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe?

SELECT
    subscription_status,
    COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;

-- Q10. What is the revenue contribution of each age group?

SELECT
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;

