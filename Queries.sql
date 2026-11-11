-- SECTION A: SQL FUNDAMENTALS

-- Q1. Retrieve all customer records.
SELECT *
FROM customers;

-- Q2. Display customer names, cities, and segments.
SELECT customer_name, city, customer_segment
FROM customers;

--Q3. Find customers living in Nairobi.
SELECT *
FROM customers
WHERE city = 'Nairobi';

--Q4.Find customers registered after January 1, 2025.
SELECT *
FROM customers
WHERE registration_date > '2025-01-01';

--Q5. Display all unique customer cities.
SELECT DISTINCT city
FROM customers;

--Q6.Retrieve the 10 most recent orders.
SELECT *
FROM orders
ORDER BY order_date DESC
LIMIT 10;

--Q7. Find orders with unit prices above KSh 10,000.
SELECT *
FROM orders
WHERE unit_price > 10000;

--Q8. Find customers whose names start with A.
SELECT *
FROM orders
WHERE unit_price > 10000;

--Q9. Retrieve orders with quantities between 2 and 5.
SELECT *
FROM orders
WHERE quantity BETWEEN 2 AND 5;

--Q10. Q10. Find orders paid through M-Pesa.
SELECT *
FROM orders
WHERE payment_method = 'M-Pesa';

---SECTION B – Aggregation and Grouping (Q11–Q20)

--Q11. Count all customers.
SELECT COUNT(*) AS total_customers
FROM customers;

--Q12. Count all orders.
SELECT COUNT(*) AS total_orders
FROM orders;

--Q13. Calculate completed-order revenue.
SELECT
    SUM(quantity * unit_price * (1 - discount / 100)) AS total_revenue
FROM orders
WHERE order_status = 'Completed';

--Q14. Calculate the average completed-order value
SELECT
    AVG(quantity * unit_price * (1 - discount / 100)) AS average_order_value
FROM orders
WHERE order_status = 'Completed';

--Q15. Find the highest and lowest product prices.
SELECT
    MAX(unit_price) AS highest_price,
    MIN(unit_price) AS lowest_price
FROM orders;

--Q16. Calculate revenue by product category.
SELECT
    product_category,
    SUM(quantity * unit_price * (1 - discount / 100)) AS total_revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
ORDER BY total_revenue DESC;

--Q17. Count customers by city.
SELECT
    city,
    COUNT(*) AS total_customers
FROM customers
GROUP BY city
ORDER BY total_customers DESC;

--Q18. Calculate quantity sold by product.
SELECT
    product_name,
    SUM(quantity) AS total_quantity_sold
FROM orders
GROUP BY product_name
ORDER BY total_quantity_sold DESC;

--Q19. Find categories generating more than KSh 100,000 in revenue.
SELECT
    product_category,
    SUM(quantity * unit_price * (1 - discount / 100)) AS total_revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
HAVING SUM(quantity * unit_price * (1 - discount / 100)) > 100000;

--Q20. Calculate the percentage of cancelled orders.
SELECT
    COUNT(*) FILTER (WHERE order_status = 'Cancelled') * 100.0
    / COUNT(*) AS cancelled_percentage
FROM orders;

---Section C — Joins and customer analytics (Q21–Q28)

-- Q21. Display orders with customer names and cities.

SELECT
    orders.order_id,
    customers.customer_name,
    customers.city,
    orders.product_name,
    orders.quantity,
    orders.order_date
FROM orders
INNER JOIN customers
    ON orders.customer_id = customers.customer_id;


-- Q22. Calculate total spending by customer.

SELECT
    customers.customer_id,
    customers.customer_name,
    SUM(orders.quantity * orders.unit_price * (1 - orders.discount / 100)) AS total_spending
FROM customers
INNER JOIN orders
    ON customers.customer_id = orders.customer_id
WHERE orders.order_status = 'Completed'
GROUP BY customers.customer_id, customers.customer_name
ORDER BY total_spending DESC;

-- Q21 Display orders with customer names and cities.
SELECT
    orders.order_id,
    customers.customer_name,
    customers.city,
    orders.product_name,
    orders.quantity,
    orders.order_date
