WITH monthly_payments AS (
    SELECT
        DATE(DATE_TRUNC('month', payment_date)) AS payment_month,
        user_id,
        SUM(revenue_amount_usd) AS total_revenue
    FROM project.games_payments
    GROUP BY 1, 2
),
settlement_month AS (
    SELECT *,
        LAG(payment_month) OVER (PARTITION BY user_id ORDER BY payment_month) AS previous_paid_month,
        DATE(payment_month + INTERVAL '1 month') AS next_calendar_month,
        LEAD(payment_month) OVER (PARTITION BY user_id ORDER BY payment_month) AS next_paid_month,
        LAG(total_revenue) OVER (PARTITION BY user_id ORDER BY payment_month) AS previous_paid_month_revenue,
        DATE(payment_month - INTERVAL '1 month') AS previous_calendar_month,
        MIN(payment_month) OVER (PARTITION BY user_id) AS first_payment_month,
        MAX(payment_month) OVER (PARTITION BY user_id) AS last_payment_month,
        SUM(total_revenue) OVER (PARTITION BY user_id) AS user_lifetime_revenue
    FROM monthly_payments
)
SELECT
    sm.user_id,
    gpu.game_name,
    gpu.language,
    gpu.age,
    gpu.has_older_device_model,
    sm.payment_month,
    sm.total_revenue,
    sm.previous_paid_month,
    sm.next_calendar_month,
    sm.next_paid_month,
    sm.previous_paid_month_revenue,
    sm.previous_calendar_month,
    CASE
        WHEN next_paid_month IS NULL OR next_paid_month != next_calendar_month
        THEN total_revenue
    END AS churned_revenue,
    CASE
        WHEN next_paid_month IS NULL OR next_paid_month != next_calendar_month
        THEN 1
    END AS churned_users,
    CASE
        WHEN previous_paid_month IS NULL
        THEN total_revenue
    END AS new_mrr,
    CASE
        WHEN previous_paid_month IS NULL
        THEN 1
    END AS new_paid_users,
    CASE
        WHEN next_paid_month IS NULL OR next_paid_month != next_calendar_month
        THEN next_calendar_month
    END AS churn_month,
    CASE
        WHEN previous_paid_month = previous_calendar_month
         AND total_revenue > previous_paid_month_revenue
        THEN total_revenue - previous_paid_month_revenue
    END AS expansion_revenue,
    CASE
        WHEN previous_paid_month = previous_calendar_month
         AND total_revenue < previous_paid_month_revenue
        THEN total_revenue - previous_paid_month_revenue
    END AS contraction_revenue,
    CASE
        WHEN previous_paid_month IS NOT NULL
         AND previous_paid_month != previous_calendar_month
        THEN total_revenue
    END AS back_from_churn_revenue,
    CASE
        WHEN previous_paid_month IS NOT NULL
         AND previous_paid_month != previous_calendar_month
        THEN 1
    END AS back_from_churn_users,
    sm.first_payment_month,
    sm.last_payment_month,
    sm.user_lifetime_revenue, 
    (EXTRACT(YEAR FROM AGE(sm.last_payment_month, sm.first_payment_month)) * 12 +
     EXTRACT(MONTH FROM AGE(sm.last_payment_month, sm.first_payment_month)) + 1) AS user_lifetime_months
FROM settlement_month sm
LEFT JOIN project.games_paid_users gpu
    ON sm.user_id = gpu.user_id;