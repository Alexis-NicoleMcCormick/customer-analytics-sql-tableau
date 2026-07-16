-- RFM Customer Segmentation
-- score customers based on: 
-- R (Recency) → How recently they purchased
-- F (Frequency) → How often they purchase
-- M (Monetary) → How much they spend

-- Build base RFM table
WITH rfm_base AS (
    SELECT 
        c.CustomerID,
        MAX(o.DateCreated) AS last_purchase_date,
        COUNT(DISTINCT o.OrderNumber) AS frequency,
        SUM(b.AmountPaid) AS monetary
    FROM contacts c
    LEFT JOIN orders o ON c.CustomerID = o.CustomerId
    LEFT JOIN billing b ON c.CustomerID = b.CustomerId
    GROUP BY c.CustomerID
)
SELECT 
    CustomerID,
    DATEDIFF(CURDATE(), last_purchase_date) AS recency,
    frequency,
    monetary
FROM rfm_base;

-- Create RFM scores (1-5 scale) using NTILE(5) to rank customers
WITH rfm_base AS (
    SELECT 
        c.CustomerID,
        DATEDIFF(CURDATE(), MAX(o.DateCreated)) AS recency,
        COUNT(DISTINCT o.OrderNumber) AS frequency,
        SUM(b.AmountPaid) AS monetary
    FROM contacts c
    LEFT JOIN orders o ON c.CustomerID = o.CustomerId
    LEFT JOIN billing b ON c.CustomerID = b.CustomerId
    GROUP BY c.CustomerID
),
rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency) AS f_score,
        NTILE(5) OVER (ORDER BY monetary) AS m_score
    FROM rfm_base
)
SELECT *,
    CONCAT(r_score, f_score, m_score) AS rfm_score
FROM rfm_scores;

-- Create Customer Segments
create view Customer_segment as 
WITH rfm_base AS 
(SELECT 
        c.CustomerID,
        DATEDIFF(CURDATE(), MAX(o.DateCreated)) AS recency,
        COUNT(DISTINCT o.OrderNumber) AS frequency,
        SUM(b.AmountPaid) AS monetary
    FROM contacts c
    LEFT JOIN orders o ON c.CustomerID = o.CustomerId
    LEFT JOIN billing b ON c.CustomerID = b.CustomerId
    GROUP BY c.CustomerID
),
rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency) AS f_score,
        NTILE(5) OVER (ORDER BY monetary) AS m_score
    FROM rfm_base
)
SELECT *,
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score = 5 AND f_score <= 2 THEN 'New Customers'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Hibernating'
        ELSE 'Potential Loyalists'
    END AS segment
FROM rfm_scores;