FROM customers
INNER JOIN orders
    ON customers.customer_id = orders.customer_id;

--Q22. Calculate total spending by customer.

SELECT
    customers.customer_id,
    customers.customer_name,
    SUM(orders.quantity * orders.unit_price * (1 - orders.discount / 100.0)) AS total_spending
FROM customers
INNER JOIN orders
    ON customers.customer_id = orders.customer_id
WHERE orders.order_status = 'Completed'
GROUP BY customers.customer_id, customers.customer_name
ORDER BY total_spending DESC;

--Q23. Identify customers who have never ordered.

SELECT
    customers.customer_id,
    customers.customer_name,
    customers.city
FROM customers
LEFT JOIN orders
    ON customers.customer_id = orders.customer_id
WHERE orders.order_id IS NULL;

--Q24. Find the 10 highest-spending customers.

SELECT
    customers.customer_id,
    customers.customer_name,
    SUM(orders.quantity * orders.unit_price * (1 - orders.discount / 100.0)) AS total_spending
FROM customers
INNER JOIN orders
    ON customers.customer_id = orders.customer_id
WHERE orders.order_status = 'Completed'
GROUP BY customers.customer_id, customers.customer_name
ORDER BY total_spending DESC
LIMIT 10;

--Q25. Calculate revenue by customer city.

SELECT
    customers.city,
    SUM(orders.quantity * orders.unit_price * (1 - orders.discount / 100.0)) AS total_revenue
FROM customers
INNER JOIN orders
    ON customers.customer_id = orders.customer_id
WHERE orders.order_status = 'Completed'
GROUP BY customers.city
ORDER BY total_revenue DESC;

--Q26. Identify customers with more than five orders.

SELECT
    customers.customer_id,
    customers.customer_name,
    COUNT(orders.order_id) AS total_orders
FROM customers
INNER JOIN orders
    ON customers.customer_id = orders.customer_id
GROUP BY customers.customer_id, customers.customer_name
HAVING COUNT(orders.order_id) > 5
ORDER BY total_orders DESC;

--Q27. Calculate average customer spending by segment

SELECT
    customers.customer_segment,
    AVG(customer_spending.total_spending) AS average_customer_spending
FROM customers
INNER JOIN (
    SELECT
        customer_id,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_spending
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
) AS customer_spending
    ON customers.customer_id = customer_spending.customer_id
GROUP BY customers.customer_segment
ORDER BY average_customer_spending DESC;

--Q28. Identify the most popular category among VIP customers.

SELECT
    orders.product_category,
    SUM(orders.quantity) AS total_quantity_sold
FROM customers
INNER JOIN orders
    ON customers.customer_id = orders.customer_id
WHERE customers.customer_segment = 'VIP'
GROUP BY orders.product_category
ORDER BY total_quantity_sold DESC
LIMIT 1;

--Q29. Find customers spending above the average total spending per purchasing customer.

WITH customer_spending AS (
    SELECT
        customer_id,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_spending
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT
    customers.customer_id,
    customers.customer_name,
    customer_spending.total_spending
FROM customers
INNER JOIN customer_spending
    ON customers.customer_id = customer_spending.customer_id
WHERE customer_spending.total_spending > (
    SELECT AVG(total_spending)
    FROM customer_spending
)
ORDER BY customer_spending.total_spending DESC;

--Q30. Find products priced above the overall average unit price

SELECT
    product_name,
    unit_price
FROM orders
WHERE unit_price > (
    SELECT AVG(unit_price)
    FROM orders
)
GROUP BY product_name, unit_price
ORDER BY unit_price DESC;

--Q31. Use a CTE to identify the three highest-revenue months.

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) AS sales_month,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    sales_month,
    total_revenue
FROM monthly_revenue
ORDER BY total_revenue DESC
LIMIT 3;

--Q32. Find customers purchasing from at least three categories.

SELECT
    customers.customer_id,
    customers.customer_name,
    COUNT(DISTINCT orders.product_category) AS categories_purchased
