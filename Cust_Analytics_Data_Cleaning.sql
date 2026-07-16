Use El_Diesel;
-- Exploring contacts table
select * from contacts;
-- Number of customers
select count(*) from contacts;
-- 
select distinct(shippingcity) from contacts;
select distinct(shippingState) from contacts;

select distinct(billingcity) from contacts;
select distinct (billingState) from contacts;


-- number of customers by state/city
select billingState AS state,
count(customerID) as total_customers
from contacts
Group By billingState
Order By total_customers desc;

select billingcity AS city,
count(customerID) as total_customers
from contacts
Group By billingcity
Order By total_customers desc;

select billingzip AS zip,
count(customerID) as total_customers
from contacts
Group By billingzip
Order By total_customers desc;

-- which customers ordered the most products
select customerId, count( distinct(OrderNumber)) as orders from orders group by customerId order by orders desc;

-- Customer Overview (Who are your Customers)
-- Total Customers and Subscriber Breakdown
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN EmailSubscriber = 'Subscribed' THEN 1 ELSE 0 END) AS EmailSubscribers,
    SUM(CASE WHEN SMSSubscriber = 'Subscribed' THEN 1 ELSE 0 END) AS SMSSubscribers
FROM contacts;

-- Customers by source (insight:  Which acquisition channel brings the most users)
SELECT CustSource, COUNT(*) AS total_customers
FROM contacts
GROUP BY CustSource
ORDER BY total_customers DESC;
-- number of new vs returning customers
-- Repeat vs New Customers

create view cust_type as 
(select  customerID, count(distinct(orderNumber)) as order_count,
    CASE 
        WHEN count(distinct(orderNumber)) = 1 THEN 'New'
        ELSE 'Returning'
    END AS customer_type
    FROM orders
GROUP BY customerId);

-- Customer Segmentation

SELECT 
    CASE 
        WHEN order_count = 1 THEN 'New'
        ELSE 'Returning'
    END AS customer_type,
    COUNT(*) AS num_customers
FROM (
    SELECT 
        CustomerID,
        COUNT(DISTINCT OrderNumber) AS order_count
    FROM orders
    GROUP BY CustomerID
) t
GROUP BY customer_type;

-- Product Performance
-- Top Selling Products


-- top 10 products by revenue
select item, sum(price*qty) as revenue from orders
Group by item
Order by revenue desc
limit 10;

-- top 5 popular products
select item, sum(qty) as quantity from orders Group By item Order By quantity desc limit 5;

-- bottom 5 products by revenue
select item, sum(price*qty) as revenue from orders Group By item Order By revenue limit 5;

-- 5 least popular products
select item, sum(qty) as quantity from orders Group By item Order By quantity limit 10;

-- which items are getting refunded
select item, sum(quantityrefunded) as refunds from orders
where quantityrefunded >0
Group by item
order by refunds desc;

-- how many refunds
select sum(quantityrefunded) as refunds from orders
where quantityrefunded >0;


-- loss from refunds
select sum(price * quantityrefunded) as loss from orders;

-- item loss
select item, sum(price * quantityrefunded) as loss from orders
where quantityrefunded >0
GROUP BY item
Order by loss desc;

-- top 10 customers by revenue
 
select CustomerID, CONCAT(FirstName, " ", LastName) as cust_name, sum(AmountPaid) as revenue
 from billing
 Group by customerID, cust_name
 Order By revenue desc
 limit 10;
select * from billing limit 10;

-- top 10 customers by quantity ordered
select firstname, lastname, (count(orderid) * sum(qty)) as quantity from orders 
join contacts on contacts.customerid = orders.customerid
Group By firstname, lastname
Order By quantity desc
limit 10;

-- Top 10 customers by number of orders placed
select firstname, lastname, count(distinct(orderNumber)) as orders from orders 
join contacts on contacts.customerid = orders.customerid
Group By firstname, lastname
Order By orders desc
limit 10;


-- revenue by city

select billingcity as city, sum(amountPaid) as revenue from billing 
group by city
order by revenue desc;

-- Revenue Trends over time (insights: Growth Trends)
SELECT 
    DATE(o.DateCreated) AS order_date,
    SUM(b.AmountPaid) AS daily_revenue
FROM orders o
JOIN billing b ON o.CustomerId = b.CustomerId
GROUP BY order_date
ORDER BY order_date;

-- Customer Lifetime Value (LTV) 
-- How much revenue a customer generates over time
Create view cust_LTV AS 
(SELECT 
    c.CustomerID AS cust_id,
    CONCAT(c.FirstName, ' ', c.LastName) AS customer_name,
    COUNT(DISTINCT o.OrderNumber) AS total_orders,
    SUM(b.AmountPaid) AS total_revenue,
    AVG(b.AmountPaid) AS avg_order_value
FROM contacts c
JOIN orders o ON c.CustomerID = o.CustomerId
JOIN billing b ON c.CustomerID = b.CustomerId
GROUP BY c.CustomerID
ORDER BY total_revenue DESC);

-- LTV by acquisition source (which channels bring high value customers? Where should the business invest?)
Create view LTV_acquisition AS 
SELECT 
    c.CustSource,
    COUNT(DISTINCT c.CustomerID) AS customers,
    SUM(b.AmountPaid) AS total_revenue,
    AVG(b.AmountPaid) AS avg_order_value,
    SUM(b.AmountPaid) / COUNT(DISTINCT c.CustomerID) AS avg_ltv
FROM contacts c
JOIN billing b ON c.CustomerID = b.CustomerId
GROUP BY c.CustSource
ORDER BY avg_ltv DESC;
-- Repeat vs One-time customers (insights: Customer retention)
create view CustomerType as(
SELECT 
    CASE 
        WHEN total_orders = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM (
    SELECT CustomerId, COUNT(Distinct(orderNumber)) AS total_orders
    FROM orders
    GROUP BY CustomerId
) t
GROUP BY customer_type);


-- Refund and Payment Analysis
SELECT 
    SUM(RefundedAmount) AS total_refunded,
    SUM(AmountPaid) AS total_paid,
    (SUM(RefundedAmount) / SUM(AmountPaid)) * 100 AS refund_rate_pct
FROM billing;


-- Payment Method Distribution (insight: preferred payment types)
SELECT 
    PaymentMethod,
    COUNT(*) AS total_orders,
    SUM(AmountPaid) AS revenue
FROM billing
GROUP BY PaymentMethod
ORDER BY revenue DESC;

-- Geographic Insights (insight: Best performing regions)
-- Revenue By State
SELECT 
    BillingState,
    SUM(AmountPaid) AS revenue
FROM billing
GROUP BY BillingState
ORDER BY revenue DESC;

-- Top Cities
SELECT 
    BillingCity,
    SUM(AmountPaid) AS revenue
FROM billing
GROUP BY BillingCity
ORDER BY revenue DESC
LIMIT 10;

-- Fulfillment and Operations
-- Fulfillment status breakdown

SELECT 
    FulfillmentStatus,
    COUNT(*) AS totalorders
FROM billing
GROUP BY FulfillmentStatus;