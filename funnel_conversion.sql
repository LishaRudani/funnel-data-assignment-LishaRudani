
WITH base AS (
    SELECT DISTINCT user_id, device, event_name
    FROM events
),
funnel AS (
    SELECT 
        device,
        event_name AS step,
        COUNT(DISTINCT user_id) AS users
    FROM base
    WHERE event_name IN ('Loaded', 'Interact', 'Clicks', 'Purchase')
    GROUP BY device, event_name
),
ordered AS (
    SELECT 
        device,
        step,
        users,
        ROW_NUMBER() OVER (PARTITION BY device ORDER BY 
            CASE step 
                WHEN 'Loaded' THEN 1 
                WHEN 'Interact' THEN 2 
                WHEN 'Clicks' THEN 3 
                WHEN 'Purchase' THEN 4 
            END) AS step_order
    FROM funnel
),
calc AS (
    SELECT 
        o.device,
        o.step,
        o.users,
        ROUND(100.0 * o.users / FIRST_VALUE(o.users) OVER (PARTITION BY o.device ORDER BY step_order), 2) AS conv_from_start_pct,
        ROUND(100.0 * o.users / LAG(o.users) OVER (PARTITION BY o.device ORDER BY step_order), 2) AS conv_from_prev_pct
    FROM ordered o
)
SELECT step, users, conv_from_prev_pct, conv_from_start_pct, device
FROM calc
ORDER BY device, step_order;
