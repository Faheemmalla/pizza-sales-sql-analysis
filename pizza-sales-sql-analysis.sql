-- percentage contribution of each pizza type to total revenue
SELECT 
    pt.name,
    SUM(od.quantity * p.price) AS revenue,
    ROUND(
        (SUM(od.quantity * p.price) / 
        (SELECT SUM(od2.quantity * p2.price)
         FROM order_details od2
         JOIN pizzas p2 
            ON od2.pizza_id = p2.pizza_id)
        ) * 100, 2
    ) AS revenue_percentage
FROM order_details od
JOIN pizzas p 
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC;

-- cumulative revenue generated over time
SELECT 
    order_date,
    SUM(daily_revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT 
        o.order_date,
        SUM(od.quantity * p.price) AS daily_revenue
    FROM orders o
    JOIN order_details od 
        ON o.order_id = od.order_id
    JOIN pizzas p 
        ON od.pizza_id = p.pizza_id
    GROUP BY o.order_date
) AS daily_sales
ORDER BY order_date;

-- top 3 most ordered pizza types based on revenue for each pizza category

SELECT *
FROM (
    SELECT 
        pt.category,
        pt.name,
        SUM(od.quantity * p.price) AS revenue,
        RANK() OVER (
            PARTITION BY pt.category 
            ORDER BY SUM(od.quantity * p.price) DESC
        ) AS rank_in_category
    FROM order_details od
    JOIN pizzas p 
        ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt 
        ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) ranked_pizzas
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category;