FROM customers
INNER JOIN orders
    ON customers.customer_id = orders.customer_id
WHERE orders.order_status = 'Completed'
GROUP BY customers.customer_id, customers.customer_name
HAVING COUNT(DISTINCT orders.product_category) >= 3
ORDER BY categories_purchased DESC;

--Q33. Use a CTE to calculate category revenue, cost, profit and profit margin.

WITH category_performance AS (
    SELECT
        product_category,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS revenue,
        SUM(quantity * cost_price) AS total_cost
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category
)
SELECT
    product_category,
    revenue,
    total_cost,
    revenue - total_cost AS profit,
    (revenue - total_cost) / NULLIF(revenue, 0) * 100 AS profit_margin
FROM category_performance
ORDER BY profit DESC;

--Q34. Find customers whose latest completed order is more than 90 days before the latest order date in the dataset.

SELECT
    customers.customer_id,
    customers.customer_name,
    MAX(orders.order_date) AS latest_completed_order
FROM customers
INNER JOIN orders
    ON customers.customer_id = orders.customer_id
WHERE orders.order_status = 'Completed'
GROUP BY customers.customer_id, customers.customer_name
HAVING MAX(orders.order_date) < (
    SELECT MAX(order_date) - INTERVAL '90 days'
    FROM orders
)
ORDER BY latest_completed_order;

---SECTION E — WINDOW FUNCTIONS (Q35–Q42)

--Q35. Rank customers by spending using RANK().

WITH customer_spending AS (
    SELECT
        customer_id,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_spending
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT
    customers.customer_name,
    customer_spending.total_spending,
    RANK() OVER (ORDER BY customer_spending.total_spending DESC) AS spending_rank
FROM customers
INNER JOIN customer_spending
    ON customers.customer_id = customer_spending.customer_id;

--Q36. Number each customer's orders by recency using ROW_NUMBER().

SELECT
    customer_id,
    order_id,
    order_date,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY order_date DESC
    ) AS order_number
FROM orders;

--Q37. Rank products within categories using DENSE_RANK().

WITH product_revenue AS (
    SELECT
        product_category,
        product_name,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category, product_name
)
SELECT
    product_category,
    product_name,
    total_revenue,
    DENSE_RANK() OVER (
        PARTITION BY product_category
        ORDER BY total_revenue DESC
    ) AS product_rank
FROM product_revenue;

--Q38. Calculate cumulative monthly revenue

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) AS sales_month,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    sales_month,
    total_revenue,
    SUM(total_revenue) OVER (
        ORDER BY sales_month
    ) AS cumulative_revenue
FROM monthly_revenue;

--Q39. Compare monthly revenue using LAG().

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) AS sales_month,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    sales_month,
    total_revenue,
    LAG(total_revenue) OVER (
        ORDER BY sales_month
    ) AS previous_month_revenue
FROM monthly_revenue;

