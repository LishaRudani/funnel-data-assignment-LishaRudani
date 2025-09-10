
WITH cleaned AS (
    SELECT 
        session_id,
        COALESCE(NULLIF(TRIM(detected_intent), ''), 'unknown') AS intent
    FROM messages
),
counts AS (
    SELECT 
        intent,
        COUNT(*) AS cnt
    FROM cleaned
    GROUP BY intent
),
total AS (
    SELECT SUM(cnt) AS total_cnt FROM counts
),
intent_share AS (
    SELECT 
        c.intent,
        c.cnt,
        ROUND(100.0 * c.cnt / t.total_cnt, 2) AS pct_of_total
    FROM counts c, total t
),
purchases AS (
    SELECT DISTINCT session_id
    FROM events
    WHERE event_name = 'Purchase'
),
intent_purchase AS (
    SELECT 
        cl.intent,
        COUNT(DISTINCT cl.session_id) AS purchase_sessions
    FROM cleaned cl
    JOIN purchases p USING (session_id)
    GROUP BY cl.intent
)
SELECT i.intent, i.cnt, i.pct_of_total
FROM intent_share i
ORDER BY i.cnt DESC;

-- Top 2 intents correlated with Purchase
SELECT intent, purchase_sessions
FROM intent_purchase
ORDER BY purchase_sessions DESC
LIMIT 2;
