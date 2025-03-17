create database pizza;

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL
);

CREATE TABLE order_detail (
    order_detail INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id VARCHAR(20) NOT NULL,
    quantity INT NOT NULL
)
-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id)
FROM
    orders;
    
    
-- Calculate the total revenue generated from pizza sales.order_detail
SELECT 
    ROUND(SUM(order_detail.quantity * pizzas.price),
            2) AS total_sale
FROM
    order_detail
        JOIN
    pizzas ON order_detail.pizza_id = pizzas.pizza_id
    
    
    -- Identify the highest-priced pizza
SELECT 
    pizza_types.name, pizzas.price AS price
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY price DESC
LIMIT 1;


--  Identify the most common pizza size ordered.
SELECT 
    pizzas.size AS size,
    COUNT(order_detail.quantity) AS count_order
FROM
    pizzas
        JOIN
    order_detail ON pizzas.pizza_id = order_detail.pizza_id
GROUP BY size
ORDER BY count_order DESC;


-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name AS name,
    COUNT(order_detail.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_detail ON order_detail.pizza_id = pizzas.pizza_id
GROUP BY name
ORDER BY quantity DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category AS category,
    SUM(order_detail.quantity) AS quantity
FROM
    order_detail
        JOIN
    pizzas ON order_detail.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY category
ORDER BY quantity DESC;


-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hours;


-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hours;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(sum_quan), 1) as avg_pizza_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_detail.quantity) AS sum_quan
    FROM
        orders
    JOIN order_detail ON orders.order_id = order_detail.order_id
    GROUP BY orders.order_date) AS quantity_count;
    
    
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name AS nam,
    SUM(order_detail.quantity * p.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas p ON pizza_types.pizza_type_id = p.pizza_type_id
        JOIN
    order_detail ON order_detail.pizza_id = p.pizza_id
GROUP BY nam
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category AS category,
    ROUND(SUM(order_detail.quantity * p.price) / (SELECT 
                    SUM(order_detail.quantity * p2.price)
                FROM
                    order_detail
                        JOIN
                    pizzas p2 ON order_detail.pizza_id = p2.pizza_id) * 100,
            2) AS revenue_percentage
FROM
    pizza_types
        JOIN
    pizzas p ON pizza_types.pizza_type_id = p.pizza_type_id
        JOIN
    order_detail ON order_detail.pizza_id = p.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue_percentage DESC;


-- Analyze the cumulative revenue generated over time.
select dates,
sum(revenue) over(order by dates) as cum_sum
	from 
(SELECT 
    orders.order_date AS dates, 
    SUM(order_detail.quantity * pizzas.price) AS revenue
FROM 
    orders
JOIN 
    order_detail ON orders.order_id = order_detail.order_id
JOIN 
    pizzas ON order_detail.pizza_id = pizzas.pizza_id
GROUP BY 
    dates
ORDER BY 
    revenue asc) as sales ;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT 
    name,
    revenue
FROM (
    SELECT 
        category,
        name,
        revenue,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM (
        SELECT 
            pizza_types.category AS category,
            pizza_types.name AS name,
            SUM(pizzas.price * order_details.quantity) AS revenue
        FROM 
            pizza_types
        JOIN 
            pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN 
            order_details ON order_details.pizza_id = pizzas.pizza_id
        GROUP BY 
            category, name
    ) AS a
) AS b
WHERE 
    rn <= 3;