--Q40. Calculate month-over-month revenue growth (%).

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) AS sales_month,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', order_date)
),
revenue_comparison AS (
    SELECT
        sales_month,
        total_revenue,
        LAG(total_revenue) OVER (ORDER BY sales_month) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    sales_month,
    total_revenue,
    previous_month_revenue,
    (total_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0) * 100 AS growth_percentage
FROM revenue_comparison;

--Q41. Divide customers into four spending groups using NTILE(4).

WITH customer_spending AS (
    SELECT
        customer_id,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_spending
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT
    customers.customer_name,
    customer_spending.total_spending,
    NTILE(4) OVER (
        ORDER BY customer_spending.total_spending DESC
    ) AS spending_group
FROM customers
INNER JOIN customer_spending
    ON customers.customer_id = customer_spending.customer_id;

--Q42. Calculate each category's share of total revenue using window functions.

WITH category_revenue AS (
    SELECT
        product_category,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category
)
SELECT
    product_category,
    total_revenue,
    total_revenue * 100.0
        / SUM(total_revenue) OVER () AS revenue_percentage
FROM category_revenue
ORDER BY revenue_percentage DESC;

--Q43. Create a monthly_sales_summary view, then select from it.

CREATE OR REPLACE VIEW monthly_sales_summary AS
SELECT
    DATE_TRUNC('month', order_date) AS month,
    COUNT(*) AS orders,
    SUM(
        CASE WHEN order_status = 'Completed'
        THEN quantity * unit_price * (1 - discount / 100.0)
        ELSE 0 END
    ) AS revenue,
    SUM(
        CASE WHEN order_status = 'Completed'
        THEN quantity * cost_price
        ELSE 0 END
    ) AS cost,
    SUM(
        CASE WHEN order_status = 'Completed'
        THEN quantity * unit_price * (1 - discount / 100.0) - quantity * cost_price
        ELSE 0 END
    ) AS profit
FROM orders
GROUP BY DATE_TRUNC('month', order_date);

SELECT *
FROM public.monthly_sales_summary
ORDER BY month;

-- Q44. Create a function to calculate a customer's completed-order revenue.

CREATE OR REPLACE FUNCTION customer_completed_revenue(p_customer_id INT)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    total_revenue NUMERIC;
BEGIN
    SELECT COALESCE(
        SUM(quantity * unit_price * (1 - discount / 100.0)),
        0
    )
    INTO total_revenue
    FROM orders
    WHERE customer_id = p_customer_id
      AND order_status = 'Completed';

    RETURN total_revenue;
END;
$$;

-- Test the function
SELECT customer_completed_revenue(1);

SELECT customer_completed_revenue(9999);

SELECT
    customer_id,
    order_status,
    COUNT(*) AS total_orders
FROM orders
WHERE customer_id = 1
GROUP BY customer_id, order_status;

SELECT
    order_id,
    quantity,
    unit_price,
    discount,
    quantity * unit_price * (1 - discount / 100.0) AS order_revenue
FROM orders
WHERE customer_id = 1
  AND order_status = 'Completed';

SELECT
    SUM(quantity * unit_price * (1 - discount / 100.0)) AS expected_revenue
FROM orders
WHERE customer_id = 1
  AND order_status = 'Completed';

SELECT customer_completed_revenue(1);

--Q45  Segment customers into High, Medium and Low Value
WITH customer_spending AS (
    SELECT
        customer_id,
        SUM(quantity * unit_price * (1 - discount / 100.0)) AS total_spending
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT
    customers.customer_id,
    customers.customer_name,
    COALESCE(customer_spending.total_spending, 0) AS total_spending,
    CASE
        WHEN COALESCE(customer_spending.total_spending, 0) >= 100000
            THEN 'High Value'
        WHEN COALESCE(customer_spending.total_spending, 0) >= 50000
            THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_value_segment
FROM customers
LEFT JOIN customer_spending
    ON customers.customer_id = customer_spending.customer_id
ORDER BY COALESCE(customer_spending.total_spending, 0) DESC;

-- Q46(a): Top five customers by spending
SELECT
    customers.customer_id,
    customers.customer_name,
    SUM(orders.quantity * orders.unit_price *
        (1 - orders.discount / 100.0)) AS total_spending
FROM customers
INNER JOIN orders
    ON customers.customer_id = orders.customer_id
WHERE orders.order_status = 'Completed'
GROUP BY customers.customer_id, customers.customer_name
ORDER BY total_spending DESC
LIMIT 5;

-- Q46(b): Top five products by revenue
SELECT
    product_name,
    SUM(quantity) AS total_quantity_sold,
    SUM(quantity * unit_price *
        (1 - discount / 100.0)) AS total_revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Q46(c): Most profitable category
SELECT
    product_category,
    SUM(quantity * unit_price *
        (1 - discount / 100.0))
        - SUM(quantity * cost_price) AS total_profit
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
ORDER BY total_profit DESC
LIMIT 1;

-- Q46(d): Lowest-revenue month
SELECT
    DATE_TRUNC('month', order_date) AS sales_month,
    SUM(quantity * unit_price *
        (1 - discount / 100.0)) AS total_revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY total_revenue ASC
LIMIT 1;




