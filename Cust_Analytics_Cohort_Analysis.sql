-- Cohort Analysis (Customer Retention)
-- Goal: Group Customers by their first purchase month and track how long they keep buying)
-- Get each customer's first order (cohort) and order activity
-- insight: Month 0= first purchase, Month 1,2,3.. = retention

    


WITH first_order AS (
    SELECT 
        CustomerId,
        MIN(DATE(DateCreated)) AS first_order_date
    FROM orders
    GROUP BY CustomerId
),
customer_activity AS (
    SELECT 
		o.customerid as custid,
        MAX(DATE(o.DateCreated)) AS order_date,
        f.first_order_date,
        TIMESTAMPDIFF(MONTH, f.first_order_date, MAX(o.DateCreated)) AS cohort_month
    FROM orders o
    JOIN first_order f ON o.CustomerId = f.CustomerId GROUP BY custid
)
SELECT
	custid,
    DATE_FORMAT(first_order_date, '%Y-%m') AS cohort,
    cohort_month from customer_activity order by cohort_month;

