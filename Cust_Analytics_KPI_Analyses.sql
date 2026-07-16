Use El_Diesel;

-- KPI Analyses

-- Total customers
select count(Customerid) from contacts;

-- how many of these actually placed an order since May 2025
select count(distinct (customerId)) from orders;


-- Total Orders
select count(distinct(orderNumber)) from orders;

-- Avg Order Value (AOV)
SELECT 
    AVG(AmountPaid) AS avg_order_value
FROM billing;


-- Total Revenue
select sum(revenue) as total_revenue from
(select sum((qty-quantityrefunded)*price) Revenue from orders UNION
select sum(amountpaid) from billing where invoiceSource= "SquareSpace")t;




-- Avg Customer Lifetime value
select avg(amountpaid) from billing;

-- Average LTV across all customers

Create View Avg_LTV AS 
SELECT 
    AVG(customer_ltv) AS avg_ltv
FROM (
    SELECT 
        CustomerId,
        SUM(AmountPaid) AS customer_ltv
    FROM billing
    GROUP BY CustomerId
) t;


-- Total Products
select count(distinct(item)) from orders;

-- Total Products Sold
select count(orderid) from orders;
select count(item) from orders;

-- Avg Number of Orders per Customer
select avg(order_qty) from
(select customerid, count(distinct(orderNumber)) As order_qty from orders Group By Customerid)t;

-- Avg Number of Products Purchased
select avg(tot_products) from
(Select customerid, count(orderid) as tot_products from orders Group by customerid)T;

-- Total Refunds
select sum(quantityrefunded) from orders;

-- Loss From Refunds
select sum(quantityrefunded * price) from orders;


-- Refund Rate by Number of Transactions
select *, (refunds/transactions)* 100 as refund_rate from
(select sum(quantityrefunded) as refunds, count(orderid) as transactions from orders)t;


