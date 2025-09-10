
WITH base AS (
    SELECT 
        order_id,
        created_at,
        canceled_at,
        CASE 
            WHEN canceled_at IS NOT NULL THEN 1 ELSE 0 
        END AS is_canceled,
        CASE 
            WHEN canceled_at IS NOT NULL 
                 AND (strftime('%s', canceled_at) - strftime('%s', created_at)) > 3600 
            THEN 1 ELSE 0 
        END AS is_violation
    FROM orders
)
SELECT 
    COUNT(*) AS total_orders,
    SUM(is_canceled) AS canceled,
    SUM(is_violation) AS violations,
    ROUND(100.0 * SUM(is_violation) / NULLIF(SUM(is_canceled),0), 2) AS violation_rate_pct
FROM base;
