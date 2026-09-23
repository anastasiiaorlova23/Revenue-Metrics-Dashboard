INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('06RPvlsFPCmM9ag+iSM/Ag==','game 3','ru',34,false,'2022-04-01',12.03,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,12.03,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-11-01',227.79,8),
	 ('06RPvlsFPCmM9ag+iSM/Ag==','game 3','ru',34,false,'2022-05-01',28.32,'2022-04-01','2022-06-01','2022-06-01',12.03,'2022-04-01',NULL,NULL,NULL,NULL,NULL,16.29,NULL,NULL,NULL,'2022-04-01','2022-11-01',227.79,8),
	 ('06RPvlsFPCmM9ag+iSM/Ag==','game 3','ru',34,false,'2022-06-01',29.07,'2022-05-01','2022-07-01','2022-07-01',28.32,'2022-05-01',NULL,NULL,NULL,NULL,NULL,0.75,NULL,NULL,NULL,'2022-04-01','2022-11-01',227.79,8),
	 ('06RPvlsFPCmM9ag+iSM/Ag==','game 3','ru',34,false,'2022-07-01',25.23,'2022-06-01','2022-08-01','2022-08-01',29.07,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-3.84,NULL,NULL,'2022-04-01','2022-11-01',227.79,8),
	 ('06RPvlsFPCmM9ag+iSM/Ag==','game 3','ru',34,false,'2022-08-01',18.9,'2022-07-01','2022-09-01','2022-09-01',25.23,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-6.33,NULL,NULL,'2022-04-01','2022-11-01',227.79,8),
	 ('06RPvlsFPCmM9ag+iSM/Ag==','game 3','ru',34,false,'2022-09-01',48.72,'2022-08-01','2022-10-01','2022-10-01',18.9,'2022-08-01',NULL,NULL,NULL,NULL,NULL,29.82,NULL,NULL,NULL,'2022-04-01','2022-11-01',227.79,8),
	 ('06RPvlsFPCmM9ag+iSM/Ag==','game 3','ru',34,false,'2022-10-01',25.74,'2022-09-01','2022-11-01','2022-11-01',48.72,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-22.98,NULL,NULL,'2022-04-01','2022-11-01',227.79,8),
	 ('06RPvlsFPCmM9ag+iSM/Ag==','game 3','ru',34,false,'2022-11-01',39.78,'2022-10-01','2022-12-01',NULL,25.74,'2022-10-01',39.78,1,NULL,NULL,'2022-12-01',14.04,NULL,NULL,NULL,'2022-04-01','2022-11-01',227.79,8),
	 ('0A5RkQrm+GBgG7KSFk/xhw==','game 3','uk',31,false,'2022-05-01',13.8,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,13.8,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-11-01',299.76,7),
	 ('0A5RkQrm+GBgG7KSFk/xhw==','game 3','uk',31,false,'2022-06-01',48.21,'2022-05-01','2022-07-01','2022-07-01',13.8,'2022-05-01',NULL,NULL,NULL,NULL,NULL,34.41,NULL,NULL,NULL,'2022-05-01','2022-11-01',299.76,7);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('0A5RkQrm+GBgG7KSFk/xhw==','game 3','uk',31,false,'2022-07-01',52.77,'2022-06-01','2022-08-01','2022-08-01',48.21,'2022-06-01',NULL,NULL,NULL,NULL,NULL,4.56,NULL,NULL,NULL,'2022-05-01','2022-11-01',299.76,7),
	 ('0A5RkQrm+GBgG7KSFk/xhw==','game 3','uk',31,false,'2022-08-01',40.83,'2022-07-01','2022-09-01','2022-09-01',52.77,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-11.94,NULL,NULL,'2022-05-01','2022-11-01',299.76,7),
	 ('0A5RkQrm+GBgG7KSFk/xhw==','game 3','uk',31,false,'2022-09-01',35.49,'2022-08-01','2022-10-01','2022-10-01',40.83,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-5.34,NULL,NULL,'2022-05-01','2022-11-01',299.76,7),
	 ('0A5RkQrm+GBgG7KSFk/xhw==','game 3','uk',31,false,'2022-10-01',35.73,'2022-09-01','2022-11-01','2022-11-01',35.49,'2022-09-01',NULL,NULL,NULL,NULL,NULL,0.24,NULL,NULL,NULL,'2022-05-01','2022-11-01',299.76,7),
	 ('0A5RkQrm+GBgG7KSFk/xhw==','game 3','uk',31,false,'2022-11-01',72.93,'2022-10-01','2022-12-01',NULL,35.73,'2022-10-01',72.93,1,NULL,NULL,'2022-12-01',37.20,NULL,NULL,NULL,'2022-05-01','2022-11-01',299.76,7),
	 ('0afix9qVNfU3GJY1n0QGkw==','game 3','uk',25,false,'2022-09-01',32.28,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,32.28,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-10-01',45.51,2),
	 ('0afix9qVNfU3GJY1n0QGkw==','game 3','uk',25,false,'2022-10-01',13.23,'2022-09-01','2022-11-01',NULL,32.28,'2022-09-01',13.23,1,NULL,NULL,'2022-11-01',NULL,-19.05,NULL,NULL,'2022-09-01','2022-10-01',45.51,2),
	 ('0dJXy70SFjxVR6YgOPZzMQ==','game 3','uk',27,false,'2022-11-01',17.19,NULL,'2022-12-01',NULL,NULL,'2022-10-01',17.19,1,17.19,1,'2022-12-01',NULL,NULL,NULL,NULL,'2022-11-01','2022-11-01',17.19,1),
	 ('14RMzQMoG017OLkaDBFjng==','game 3','uk',36,false,'2022-07-01',14.43,NULL,'2022-08-01','2022-11-01',NULL,'2022-06-01',14.43,1,14.43,1,'2022-08-01',NULL,NULL,NULL,NULL,'2022-07-01','2022-11-01',27.18,5),
	 ('14RMzQMoG017OLkaDBFjng==','game 3','uk',36,false,'2022-11-01',12.75,'2022-07-01','2022-12-01',NULL,14.43,'2022-10-01',12.75,1,NULL,NULL,'2022-12-01',NULL,NULL,12.75,1,'2022-07-01','2022-11-01',27.18,5);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('1BBMagZRq/39AV1l2rm4Iw==','game 3','ru',23,false,'2022-08-01',89.04,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,89.04,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-11-01',327.78,4),
	 ('1BBMagZRq/39AV1l2rm4Iw==','game 3','ru',23,false,'2022-09-01',34.8,'2022-08-01','2022-10-01','2022-10-01',89.04,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-54.24,NULL,NULL,'2022-08-01','2022-11-01',327.78,4),
	 ('1BBMagZRq/39AV1l2rm4Iw==','game 3','ru',23,false,'2022-10-01',55.80,'2022-09-01','2022-11-01','2022-11-01',34.8,'2022-09-01',NULL,NULL,NULL,NULL,NULL,21.00,NULL,NULL,NULL,'2022-08-01','2022-11-01',327.78,4),
	 ('1BBMagZRq/39AV1l2rm4Iw==','game 3','ru',23,false,'2022-11-01',148.14,'2022-10-01','2022-12-01',NULL,55.80,'2022-10-01',148.14,1,NULL,NULL,'2022-12-01',92.34,NULL,NULL,NULL,'2022-08-01','2022-11-01',327.78,4),
	 ('1dvc3uv3gFy83YY5oJeFkQ==','game 3','uk',17,false,'2022-08-01',45.93,NULL,'2022-09-01',NULL,NULL,'2022-07-01',45.93,1,45.93,1,'2022-09-01',NULL,NULL,NULL,NULL,'2022-08-01','2022-08-01',45.93,1),
	 ('1jx1AjqUwE9sbCyafQnUNQ==','game 3','ru',25,false,'2022-06-01',56.13,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,56.13,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-12-01',212.79,7),
	 ('1jx1AjqUwE9sbCyafQnUNQ==','game 3','ru',25,false,'2022-07-01',16.29,'2022-06-01','2022-08-01','2022-08-01',56.13,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-39.84,NULL,NULL,'2022-06-01','2022-12-01',212.79,7),
	 ('1jx1AjqUwE9sbCyafQnUNQ==','game 3','ru',25,false,'2022-08-01',21.18,'2022-07-01','2022-09-01','2022-09-01',16.29,'2022-07-01',NULL,NULL,NULL,NULL,NULL,4.89,NULL,NULL,NULL,'2022-06-01','2022-12-01',212.79,7),
	 ('1jx1AjqUwE9sbCyafQnUNQ==','game 3','ru',25,false,'2022-09-01',13.71,'2022-08-01','2022-10-01','2022-10-01',21.18,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-7.47,NULL,NULL,'2022-06-01','2022-12-01',212.79,7),
	 ('1jx1AjqUwE9sbCyafQnUNQ==','game 3','ru',25,false,'2022-10-01',46.98,'2022-09-01','2022-11-01','2022-11-01',13.71,'2022-09-01',NULL,NULL,NULL,NULL,NULL,33.27,NULL,NULL,NULL,'2022-06-01','2022-12-01',212.79,7);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('1jx1AjqUwE9sbCyafQnUNQ==','game 3','ru',25,false,'2022-11-01',20.13,'2022-10-01','2022-12-01','2022-12-01',46.98,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-26.85,NULL,NULL,'2022-06-01','2022-12-01',212.79,7),
	 ('1jx1AjqUwE9sbCyafQnUNQ==','game 3','ru',25,false,'2022-12-01',38.37,'2022-11-01','2023-01-01',NULL,20.13,'2022-11-01',38.37,1,NULL,NULL,'2023-01-01',18.24,NULL,NULL,NULL,'2022-06-01','2022-12-01',212.79,7),
	 ('1KzlDBp5hORL7Y5PBaB+0g==','game 3','uk',22,false,'2022-09-01',58.20,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,58.20,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',220.38,4),
	 ('1KzlDBp5hORL7Y5PBaB+0g==','game 3','uk',22,false,'2022-10-01',77.19,'2022-09-01','2022-11-01','2022-11-01',58.20,'2022-09-01',NULL,NULL,NULL,NULL,NULL,18.99,NULL,NULL,NULL,'2022-09-01','2022-12-01',220.38,4),
	 ('1KzlDBp5hORL7Y5PBaB+0g==','game 3','uk',22,false,'2022-11-01',63.27,'2022-10-01','2022-12-01','2022-12-01',77.19,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-13.92,NULL,NULL,'2022-09-01','2022-12-01',220.38,4),
	 ('1KzlDBp5hORL7Y5PBaB+0g==','game 3','uk',22,false,'2022-12-01',21.72,'2022-11-01','2023-01-01',NULL,63.27,'2022-11-01',21.72,1,NULL,NULL,'2023-01-01',NULL,-41.55,NULL,NULL,'2022-09-01','2022-12-01',220.38,4),
	 ('1tIsLi6U0zW1RIuaViNanA==','game 3','uk',20,false,'2022-09-01',33.36,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,33.36,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',150.24,4),
	 ('1tIsLi6U0zW1RIuaViNanA==','game 3','uk',20,false,'2022-10-01',29.25,'2022-09-01','2022-11-01','2022-11-01',33.36,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-4.11,NULL,NULL,'2022-09-01','2022-12-01',150.24,4),
	 ('1tIsLi6U0zW1RIuaViNanA==','game 3','uk',20,false,'2022-11-01',18.15,'2022-10-01','2022-12-01','2022-12-01',29.25,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-11.10,NULL,NULL,'2022-09-01','2022-12-01',150.24,4),
	 ('1tIsLi6U0zW1RIuaViNanA==','game 3','uk',20,false,'2022-12-01',69.48,'2022-11-01','2023-01-01',NULL,18.15,'2022-11-01',69.48,1,NULL,NULL,'2023-01-01',51.33,NULL,NULL,NULL,'2022-09-01','2022-12-01',150.24,4);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('29qvbD06oXdmg5G7X/Wigw==','game 3','uk',17,false,'2022-12-01',24.51,NULL,'2023-01-01',NULL,NULL,'2022-11-01',24.51,1,24.51,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',24.51,1),
	 ('2be8IOVjt9pzDDEVqZwIKQ==','game 3','ru',25,false,'2022-10-01',27.0,NULL,'2022-11-01','2022-12-01',NULL,'2022-09-01',27.0,1,27.0,1,'2022-11-01',NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',96.96,3),
	 ('2be8IOVjt9pzDDEVqZwIKQ==','game 3','ru',25,false,'2022-12-01',69.96,'2022-10-01','2023-01-01',NULL,27.0,'2022-11-01',69.96,1,NULL,NULL,'2023-01-01',NULL,NULL,69.96,1,'2022-10-01','2022-12-01',96.96,3),
	 ('2FYEYdoJMUOtbJ6TruruWA==','game 3','ru',20,false,'2022-04-01',56.85,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,56.85,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-12-01',234.78,9),
	 ('2FYEYdoJMUOtbJ6TruruWA==','game 3','ru',20,false,'2022-05-01',30.33,'2022-04-01','2022-06-01','2022-06-01',56.85,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-26.52,NULL,NULL,'2022-04-01','2022-12-01',234.78,9),
	 ('2FYEYdoJMUOtbJ6TruruWA==','game 3','ru',20,false,'2022-06-01',22.47,'2022-05-01','2022-07-01','2022-07-01',30.33,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-7.86,NULL,NULL,'2022-04-01','2022-12-01',234.78,9),
	 ('2FYEYdoJMUOtbJ6TruruWA==','game 3','ru',20,false,'2022-07-01',24.84,'2022-06-01','2022-08-01','2022-08-01',22.47,'2022-06-01',NULL,NULL,NULL,NULL,NULL,2.37,NULL,NULL,NULL,'2022-04-01','2022-12-01',234.78,9),
	 ('2FYEYdoJMUOtbJ6TruruWA==','game 3','ru',20,false,'2022-08-01',14.19,'2022-07-01','2022-09-01','2022-10-01',24.84,'2022-07-01',14.19,1,NULL,NULL,'2022-09-01',NULL,-10.65,NULL,NULL,'2022-04-01','2022-12-01',234.78,9),
	 ('2FYEYdoJMUOtbJ6TruruWA==','game 3','ru',20,false,'2022-10-01',42.84,'2022-08-01','2022-11-01','2022-11-01',14.19,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,42.84,1,'2022-04-01','2022-12-01',234.78,9),
	 ('2FYEYdoJMUOtbJ6TruruWA==','game 3','ru',20,false,'2022-11-01',29.13,'2022-10-01','2022-12-01','2022-12-01',42.84,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-13.71,NULL,NULL,'2022-04-01','2022-12-01',234.78,9);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('2FYEYdoJMUOtbJ6TruruWA==','game 3','ru',20,false,'2022-12-01',14.13,'2022-11-01','2023-01-01',NULL,29.13,'2022-11-01',14.13,1,NULL,NULL,'2023-01-01',NULL,-15.00,NULL,NULL,'2022-04-01','2022-12-01',234.78,9),
	 ('2KL9Q4TKLCcD4cngwhx6Dg==','game 3','ru',18,false,'2022-09-01',14.04,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,14.04,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-11-01',94.92,3),
	 ('2KL9Q4TKLCcD4cngwhx6Dg==','game 3','ru',18,false,'2022-10-01',56.04,'2022-09-01','2022-11-01','2022-11-01',14.04,'2022-09-01',NULL,NULL,NULL,NULL,NULL,42.00,NULL,NULL,NULL,'2022-09-01','2022-11-01',94.92,3),
	 ('2KL9Q4TKLCcD4cngwhx6Dg==','game 3','ru',18,false,'2022-11-01',24.84,'2022-10-01','2022-12-01',NULL,56.04,'2022-10-01',24.84,1,NULL,NULL,'2022-12-01',NULL,-31.20,NULL,NULL,'2022-09-01','2022-11-01',94.92,3),
	 ('2onLVyXEEj2aH+D4N9ldYQ==','game 3','uk',16,false,'2022-08-01',50.04,NULL,'2022-09-01','2022-10-01',NULL,'2022-07-01',50.04,1,50.04,1,'2022-09-01',NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',221.82,5),
	 ('2onLVyXEEj2aH+D4N9ldYQ==','game 3','uk',16,false,'2022-10-01',42.72,'2022-08-01','2022-11-01','2022-11-01',50.04,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,42.72,1,'2022-08-01','2022-12-01',221.82,5),
	 ('2onLVyXEEj2aH+D4N9ldYQ==','game 3','uk',16,false,'2022-11-01',22.68,'2022-10-01','2022-12-01','2022-12-01',42.72,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-20.04,NULL,NULL,'2022-08-01','2022-12-01',221.82,5),
	 ('2onLVyXEEj2aH+D4N9ldYQ==','game 3','uk',16,false,'2022-12-01',106.38,'2022-11-01','2023-01-01',NULL,22.68,'2022-11-01',106.38,1,NULL,NULL,'2023-01-01',83.70,NULL,NULL,NULL,'2022-08-01','2022-12-01',221.82,5),
	 ('2Tm77AxZ7h7oCNKgCgMpnQ==','game 3','uk',23,false,'2022-04-01',54.96,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,54.96,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-11-01',240.45,8),
	 ('2Tm77AxZ7h7oCNKgCgMpnQ==','game 3','uk',23,false,'2022-05-01',72.06,'2022-04-01','2022-06-01','2022-06-01',54.96,'2022-04-01',NULL,NULL,NULL,NULL,NULL,17.10,NULL,NULL,NULL,'2022-04-01','2022-11-01',240.45,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('2Tm77AxZ7h7oCNKgCgMpnQ==','game 3','uk',23,false,'2022-06-01',25.35,'2022-05-01','2022-07-01','2022-07-01',72.06,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-46.71,NULL,NULL,'2022-04-01','2022-11-01',240.45,8),
	 ('2Tm77AxZ7h7oCNKgCgMpnQ==','game 3','uk',23,false,'2022-07-01',38.10,'2022-06-01','2022-08-01','2022-09-01',25.35,'2022-06-01',38.10,1,NULL,NULL,'2022-08-01',12.75,NULL,NULL,NULL,'2022-04-01','2022-11-01',240.45,8),
	 ('2Tm77AxZ7h7oCNKgCgMpnQ==','game 3','uk',23,false,'2022-09-01',12.12,'2022-07-01','2022-10-01','2022-10-01',38.10,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,12.12,1,'2022-04-01','2022-11-01',240.45,8),
	 ('2Tm77AxZ7h7oCNKgCgMpnQ==','game 3','uk',23,false,'2022-10-01',21.87,'2022-09-01','2022-11-01','2022-11-01',12.12,'2022-09-01',NULL,NULL,NULL,NULL,NULL,9.75,NULL,NULL,NULL,'2022-04-01','2022-11-01',240.45,8),
	 ('2Tm77AxZ7h7oCNKgCgMpnQ==','game 3','uk',23,false,'2022-11-01',15.99,'2022-10-01','2022-12-01',NULL,21.87,'2022-10-01',15.99,1,NULL,NULL,'2022-12-01',NULL,-5.88,NULL,NULL,'2022-04-01','2022-11-01',240.45,8),
	 ('3iITAz/ADjFv3PDTgTjxSg==','game 3','ru',16,false,'2022-03-01',23.76,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,23.76,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-09-01',321.60,7),
	 ('3iITAz/ADjFv3PDTgTjxSg==','game 3','ru',16,false,'2022-04-01',81.42,'2022-03-01','2022-05-01','2022-05-01',23.76,'2022-03-01',NULL,NULL,NULL,NULL,NULL,57.66,NULL,NULL,NULL,'2022-03-01','2022-09-01',321.60,7),
	 ('3iITAz/ADjFv3PDTgTjxSg==','game 3','ru',16,false,'2022-05-01',15.69,'2022-04-01','2022-06-01','2022-06-01',81.42,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-65.73,NULL,NULL,'2022-03-01','2022-09-01',321.60,7),
	 ('3iITAz/ADjFv3PDTgTjxSg==','game 3','ru',16,false,'2022-06-01',34.35,'2022-05-01','2022-07-01','2022-07-01',15.69,'2022-05-01',NULL,NULL,NULL,NULL,NULL,18.66,NULL,NULL,NULL,'2022-03-01','2022-09-01',321.60,7),
	 ('3iITAz/ADjFv3PDTgTjxSg==','game 3','ru',16,false,'2022-07-01',50.58,'2022-06-01','2022-08-01','2022-08-01',34.35,'2022-06-01',NULL,NULL,NULL,NULL,NULL,16.23,NULL,NULL,NULL,'2022-03-01','2022-09-01',321.60,7);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('3iITAz/ADjFv3PDTgTjxSg==','game 3','ru',16,false,'2022-08-01',97.08,'2022-07-01','2022-09-01','2022-09-01',50.58,'2022-07-01',NULL,NULL,NULL,NULL,NULL,46.50,NULL,NULL,NULL,'2022-03-01','2022-09-01',321.60,7),
	 ('3iITAz/ADjFv3PDTgTjxSg==','game 3','ru',16,false,'2022-09-01',18.72,'2022-08-01','2022-10-01',NULL,97.08,'2022-08-01',18.72,1,NULL,NULL,'2022-10-01',NULL,-78.36,NULL,NULL,'2022-03-01','2022-09-01',321.60,7),
	 ('3KHhqZr7/1n2+bTP13WuXA==','game 3','uk',16,false,'2022-06-01',74.85,NULL,'2022-07-01','2022-08-01',NULL,'2022-05-01',74.85,1,74.85,1,'2022-07-01',NULL,NULL,NULL,NULL,'2022-06-01','2022-10-01',172.53,5),
	 ('3KHhqZr7/1n2+bTP13WuXA==','game 3','uk',16,false,'2022-08-01',20.19,'2022-06-01','2022-09-01','2022-09-01',74.85,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,20.19,1,'2022-06-01','2022-10-01',172.53,5),
	 ('3KHhqZr7/1n2+bTP13WuXA==','game 3','uk',16,false,'2022-09-01',48.27,'2022-08-01','2022-10-01','2022-10-01',20.19,'2022-08-01',NULL,NULL,NULL,NULL,NULL,28.08,NULL,NULL,NULL,'2022-06-01','2022-10-01',172.53,5),
	 ('3KHhqZr7/1n2+bTP13WuXA==','game 3','uk',16,false,'2022-10-01',29.22,'2022-09-01','2022-11-01',NULL,48.27,'2022-09-01',29.22,1,NULL,NULL,'2022-11-01',NULL,-19.05,NULL,NULL,'2022-06-01','2022-10-01',172.53,5),
	 ('3KSfEl7FcP/+5FSUNXs5Aw==','game 3','ru',28,false,'2022-10-01',23.31,NULL,'2022-11-01',NULL,NULL,'2022-09-01',23.31,1,23.31,1,'2022-11-01',NULL,NULL,NULL,NULL,'2022-10-01','2022-10-01',23.31,1),
	 ('3OXz+Ar2gN+zfGLZTRCVMQ==','game 3','uk',16,false,'2022-12-01',18.9,NULL,'2023-01-01',NULL,NULL,'2022-11-01',18.9,1,18.9,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',18.9,1),
	 ('3rCdNEPkh3vwmYB0BVadEw==','game 3','ru',27,false,'2022-05-01',22.86,NULL,'2022-06-01','2022-07-01',NULL,'2022-04-01',22.86,1,22.86,1,'2022-06-01',NULL,NULL,NULL,NULL,'2022-05-01','2022-08-01',62.07,4),
	 ('3rCdNEPkh3vwmYB0BVadEw==','game 3','ru',27,false,'2022-07-01',21.87,'2022-05-01','2022-08-01','2022-08-01',22.86,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,21.87,1,'2022-05-01','2022-08-01',62.07,4);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('3rCdNEPkh3vwmYB0BVadEw==','game 3','ru',27,false,'2022-08-01',17.34,'2022-07-01','2022-09-01',NULL,21.87,'2022-07-01',17.34,1,NULL,NULL,'2022-09-01',NULL,-4.53,NULL,NULL,'2022-05-01','2022-08-01',62.07,4),
	 ('3TfpxDVNF0T+g4S60EOCBw==','game 3','uk',28,false,'2022-11-01',15.27,NULL,'2022-12-01',NULL,NULL,'2022-10-01',15.27,1,15.27,1,'2022-12-01',NULL,NULL,NULL,NULL,'2022-11-01','2022-11-01',15.27,1),
	 ('3v8rT35Ra6ui/zatnMoTIw==','game 3','uk',28,false,'2022-11-01',17.85,NULL,'2022-12-01','2022-12-01',NULL,'2022-10-01',NULL,NULL,17.85,1,NULL,NULL,NULL,NULL,NULL,'2022-11-01','2022-12-01',61.47,2),
	 ('3v8rT35Ra6ui/zatnMoTIw==','game 3','uk',28,false,'2022-12-01',43.62,'2022-11-01','2023-01-01',NULL,17.85,'2022-11-01',43.62,1,NULL,NULL,'2023-01-01',25.77,NULL,NULL,NULL,'2022-11-01','2022-12-01',61.47,2),
	 ('3Whh6FLR1MSfsuHKVdCEYQ==','game 3','uk',21,true,'2022-04-01',59.67,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,59.67,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-12-01',171.57,9),
	 ('3Whh6FLR1MSfsuHKVdCEYQ==','game 3','uk',21,true,'2022-05-01',12.36,'2022-04-01','2022-06-01','2022-06-01',59.67,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-47.31,NULL,NULL,'2022-04-01','2022-12-01',171.57,9),
	 ('3Whh6FLR1MSfsuHKVdCEYQ==','game 3','uk',21,true,'2022-06-01',20.13,'2022-05-01','2022-07-01','2022-07-01',12.36,'2022-05-01',NULL,NULL,NULL,NULL,NULL,7.77,NULL,NULL,NULL,'2022-04-01','2022-12-01',171.57,9),
	 ('3Whh6FLR1MSfsuHKVdCEYQ==','game 3','uk',21,true,'2022-07-01',15.78,'2022-06-01','2022-08-01','2022-08-01',20.13,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-4.35,NULL,NULL,'2022-04-01','2022-12-01',171.57,9),
	 ('3Whh6FLR1MSfsuHKVdCEYQ==','game 3','uk',21,true,'2022-08-01',17.16,'2022-07-01','2022-09-01','2022-09-01',15.78,'2022-07-01',NULL,NULL,NULL,NULL,NULL,1.38,NULL,NULL,NULL,'2022-04-01','2022-12-01',171.57,9),
	 ('3Whh6FLR1MSfsuHKVdCEYQ==','game 3','uk',21,true,'2022-09-01',19.74,'2022-08-01','2022-10-01','2022-12-01',17.16,'2022-08-01',19.74,1,NULL,NULL,'2022-10-01',2.58,NULL,NULL,NULL,'2022-04-01','2022-12-01',171.57,9);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('3Whh6FLR1MSfsuHKVdCEYQ==','game 3','uk',21,true,'2022-12-01',26.73,'2022-09-01','2023-01-01',NULL,19.74,'2022-11-01',26.73,1,NULL,NULL,'2023-01-01',NULL,NULL,26.73,1,'2022-04-01','2022-12-01',171.57,9),
	 ('3Xuq0acIoGEgw19qflIoog==','game 3','uk',25,false,'2022-06-01',12.69,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,12.69,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-10-01',139.50,5),
	 ('3Xuq0acIoGEgw19qflIoog==','game 3','uk',25,false,'2022-07-01',41.73,'2022-06-01','2022-08-01','2022-08-01',12.69,'2022-06-01',NULL,NULL,NULL,NULL,NULL,29.04,NULL,NULL,NULL,'2022-06-01','2022-10-01',139.50,5),
	 ('3Xuq0acIoGEgw19qflIoog==','game 3','uk',25,false,'2022-08-01',19.86,'2022-07-01','2022-09-01','2022-09-01',41.73,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-21.87,NULL,NULL,'2022-06-01','2022-10-01',139.50,5),
	 ('3Xuq0acIoGEgw19qflIoog==','game 3','uk',25,false,'2022-09-01',34.32,'2022-08-01','2022-10-01','2022-10-01',19.86,'2022-08-01',NULL,NULL,NULL,NULL,NULL,14.46,NULL,NULL,NULL,'2022-06-01','2022-10-01',139.50,5),
	 ('3Xuq0acIoGEgw19qflIoog==','game 3','uk',25,false,'2022-10-01',30.9,'2022-09-01','2022-11-01',NULL,34.32,'2022-09-01',30.9,1,NULL,NULL,'2022-11-01',NULL,-3.42,NULL,NULL,'2022-06-01','2022-10-01',139.50,5),
	 ('4b7l8C489HEJirtoe7xtFg==','game 3','uk',20,true,'2022-03-01',27.15,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,27.15,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-12-01',268.41,10),
	 ('4b7l8C489HEJirtoe7xtFg==','game 3','uk',20,true,'2022-04-01',14.94,'2022-03-01','2022-05-01','2022-05-01',27.15,'2022-03-01',NULL,NULL,NULL,NULL,NULL,NULL,-12.21,NULL,NULL,'2022-03-01','2022-12-01',268.41,10),
	 ('4b7l8C489HEJirtoe7xtFg==','game 3','uk',20,true,'2022-05-01',26.40,'2022-04-01','2022-06-01','2022-06-01',14.94,'2022-04-01',NULL,NULL,NULL,NULL,NULL,11.46,NULL,NULL,NULL,'2022-03-01','2022-12-01',268.41,10),
	 ('4b7l8C489HEJirtoe7xtFg==','game 3','uk',20,true,'2022-06-01',22.83,'2022-05-01','2022-07-01','2022-07-01',26.40,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-3.57,NULL,NULL,'2022-03-01','2022-12-01',268.41,10);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('4b7l8C489HEJirtoe7xtFg==','game 3','uk',20,true,'2022-07-01',89.28,'2022-06-01','2022-08-01','2022-08-01',22.83,'2022-06-01',NULL,NULL,NULL,NULL,NULL,66.45,NULL,NULL,NULL,'2022-03-01','2022-12-01',268.41,10),
	 ('4b7l8C489HEJirtoe7xtFg==','game 3','uk',20,true,'2022-08-01',16.56,'2022-07-01','2022-09-01','2022-09-01',89.28,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-72.72,NULL,NULL,'2022-03-01','2022-12-01',268.41,10),
	 ('4b7l8C489HEJirtoe7xtFg==','game 3','uk',20,true,'2022-09-01',18.24,'2022-08-01','2022-10-01','2022-11-01',16.56,'2022-08-01',18.24,1,NULL,NULL,'2022-10-01',1.68,NULL,NULL,NULL,'2022-03-01','2022-12-01',268.41,10),
	 ('4b7l8C489HEJirtoe7xtFg==','game 3','uk',20,true,'2022-11-01',31.26,'2022-09-01','2022-12-01','2022-12-01',18.24,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,31.26,1,'2022-03-01','2022-12-01',268.41,10),
	 ('4b7l8C489HEJirtoe7xtFg==','game 3','uk',20,true,'2022-12-01',21.75,'2022-11-01','2023-01-01',NULL,31.26,'2022-11-01',21.75,1,NULL,NULL,'2023-01-01',NULL,-9.51,NULL,NULL,'2022-03-01','2022-12-01',268.41,10),
	 ('4btLP2zvi8eBV0t08fdkKQ==','game 3','ru',20,false,'2022-03-01',17.79,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,17.79,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-12-01',467.37,10),
	 ('4btLP2zvi8eBV0t08fdkKQ==','game 3','ru',20,false,'2022-04-01',125.97,'2022-03-01','2022-05-01','2022-05-01',17.79,'2022-03-01',NULL,NULL,NULL,NULL,NULL,108.18,NULL,NULL,NULL,'2022-03-01','2022-12-01',467.37,10),
	 ('4btLP2zvi8eBV0t08fdkKQ==','game 3','ru',20,false,'2022-05-01',91.68,'2022-04-01','2022-06-01','2022-06-01',125.97,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-34.29,NULL,NULL,'2022-03-01','2022-12-01',467.37,10),
	 ('4btLP2zvi8eBV0t08fdkKQ==','game 3','ru',20,false,'2022-06-01',27.87,'2022-05-01','2022-07-01','2022-07-01',91.68,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-63.81,NULL,NULL,'2022-03-01','2022-12-01',467.37,10),
	 ('4btLP2zvi8eBV0t08fdkKQ==','game 3','ru',20,false,'2022-07-01',40.71,'2022-06-01','2022-08-01','2022-08-01',27.87,'2022-06-01',NULL,NULL,NULL,NULL,NULL,12.84,NULL,NULL,NULL,'2022-03-01','2022-12-01',467.37,10);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('4btLP2zvi8eBV0t08fdkKQ==','game 3','ru',20,false,'2022-08-01',47.91,'2022-07-01','2022-09-01','2022-09-01',40.71,'2022-07-01',NULL,NULL,NULL,NULL,NULL,7.20,NULL,NULL,NULL,'2022-03-01','2022-12-01',467.37,10),
	 ('4btLP2zvi8eBV0t08fdkKQ==','game 3','ru',20,false,'2022-09-01',23.34,'2022-08-01','2022-10-01','2022-12-01',47.91,'2022-08-01',23.34,1,NULL,NULL,'2022-10-01',NULL,-24.57,NULL,NULL,'2022-03-01','2022-12-01',467.37,10),
	 ('4btLP2zvi8eBV0t08fdkKQ==','game 3','ru',20,false,'2022-12-01',92.10,'2022-09-01','2023-01-01',NULL,23.34,'2022-11-01',92.10,1,NULL,NULL,'2023-01-01',NULL,NULL,92.10,1,'2022-03-01','2022-12-01',467.37,10),
	 ('4EiWC2ewiX2A7i9NuBAefQ==','game 3','uk',18,true,'2022-09-01',18.69,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,18.69,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-11-01',105.87,3),
	 ('4EiWC2ewiX2A7i9NuBAefQ==','game 3','uk',18,true,'2022-10-01',57.39,'2022-09-01','2022-11-01','2022-11-01',18.69,'2022-09-01',NULL,NULL,NULL,NULL,NULL,38.70,NULL,NULL,NULL,'2022-09-01','2022-11-01',105.87,3),
	 ('4EiWC2ewiX2A7i9NuBAefQ==','game 3','uk',18,true,'2022-11-01',29.79,'2022-10-01','2022-12-01',NULL,57.39,'2022-10-01',29.79,1,NULL,NULL,'2022-12-01',NULL,-27.60,NULL,NULL,'2022-09-01','2022-11-01',105.87,3),
	 ('4oH5e29koOH9zNYW8Kwcsg==','game 3','uk',28,false,'2022-05-01',12.99,NULL,'2022-06-01','2022-07-01',NULL,'2022-04-01',12.99,1,12.99,1,'2022-06-01',NULL,NULL,NULL,NULL,'2022-05-01','2022-08-01',43.56,4),
	 ('4oH5e29koOH9zNYW8Kwcsg==','game 3','uk',28,false,'2022-07-01',18.06,'2022-05-01','2022-08-01','2022-08-01',12.99,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,18.06,1,'2022-05-01','2022-08-01',43.56,4),
	 ('4oH5e29koOH9zNYW8Kwcsg==','game 3','uk',28,false,'2022-08-01',12.51,'2022-07-01','2022-09-01',NULL,18.06,'2022-07-01',12.51,1,NULL,NULL,'2022-09-01',NULL,-5.55,NULL,NULL,'2022-05-01','2022-08-01',43.56,4),
	 ('4pssft0TgDfiQexjbe25lw==','game 3','ru',26,false,'2022-06-01',14.76,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,14.76,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-11-01',126.39,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('4pssft0TgDfiQexjbe25lw==','game 3','ru',26,false,'2022-07-01',14.43,'2022-06-01','2022-08-01','2022-08-01',14.76,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-0.33,NULL,NULL,'2022-06-01','2022-11-01',126.39,6),
	 ('4pssft0TgDfiQexjbe25lw==','game 3','ru',26,false,'2022-08-01',59.40,'2022-07-01','2022-09-01','2022-11-01',14.43,'2022-07-01',59.40,1,NULL,NULL,'2022-09-01',44.97,NULL,NULL,NULL,'2022-06-01','2022-11-01',126.39,6),
	 ('4pssft0TgDfiQexjbe25lw==','game 3','ru',26,false,'2022-11-01',37.80,'2022-08-01','2022-12-01',NULL,59.40,'2022-10-01',37.80,1,NULL,NULL,'2022-12-01',NULL,NULL,37.80,1,'2022-06-01','2022-11-01',126.39,6),
	 ('54ouP7lBhVCeV8ftS1Oj4Q==','game 3','ru',21,false,'2022-11-01',29.22,NULL,'2022-12-01','2022-12-01',NULL,'2022-10-01',NULL,NULL,29.22,1,NULL,NULL,NULL,NULL,NULL,'2022-11-01','2022-12-01',57.45,2),
	 ('54ouP7lBhVCeV8ftS1Oj4Q==','game 3','ru',21,false,'2022-12-01',28.23,'2022-11-01','2023-01-01',NULL,29.22,'2022-11-01',28.23,1,NULL,NULL,'2023-01-01',NULL,-0.99,NULL,NULL,'2022-11-01','2022-12-01',57.45,2),
	 ('5a/eDajN+4bJdigfI5TWoQ==','game 3','ru',17,false,'2022-07-01',12.87,NULL,'2022-08-01',NULL,NULL,'2022-06-01',12.87,1,12.87,1,'2022-08-01',NULL,NULL,NULL,NULL,'2022-07-01','2022-07-01',12.87,1),
	 ('5fGaUgWk82R8c6U6A5d9pg==','game 3','uk',31,false,'2022-12-01',17.28,NULL,'2023-01-01',NULL,NULL,'2022-11-01',17.28,1,17.28,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',17.28,1),
	 ('5n2VR2SS79K3vJ0/V2A8RQ==','game 3','ru',27,false,'2022-08-01',47.13,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,47.13,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-09-01',79.17,2),
	 ('5n2VR2SS79K3vJ0/V2A8RQ==','game 3','ru',27,false,'2022-09-01',32.04,'2022-08-01','2022-10-01',NULL,47.13,'2022-08-01',32.04,1,NULL,NULL,'2022-10-01',NULL,-15.09,NULL,NULL,'2022-08-01','2022-09-01',79.17,2),
	 ('6NexxpTuLaFmuoksJ0l8rg==','game 3','uk',24,false,'2022-10-01',19.17,NULL,'2022-11-01','2022-12-01',NULL,'2022-09-01',19.17,1,19.17,1,'2022-11-01',NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',122.01,3);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('6NexxpTuLaFmuoksJ0l8rg==','game 3','uk',24,false,'2022-12-01',102.84,'2022-10-01','2023-01-01',NULL,19.17,'2022-11-01',102.84,1,NULL,NULL,'2023-01-01',NULL,NULL,102.84,1,'2022-10-01','2022-12-01',122.01,3),
	 ('6We7zBO7mVbNxGEl/xPKVg==','game 3','uk',19,false,'2022-05-01',22.74,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,22.74,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-12-01',556.86,8),
	 ('6We7zBO7mVbNxGEl/xPKVg==','game 3','uk',19,false,'2022-06-01',28.95,'2022-05-01','2022-07-01','2022-07-01',22.74,'2022-05-01',NULL,NULL,NULL,NULL,NULL,6.21,NULL,NULL,NULL,'2022-05-01','2022-12-01',556.86,8),
	 ('6We7zBO7mVbNxGEl/xPKVg==','game 3','uk',19,false,'2022-07-01',118.83,'2022-06-01','2022-08-01','2022-08-01',28.95,'2022-06-01',NULL,NULL,NULL,NULL,NULL,89.88,NULL,NULL,NULL,'2022-05-01','2022-12-01',556.86,8),
	 ('6We7zBO7mVbNxGEl/xPKVg==','game 3','uk',19,false,'2022-08-01',21.87,'2022-07-01','2022-09-01','2022-09-01',118.83,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-96.96,NULL,NULL,'2022-05-01','2022-12-01',556.86,8),
	 ('6We7zBO7mVbNxGEl/xPKVg==','game 3','uk',19,false,'2022-09-01',41.55,'2022-08-01','2022-10-01','2022-10-01',21.87,'2022-08-01',NULL,NULL,NULL,NULL,NULL,19.68,NULL,NULL,NULL,'2022-05-01','2022-12-01',556.86,8),
	 ('6We7zBO7mVbNxGEl/xPKVg==','game 3','uk',19,false,'2022-10-01',151.68,'2022-09-01','2022-11-01','2022-11-01',41.55,'2022-09-01',NULL,NULL,NULL,NULL,NULL,110.13,NULL,NULL,NULL,'2022-05-01','2022-12-01',556.86,8),
	 ('6We7zBO7mVbNxGEl/xPKVg==','game 3','uk',19,false,'2022-11-01',95.43,'2022-10-01','2022-12-01','2022-12-01',151.68,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-56.25,NULL,NULL,'2022-05-01','2022-12-01',556.86,8),
	 ('6We7zBO7mVbNxGEl/xPKVg==','game 3','uk',19,false,'2022-12-01',75.81,'2022-11-01','2023-01-01',NULL,95.43,'2022-11-01',75.81,1,NULL,NULL,'2023-01-01',NULL,-19.62,NULL,NULL,'2022-05-01','2022-12-01',556.86,8),
	 ('/70HXakPPmIGA9K58CIOug==','game 3','uk',18,false,'2022-10-01',15.48,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,15.48,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-11-01',27.99,2);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('/70HXakPPmIGA9K58CIOug==','game 3','uk',18,false,'2022-11-01',12.51,'2022-10-01','2022-12-01',NULL,15.48,'2022-10-01',12.51,1,NULL,NULL,'2022-12-01',NULL,-2.97,NULL,NULL,'2022-10-01','2022-11-01',27.99,2),
	 ('72brUr/DKItStlTen5pHYg==','game 3','uk',24,false,'2022-03-01',24.15,NULL,'2022-04-01','2022-05-01',NULL,'2022-02-01',24.15,1,24.15,1,'2022-04-01',NULL,NULL,NULL,NULL,'2022-03-01','2022-11-01',262.56,9),
	 ('72brUr/DKItStlTen5pHYg==','game 3','uk',24,false,'2022-05-01',19.92,'2022-03-01','2022-06-01','2022-06-01',24.15,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,19.92,1,'2022-03-01','2022-11-01',262.56,9),
	 ('72brUr/DKItStlTen5pHYg==','game 3','uk',24,false,'2022-06-01',86.91,'2022-05-01','2022-07-01','2022-07-01',19.92,'2022-05-01',NULL,NULL,NULL,NULL,NULL,66.99,NULL,NULL,NULL,'2022-03-01','2022-11-01',262.56,9),
	 ('72brUr/DKItStlTen5pHYg==','game 3','uk',24,false,'2022-07-01',37.11,'2022-06-01','2022-08-01','2022-08-01',86.91,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-49.80,NULL,NULL,'2022-03-01','2022-11-01',262.56,9),
	 ('72brUr/DKItStlTen5pHYg==','game 3','uk',24,false,'2022-08-01',30.63,'2022-07-01','2022-09-01','2022-09-01',37.11,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-6.48,NULL,NULL,'2022-03-01','2022-11-01',262.56,9),
	 ('72brUr/DKItStlTen5pHYg==','game 3','uk',24,false,'2022-09-01',18.3,'2022-08-01','2022-10-01','2022-10-01',30.63,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-12.33,NULL,NULL,'2022-03-01','2022-11-01',262.56,9),
	 ('72brUr/DKItStlTen5pHYg==','game 3','uk',24,false,'2022-10-01',31.98,'2022-09-01','2022-11-01','2022-11-01',18.3,'2022-09-01',NULL,NULL,NULL,NULL,NULL,13.68,NULL,NULL,NULL,'2022-03-01','2022-11-01',262.56,9),
	 ('72brUr/DKItStlTen5pHYg==','game 3','uk',24,false,'2022-11-01',13.56,'2022-10-01','2022-12-01',NULL,31.98,'2022-10-01',13.56,1,NULL,NULL,'2022-12-01',NULL,-18.42,NULL,NULL,'2022-03-01','2022-11-01',262.56,9),
	 ('75lEf3nSWLSf6GncqhR9gQ==','game 3','ru',22,false,'2022-03-01',14.1,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,14.1,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-09-01',288.21,7);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('75lEf3nSWLSf6GncqhR9gQ==','game 3','ru',22,false,'2022-04-01',65.97,'2022-03-01','2022-05-01','2022-05-01',14.1,'2022-03-01',NULL,NULL,NULL,NULL,NULL,51.87,NULL,NULL,NULL,'2022-03-01','2022-09-01',288.21,7),
	 ('75lEf3nSWLSf6GncqhR9gQ==','game 3','ru',22,false,'2022-05-01',58.26,'2022-04-01','2022-06-01','2022-06-01',65.97,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-7.71,NULL,NULL,'2022-03-01','2022-09-01',288.21,7),
	 ('75lEf3nSWLSf6GncqhR9gQ==','game 3','ru',22,false,'2022-06-01',86.85,'2022-05-01','2022-07-01','2022-07-01',58.26,'2022-05-01',NULL,NULL,NULL,NULL,NULL,28.59,NULL,NULL,NULL,'2022-03-01','2022-09-01',288.21,7),
	 ('75lEf3nSWLSf6GncqhR9gQ==','game 3','ru',22,false,'2022-07-01',49.23,'2022-06-01','2022-08-01','2022-09-01',86.85,'2022-06-01',49.23,1,NULL,NULL,'2022-08-01',NULL,-37.62,NULL,NULL,'2022-03-01','2022-09-01',288.21,7),
	 ('75lEf3nSWLSf6GncqhR9gQ==','game 3','ru',22,false,'2022-09-01',13.8,'2022-07-01','2022-10-01',NULL,49.23,'2022-08-01',13.8,1,NULL,NULL,'2022-10-01',NULL,NULL,13.8,1,'2022-03-01','2022-09-01',288.21,7),
	 ('787jk0VnxM8/sv/0TkvO6A==','game 3','uk',20,false,'2022-03-01',48.45,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,48.45,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-12-01',470.73,10),
	 ('787jk0VnxM8/sv/0TkvO6A==','game 3','uk',20,false,'2022-04-01',53.49,'2022-03-01','2022-05-01','2022-05-01',48.45,'2022-03-01',NULL,NULL,NULL,NULL,NULL,5.04,NULL,NULL,NULL,'2022-03-01','2022-12-01',470.73,10),
	 ('787jk0VnxM8/sv/0TkvO6A==','game 3','uk',20,false,'2022-05-01',36.75,'2022-04-01','2022-06-01','2022-06-01',53.49,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-16.74,NULL,NULL,'2022-03-01','2022-12-01',470.73,10),
	 ('787jk0VnxM8/sv/0TkvO6A==','game 3','uk',20,false,'2022-06-01',97.95,'2022-05-01','2022-07-01','2022-07-01',36.75,'2022-05-01',NULL,NULL,NULL,NULL,NULL,61.20,NULL,NULL,NULL,'2022-03-01','2022-12-01',470.73,10),
	 ('787jk0VnxM8/sv/0TkvO6A==','game 3','uk',20,false,'2022-07-01',21.48,'2022-06-01','2022-08-01','2022-08-01',97.95,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-76.47,NULL,NULL,'2022-03-01','2022-12-01',470.73,10);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('787jk0VnxM8/sv/0TkvO6A==','game 3','uk',20,false,'2022-08-01',76.29,'2022-07-01','2022-09-01','2022-09-01',21.48,'2022-07-01',NULL,NULL,NULL,NULL,NULL,54.81,NULL,NULL,NULL,'2022-03-01','2022-12-01',470.73,10),
	 ('787jk0VnxM8/sv/0TkvO6A==','game 3','uk',20,false,'2022-09-01',50.61,'2022-08-01','2022-10-01','2022-10-01',76.29,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-25.68,NULL,NULL,'2022-03-01','2022-12-01',470.73,10),
	 ('787jk0VnxM8/sv/0TkvO6A==','game 3','uk',20,false,'2022-10-01',34.92,'2022-09-01','2022-11-01','2022-11-01',50.61,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-15.69,NULL,NULL,'2022-03-01','2022-12-01',470.73,10),
	 ('787jk0VnxM8/sv/0TkvO6A==','game 3','uk',20,false,'2022-11-01',33.30,'2022-10-01','2022-12-01','2022-12-01',34.92,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-1.62,NULL,NULL,'2022-03-01','2022-12-01',470.73,10),
	 ('787jk0VnxM8/sv/0TkvO6A==','game 3','uk',20,false,'2022-12-01',17.49,'2022-11-01','2023-01-01',NULL,33.30,'2022-11-01',17.49,1,NULL,NULL,'2023-01-01',NULL,-15.81,NULL,NULL,'2022-03-01','2022-12-01',470.73,10),
	 ('7BqUeLmbiug63XrWs2+ZQQ==','game 3','ru',15,false,'2022-07-01',61.41,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,61.41,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',284.97,6),
	 ('7BqUeLmbiug63XrWs2+ZQQ==','game 3','ru',15,false,'2022-08-01',32.94,'2022-07-01','2022-09-01','2022-09-01',61.41,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-28.47,NULL,NULL,'2022-07-01','2022-12-01',284.97,6),
	 ('7BqUeLmbiug63XrWs2+ZQQ==','game 3','ru',15,false,'2022-09-01',14.01,'2022-08-01','2022-10-01','2022-10-01',32.94,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-18.93,NULL,NULL,'2022-07-01','2022-12-01',284.97,6),
	 ('7BqUeLmbiug63XrWs2+ZQQ==','game 3','ru',15,false,'2022-10-01',127.08,'2022-09-01','2022-11-01','2022-11-01',14.01,'2022-09-01',NULL,NULL,NULL,NULL,NULL,113.07,NULL,NULL,NULL,'2022-07-01','2022-12-01',284.97,6),
	 ('7BqUeLmbiug63XrWs2+ZQQ==','game 3','ru',15,false,'2022-11-01',22.41,'2022-10-01','2022-12-01','2022-12-01',127.08,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-104.67,NULL,NULL,'2022-07-01','2022-12-01',284.97,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('7BqUeLmbiug63XrWs2+ZQQ==','game 3','ru',15,false,'2022-12-01',27.12,'2022-11-01','2023-01-01',NULL,22.41,'2022-11-01',27.12,1,NULL,NULL,'2023-01-01',4.71,NULL,NULL,NULL,'2022-07-01','2022-12-01',284.97,6),
	 ('7Em69vKH6zh6HgArCzG0+w==','game 3','ru',17,false,'2022-12-01',72.18,NULL,'2023-01-01',NULL,NULL,'2022-11-01',72.18,1,72.18,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',72.18,1),
	 ('7EPlnA7OQ9MhMx+od6FA9g==','game 3','ru',23,false,'2022-03-01',158.67,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,158.67,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-12-01',440.16,10),
	 ('7EPlnA7OQ9MhMx+od6FA9g==','game 3','ru',23,false,'2022-04-01',114.15,'2022-03-01','2022-05-01','2022-05-01',158.67,'2022-03-01',NULL,NULL,NULL,NULL,NULL,NULL,-44.52,NULL,NULL,'2022-03-01','2022-12-01',440.16,10),
	 ('7EPlnA7OQ9MhMx+od6FA9g==','game 3','ru',23,false,'2022-05-01',51.18,'2022-04-01','2022-06-01','2022-06-01',114.15,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-62.97,NULL,NULL,'2022-03-01','2022-12-01',440.16,10),
	 ('7EPlnA7OQ9MhMx+od6FA9g==','game 3','ru',23,false,'2022-06-01',12.39,'2022-05-01','2022-07-01','2022-08-01',51.18,'2022-05-01',12.39,1,NULL,NULL,'2022-07-01',NULL,-38.79,NULL,NULL,'2022-03-01','2022-12-01',440.16,10),
	 ('7EPlnA7OQ9MhMx+od6FA9g==','game 3','ru',23,false,'2022-08-01',48.18,'2022-06-01','2022-09-01','2022-11-01',12.39,'2022-07-01',48.18,1,NULL,NULL,'2022-09-01',NULL,NULL,48.18,1,'2022-03-01','2022-12-01',440.16,10),
	 ('7EPlnA7OQ9MhMx+od6FA9g==','game 3','ru',23,false,'2022-11-01',14.43,'2022-08-01','2022-12-01','2022-12-01',48.18,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,14.43,1,'2022-03-01','2022-12-01',440.16,10),
	 ('7EPlnA7OQ9MhMx+od6FA9g==','game 3','ru',23,false,'2022-12-01',41.16,'2022-11-01','2023-01-01',NULL,14.43,'2022-11-01',41.16,1,NULL,NULL,'2023-01-01',26.73,NULL,NULL,NULL,'2022-03-01','2022-12-01',440.16,10),
	 ('7ew71UmoMb73L41PM/YL/w==','game 3','uk',17,false,'2022-05-01',32.10,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,32.10,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-11-01',235.83,7);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('7ew71UmoMb73L41PM/YL/w==','game 3','uk',17,false,'2022-06-01',34.11,'2022-05-01','2022-07-01','2022-07-01',32.10,'2022-05-01',NULL,NULL,NULL,NULL,NULL,2.01,NULL,NULL,NULL,'2022-05-01','2022-11-01',235.83,7),
	 ('7ew71UmoMb73L41PM/YL/w==','game 3','uk',17,false,'2022-07-01',40.23,'2022-06-01','2022-08-01','2022-08-01',34.11,'2022-06-01',NULL,NULL,NULL,NULL,NULL,6.12,NULL,NULL,NULL,'2022-05-01','2022-11-01',235.83,7),
	 ('7ew71UmoMb73L41PM/YL/w==','game 3','uk',17,false,'2022-08-01',40.74,'2022-07-01','2022-09-01','2022-09-01',40.23,'2022-07-01',NULL,NULL,NULL,NULL,NULL,0.51,NULL,NULL,NULL,'2022-05-01','2022-11-01',235.83,7),
	 ('7ew71UmoMb73L41PM/YL/w==','game 3','uk',17,false,'2022-09-01',45.15,'2022-08-01','2022-10-01','2022-10-01',40.74,'2022-08-01',NULL,NULL,NULL,NULL,NULL,4.41,NULL,NULL,NULL,'2022-05-01','2022-11-01',235.83,7),
	 ('7ew71UmoMb73L41PM/YL/w==','game 3','uk',17,false,'2022-10-01',13.74,'2022-09-01','2022-11-01','2022-11-01',45.15,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-31.41,NULL,NULL,'2022-05-01','2022-11-01',235.83,7),
	 ('7ew71UmoMb73L41PM/YL/w==','game 3','uk',17,false,'2022-11-01',29.76,'2022-10-01','2022-12-01',NULL,13.74,'2022-10-01',29.76,1,NULL,NULL,'2022-12-01',16.02,NULL,NULL,NULL,'2022-05-01','2022-11-01',235.83,7),
	 ('7GCGwypiXsxGxetp6/KmnA==','game 3','uk',31,false,'2022-08-01',30.21,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,30.21,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-11-01',138.51,4),
	 ('7GCGwypiXsxGxetp6/KmnA==','game 3','uk',31,false,'2022-09-01',63.30,'2022-08-01','2022-10-01','2022-11-01',30.21,'2022-08-01',63.30,1,NULL,NULL,'2022-10-01',33.09,NULL,NULL,NULL,'2022-08-01','2022-11-01',138.51,4),
	 ('7GCGwypiXsxGxetp6/KmnA==','game 3','uk',31,false,'2022-11-01',45.00,'2022-09-01','2022-12-01',NULL,63.30,'2022-10-01',45.00,1,NULL,NULL,'2022-12-01',NULL,NULL,45.00,1,'2022-08-01','2022-11-01',138.51,4),
	 ('7GE5h/3N3lcro3K9T3aujw==','game 3','ru',32,false,'2022-03-01',38.52,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,38.52,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-10-01',722.67,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('7GE5h/3N3lcro3K9T3aujw==','game 3','ru',32,false,'2022-04-01',58.20,'2022-03-01','2022-05-01','2022-05-01',38.52,'2022-03-01',NULL,NULL,NULL,NULL,NULL,19.68,NULL,NULL,NULL,'2022-03-01','2022-10-01',722.67,8),
	 ('7GE5h/3N3lcro3K9T3aujw==','game 3','ru',32,false,'2022-05-01',118.95,'2022-04-01','2022-06-01','2022-06-01',58.20,'2022-04-01',NULL,NULL,NULL,NULL,NULL,60.75,NULL,NULL,NULL,'2022-03-01','2022-10-01',722.67,8),
	 ('7GE5h/3N3lcro3K9T3aujw==','game 3','ru',32,false,'2022-06-01',144.75,'2022-05-01','2022-07-01','2022-07-01',118.95,'2022-05-01',NULL,NULL,NULL,NULL,NULL,25.80,NULL,NULL,NULL,'2022-03-01','2022-10-01',722.67,8),
	 ('7GE5h/3N3lcro3K9T3aujw==','game 3','ru',32,false,'2022-07-01',89.04,'2022-06-01','2022-08-01','2022-08-01',144.75,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-55.71,NULL,NULL,'2022-03-01','2022-10-01',722.67,8),
	 ('7GE5h/3N3lcro3K9T3aujw==','game 3','ru',32,false,'2022-08-01',104.70,'2022-07-01','2022-09-01','2022-09-01',89.04,'2022-07-01',NULL,NULL,NULL,NULL,NULL,15.66,NULL,NULL,NULL,'2022-03-01','2022-10-01',722.67,8),
	 ('7GE5h/3N3lcro3K9T3aujw==','game 3','ru',32,false,'2022-09-01',90.87,'2022-08-01','2022-10-01','2022-10-01',104.70,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-13.83,NULL,NULL,'2022-03-01','2022-10-01',722.67,8),
	 ('7GE5h/3N3lcro3K9T3aujw==','game 3','ru',32,false,'2022-10-01',77.64,'2022-09-01','2022-11-01',NULL,90.87,'2022-09-01',77.64,1,NULL,NULL,'2022-11-01',NULL,-13.23,NULL,NULL,'2022-03-01','2022-10-01',722.67,8),
	 ('7iS0Md8Z5SFpqNAYOVcs4w==','game 3','uk',18,false,'2022-12-01',68.64,NULL,'2023-01-01',NULL,NULL,'2022-11-01',68.64,1,68.64,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',68.64,1),
	 ('7L4SKPGMd33lnSOq6PWyYg==','game 3','uk',30,false,'2022-12-01',70.14,NULL,'2023-01-01',NULL,NULL,'2022-11-01',70.14,1,70.14,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',70.14,1),
	 ('7luG+f1d+Ri4AjeMbFR1Xw==','game 3','uk',29,false,'2022-04-01',16.92,NULL,'2022-05-01','2022-09-01',NULL,'2022-03-01',16.92,1,16.92,1,'2022-05-01',NULL,NULL,NULL,NULL,'2022-04-01','2022-09-01',31.98,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('7luG+f1d+Ri4AjeMbFR1Xw==','game 3','uk',29,false,'2022-09-01',15.06,'2022-04-01','2022-10-01',NULL,16.92,'2022-08-01',15.06,1,NULL,NULL,'2022-10-01',NULL,NULL,15.06,1,'2022-04-01','2022-09-01',31.98,6),
	 ('7RkS5ikrXwWByJobMXv2sA==','game 3','ru',21,false,'2022-10-01',25.89,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,25.89,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',180.57,3),
	 ('7RkS5ikrXwWByJobMXv2sA==','game 3','ru',21,false,'2022-11-01',87.75,'2022-10-01','2022-12-01','2022-12-01',25.89,'2022-10-01',NULL,NULL,NULL,NULL,NULL,61.86,NULL,NULL,NULL,'2022-10-01','2022-12-01',180.57,3),
	 ('7RkS5ikrXwWByJobMXv2sA==','game 3','ru',21,false,'2022-12-01',66.93,'2022-11-01','2023-01-01',NULL,87.75,'2022-11-01',66.93,1,NULL,NULL,'2023-01-01',NULL,-20.82,NULL,NULL,'2022-10-01','2022-12-01',180.57,3),
	 ('7SeM1pmnTTTXfhI+x3ldng==','game 3','ru',22,false,'2022-03-01',34.74,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,34.74,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-12-01',501.48,10),
	 ('7SeM1pmnTTTXfhI+x3ldng==','game 3','ru',22,false,'2022-04-01',105.96,'2022-03-01','2022-05-01','2022-05-01',34.74,'2022-03-01',NULL,NULL,NULL,NULL,NULL,71.22,NULL,NULL,NULL,'2022-03-01','2022-12-01',501.48,10),
	 ('7SeM1pmnTTTXfhI+x3ldng==','game 3','ru',22,false,'2022-05-01',62.61,'2022-04-01','2022-06-01','2022-07-01',105.96,'2022-04-01',62.61,1,NULL,NULL,'2022-06-01',NULL,-43.35,NULL,NULL,'2022-03-01','2022-12-01',501.48,10),
	 ('7SeM1pmnTTTXfhI+x3ldng==','game 3','ru',22,false,'2022-07-01',82.32,'2022-05-01','2022-08-01','2022-08-01',62.61,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,82.32,1,'2022-03-01','2022-12-01',501.48,10),
	 ('7SeM1pmnTTTXfhI+x3ldng==','game 3','ru',22,false,'2022-08-01',55.56,'2022-07-01','2022-09-01','2022-09-01',82.32,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-26.76,NULL,NULL,'2022-03-01','2022-12-01',501.48,10),
	 ('7SeM1pmnTTTXfhI+x3ldng==','game 3','ru',22,false,'2022-09-01',22.71,'2022-08-01','2022-10-01','2022-10-01',55.56,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-32.85,NULL,NULL,'2022-03-01','2022-12-01',501.48,10);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('7SeM1pmnTTTXfhI+x3ldng==','game 3','ru',22,false,'2022-10-01',37.44,'2022-09-01','2022-11-01','2022-11-01',22.71,'2022-09-01',NULL,NULL,NULL,NULL,NULL,14.73,NULL,NULL,NULL,'2022-03-01','2022-12-01',501.48,10),
	 ('7SeM1pmnTTTXfhI+x3ldng==','game 3','ru',22,false,'2022-11-01',84.15,'2022-10-01','2022-12-01','2022-12-01',37.44,'2022-10-01',NULL,NULL,NULL,NULL,NULL,46.71,NULL,NULL,NULL,'2022-03-01','2022-12-01',501.48,10),
	 ('7SeM1pmnTTTXfhI+x3ldng==','game 3','ru',22,false,'2022-12-01',15.99,'2022-11-01','2023-01-01',NULL,84.15,'2022-11-01',15.99,1,NULL,NULL,'2023-01-01',NULL,-68.16,NULL,NULL,'2022-03-01','2022-12-01',501.48,10),
	 ('7vnYIRqjBNlAyBbtPg02tQ==','game 3','uk',21,false,'2022-07-01',31.59,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,31.59,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',415.92,6),
	 ('7vnYIRqjBNlAyBbtPg02tQ==','game 3','uk',21,false,'2022-08-01',82.08,'2022-07-01','2022-09-01','2022-09-01',31.59,'2022-07-01',NULL,NULL,NULL,NULL,NULL,50.49,NULL,NULL,NULL,'2022-07-01','2022-12-01',415.92,6),
	 ('7vnYIRqjBNlAyBbtPg02tQ==','game 3','uk',21,false,'2022-09-01',73.29,'2022-08-01','2022-10-01','2022-10-01',82.08,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-8.79,NULL,NULL,'2022-07-01','2022-12-01',415.92,6),
	 ('7vnYIRqjBNlAyBbtPg02tQ==','game 3','uk',21,false,'2022-10-01',158.16,'2022-09-01','2022-11-01','2022-11-01',73.29,'2022-09-01',NULL,NULL,NULL,NULL,NULL,84.87,NULL,NULL,NULL,'2022-07-01','2022-12-01',415.92,6),
	 ('7vnYIRqjBNlAyBbtPg02tQ==','game 3','uk',21,false,'2022-11-01',23.49,'2022-10-01','2022-12-01','2022-12-01',158.16,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-134.67,NULL,NULL,'2022-07-01','2022-12-01',415.92,6),
	 ('7vnYIRqjBNlAyBbtPg02tQ==','game 3','uk',21,false,'2022-12-01',47.31,'2022-11-01','2023-01-01',NULL,23.49,'2022-11-01',47.31,1,NULL,NULL,'2023-01-01',23.82,NULL,NULL,NULL,'2022-07-01','2022-12-01',415.92,6),
	 ('7YaJfLI3RPGUEN2esrQxsQ==','game 3','ru',15,false,'2022-09-01',35.28,NULL,'2022-10-01','2022-12-01',NULL,'2022-08-01',35.28,1,35.28,1,'2022-10-01',NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',61.95,4);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('7YaJfLI3RPGUEN2esrQxsQ==','game 3','ru',15,false,'2022-12-01',26.67,'2022-09-01','2023-01-01',NULL,35.28,'2022-11-01',26.67,1,NULL,NULL,'2023-01-01',NULL,NULL,26.67,1,'2022-09-01','2022-12-01',61.95,4),
	 ('7zai/c69uF/NhB95HgKuYw==','game 3','uk',16,false,'2022-07-01',62.25,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,62.25,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-11-01',249.69,5),
	 ('7zai/c69uF/NhB95HgKuYw==','game 3','uk',16,false,'2022-08-01',75.15,'2022-07-01','2022-09-01','2022-09-01',62.25,'2022-07-01',NULL,NULL,NULL,NULL,NULL,12.90,NULL,NULL,NULL,'2022-07-01','2022-11-01',249.69,5),
	 ('7zai/c69uF/NhB95HgKuYw==','game 3','uk',16,false,'2022-09-01',48.48,'2022-08-01','2022-10-01','2022-10-01',75.15,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-26.67,NULL,NULL,'2022-07-01','2022-11-01',249.69,5),
	 ('7zai/c69uF/NhB95HgKuYw==','game 3','uk',16,false,'2022-10-01',22.77,'2022-09-01','2022-11-01','2022-11-01',48.48,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-25.71,NULL,NULL,'2022-07-01','2022-11-01',249.69,5),
	 ('7zai/c69uF/NhB95HgKuYw==','game 3','uk',16,false,'2022-11-01',41.04,'2022-10-01','2022-12-01',NULL,22.77,'2022-10-01',41.04,1,NULL,NULL,'2022-12-01',18.27,NULL,NULL,NULL,'2022-07-01','2022-11-01',249.69,5),
	 ('7zbxKst2yi3pfdVI8iEChw==','game 3','ru',15,false,'2022-04-01',23.31,NULL,'2022-05-01','2022-06-01',NULL,'2022-03-01',23.31,1,23.31,1,'2022-05-01',NULL,NULL,NULL,NULL,'2022-04-01','2022-12-01',67.71,9),
	 ('7zbxKst2yi3pfdVI8iEChw==','game 3','ru',15,false,'2022-06-01',13.05,'2022-04-01','2022-07-01','2022-08-01',23.31,'2022-05-01',13.05,1,NULL,NULL,'2022-07-01',NULL,NULL,13.05,1,'2022-04-01','2022-12-01',67.71,9),
	 ('7zbxKst2yi3pfdVI8iEChw==','game 3','ru',15,false,'2022-08-01',18.3,'2022-06-01','2022-09-01','2022-12-01',13.05,'2022-07-01',18.3,1,NULL,NULL,'2022-09-01',NULL,NULL,18.3,1,'2022-04-01','2022-12-01',67.71,9),
	 ('7zbxKst2yi3pfdVI8iEChw==','game 3','ru',15,false,'2022-12-01',13.05,'2022-08-01','2023-01-01',NULL,18.3,'2022-11-01',13.05,1,NULL,NULL,'2023-01-01',NULL,NULL,13.05,1,'2022-04-01','2022-12-01',67.71,9);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('8ncYOMYXeKDelzX40EnuLA==','game 3','uk',19,false,'2022-07-01',86.94,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,86.94,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',432.84,6),
	 ('8ncYOMYXeKDelzX40EnuLA==','game 3','uk',19,false,'2022-08-01',158.76,'2022-07-01','2022-09-01','2022-09-01',86.94,'2022-07-01',NULL,NULL,NULL,NULL,NULL,71.82,NULL,NULL,NULL,'2022-07-01','2022-12-01',432.84,6),
	 ('8ncYOMYXeKDelzX40EnuLA==','game 3','uk',19,false,'2022-09-01',35.61,'2022-08-01','2022-10-01','2022-11-01',158.76,'2022-08-01',35.61,1,NULL,NULL,'2022-10-01',NULL,-123.15,NULL,NULL,'2022-07-01','2022-12-01',432.84,6),
	 ('8ncYOMYXeKDelzX40EnuLA==','game 3','uk',19,false,'2022-11-01',33.57,'2022-09-01','2022-12-01','2022-12-01',35.61,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,33.57,1,'2022-07-01','2022-12-01',432.84,6),
	 ('8ncYOMYXeKDelzX40EnuLA==','game 3','uk',19,false,'2022-12-01',117.96,'2022-11-01','2023-01-01',NULL,33.57,'2022-11-01',117.96,1,NULL,NULL,'2023-01-01',84.39,NULL,NULL,NULL,'2022-07-01','2022-12-01',432.84,6),
	 ('8TTRdxncZg7Nl0tvfwsZng==','game 3','uk',30,false,'2022-05-01',14.25,NULL,'2022-06-01',NULL,NULL,'2022-04-01',14.25,1,14.25,1,'2022-06-01',NULL,NULL,NULL,NULL,'2022-05-01','2022-05-01',14.25,1),
	 ('99X4aLWWjAIgmlXjrXQIgg==','game 3','ru',22,false,'2022-03-01',16.98,NULL,'2022-04-01',NULL,NULL,'2022-02-01',16.98,1,16.98,1,'2022-04-01',NULL,NULL,NULL,NULL,'2022-03-01','2022-03-01',16.98,1),
	 ('9I0ppB2UxsJPIO8BpHQfEw==','game 3','uk',26,false,'2022-10-01',16.17,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,16.17,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-11-01',42.93,2),
	 ('9I0ppB2UxsJPIO8BpHQfEw==','game 3','uk',26,false,'2022-11-01',26.76,'2022-10-01','2022-12-01',NULL,16.17,'2022-10-01',26.76,1,NULL,NULL,'2022-12-01',10.59,NULL,NULL,NULL,'2022-10-01','2022-11-01',42.93,2),
	 ('9IWUQ1iWPfYSSN2tWuVqMQ==','game 3','ru',24,false,'2022-05-01',12.48,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,12.48,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-12-01',402.24,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('9IWUQ1iWPfYSSN2tWuVqMQ==','game 3','ru',24,false,'2022-06-01',88.08,'2022-05-01','2022-07-01','2022-07-01',12.48,'2022-05-01',NULL,NULL,NULL,NULL,NULL,75.60,NULL,NULL,NULL,'2022-05-01','2022-12-01',402.24,8),
	 ('9IWUQ1iWPfYSSN2tWuVqMQ==','game 3','ru',24,false,'2022-07-01',120.75,'2022-06-01','2022-08-01','2022-08-01',88.08,'2022-06-01',NULL,NULL,NULL,NULL,NULL,32.67,NULL,NULL,NULL,'2022-05-01','2022-12-01',402.24,8),
	 ('9IWUQ1iWPfYSSN2tWuVqMQ==','game 3','ru',24,false,'2022-08-01',46.29,'2022-07-01','2022-09-01','2022-09-01',120.75,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-74.46,NULL,NULL,'2022-05-01','2022-12-01',402.24,8),
	 ('9IWUQ1iWPfYSSN2tWuVqMQ==','game 3','ru',24,false,'2022-09-01',15.63,'2022-08-01','2022-10-01','2022-10-01',46.29,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-30.66,NULL,NULL,'2022-05-01','2022-12-01',402.24,8),
	 ('9IWUQ1iWPfYSSN2tWuVqMQ==','game 3','ru',24,false,'2022-10-01',17.37,'2022-09-01','2022-11-01','2022-11-01',15.63,'2022-09-01',NULL,NULL,NULL,NULL,NULL,1.74,NULL,NULL,NULL,'2022-05-01','2022-12-01',402.24,8),
	 ('9IWUQ1iWPfYSSN2tWuVqMQ==','game 3','ru',24,false,'2022-11-01',71.52,'2022-10-01','2022-12-01','2022-12-01',17.37,'2022-10-01',NULL,NULL,NULL,NULL,NULL,54.15,NULL,NULL,NULL,'2022-05-01','2022-12-01',402.24,8),
	 ('9IWUQ1iWPfYSSN2tWuVqMQ==','game 3','ru',24,false,'2022-12-01',30.12,'2022-11-01','2023-01-01',NULL,71.52,'2022-11-01',30.12,1,NULL,NULL,'2023-01-01',NULL,-41.40,NULL,NULL,'2022-05-01','2022-12-01',402.24,8),
	 ('9U26VpwYC1aliSUokeNK6A==','game 3','uk',34,false,'2022-11-01',53.07,NULL,'2022-12-01','2022-12-01',NULL,'2022-10-01',NULL,NULL,53.07,1,NULL,NULL,NULL,NULL,NULL,'2022-11-01','2022-12-01',67.41,2),
	 ('9U26VpwYC1aliSUokeNK6A==','game 3','uk',34,false,'2022-12-01',14.34,'2022-11-01','2023-01-01',NULL,53.07,'2022-11-01',14.34,1,NULL,NULL,'2023-01-01',NULL,-38.73,NULL,NULL,'2022-11-01','2022-12-01',67.41,2),
	 ('A1qVjssGQ+ZUWZu3Z5DzTA==','game 3','uk',24,false,'2022-03-01',45.27,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,45.27,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-10-01',331.26,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('A1qVjssGQ+ZUWZu3Z5DzTA==','game 3','uk',24,false,'2022-04-01',13.95,'2022-03-01','2022-05-01','2022-06-01',45.27,'2022-03-01',13.95,1,NULL,NULL,'2022-05-01',NULL,-31.32,NULL,NULL,'2022-03-01','2022-10-01',331.26,8),
	 ('A1qVjssGQ+ZUWZu3Z5DzTA==','game 3','uk',24,false,'2022-06-01',107.40,'2022-04-01','2022-07-01','2022-07-01',13.95,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,107.40,1,'2022-03-01','2022-10-01',331.26,8),
	 ('A1qVjssGQ+ZUWZu3Z5DzTA==','game 3','uk',24,false,'2022-07-01',64.44,'2022-06-01','2022-08-01','2022-08-01',107.40,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-42.96,NULL,NULL,'2022-03-01','2022-10-01',331.26,8),
	 ('A1qVjssGQ+ZUWZu3Z5DzTA==','game 3','uk',24,false,'2022-08-01',15.21,'2022-07-01','2022-09-01','2022-09-01',64.44,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-49.23,NULL,NULL,'2022-03-01','2022-10-01',331.26,8),
	 ('A1qVjssGQ+ZUWZu3Z5DzTA==','game 3','uk',24,false,'2022-09-01',19.56,'2022-08-01','2022-10-01','2022-10-01',15.21,'2022-08-01',NULL,NULL,NULL,NULL,NULL,4.35,NULL,NULL,NULL,'2022-03-01','2022-10-01',331.26,8),
	 ('A1qVjssGQ+ZUWZu3Z5DzTA==','game 3','uk',24,false,'2022-10-01',65.43,'2022-09-01','2022-11-01',NULL,19.56,'2022-09-01',65.43,1,NULL,NULL,'2022-11-01',45.87,NULL,NULL,NULL,'2022-03-01','2022-10-01',331.26,8),
	 ('A6QTeGOKjaGkGkRCFqNybw==','game 3','ru',33,false,'2022-08-01',43.86,NULL,'2022-09-01',NULL,NULL,'2022-07-01',43.86,1,43.86,1,'2022-09-01',NULL,NULL,NULL,NULL,'2022-08-01','2022-08-01',43.86,1),
	 ('A8lK1Lccnv65sGqBkfP2iw==','game 3','uk',15,false,'2022-12-01',16.08,NULL,'2023-01-01',NULL,NULL,'2022-11-01',16.08,1,16.08,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',16.08,1),
	 ('ABuPH1LovAomZwU+2iw0Lw==','game 3','uk',18,false,'2022-08-01',51.00,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,51.00,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',223.65,5),
	 ('ABuPH1LovAomZwU+2iw0Lw==','game 3','uk',18,false,'2022-09-01',19.56,'2022-08-01','2022-10-01','2022-11-01',51.00,'2022-08-01',19.56,1,NULL,NULL,'2022-10-01',NULL,-31.44,NULL,NULL,'2022-08-01','2022-12-01',223.65,5);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('ABuPH1LovAomZwU+2iw0Lw==','game 3','uk',18,false,'2022-11-01',105.99,'2022-09-01','2022-12-01','2022-12-01',19.56,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,105.99,1,'2022-08-01','2022-12-01',223.65,5),
	 ('ABuPH1LovAomZwU+2iw0Lw==','game 3','uk',18,false,'2022-12-01',47.10,'2022-11-01','2023-01-01',NULL,105.99,'2022-11-01',47.10,1,NULL,NULL,'2023-01-01',NULL,-58.89,NULL,NULL,'2022-08-01','2022-12-01',223.65,5),
	 ('an5Xsrpir8vvhTb50gnppQ==','game 3','uk',43,false,'2022-05-01',15.51,NULL,'2022-06-01',NULL,NULL,'2022-04-01',15.51,1,15.51,1,'2022-06-01',NULL,NULL,NULL,NULL,'2022-05-01','2022-05-01',15.51,1),
	 ('An7gG7hfETivAjfokQv3Ww==','game 3','uk',23,false,'2022-07-01',45.03,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,45.03,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',281.34,6),
	 ('An7gG7hfETivAjfokQv3Ww==','game 3','uk',23,false,'2022-08-01',90.99,'2022-07-01','2022-09-01','2022-09-01',45.03,'2022-07-01',NULL,NULL,NULL,NULL,NULL,45.96,NULL,NULL,NULL,'2022-07-01','2022-12-01',281.34,6),
	 ('An7gG7hfETivAjfokQv3Ww==','game 3','uk',23,false,'2022-09-01',47.52,'2022-08-01','2022-10-01','2022-10-01',90.99,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-43.47,NULL,NULL,'2022-07-01','2022-12-01',281.34,6),
	 ('An7gG7hfETivAjfokQv3Ww==','game 3','uk',23,false,'2022-10-01',18.9,'2022-09-01','2022-11-01','2022-11-01',47.52,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-28.62,NULL,NULL,'2022-07-01','2022-12-01',281.34,6),
	 ('An7gG7hfETivAjfokQv3Ww==','game 3','uk',23,false,'2022-11-01',61.29,'2022-10-01','2022-12-01','2022-12-01',18.9,'2022-10-01',NULL,NULL,NULL,NULL,NULL,42.39,NULL,NULL,NULL,'2022-07-01','2022-12-01',281.34,6),
	 ('An7gG7hfETivAjfokQv3Ww==','game 3','uk',23,false,'2022-12-01',17.61,'2022-11-01','2023-01-01',NULL,61.29,'2022-11-01',17.61,1,NULL,NULL,'2023-01-01',NULL,-43.68,NULL,NULL,'2022-07-01','2022-12-01',281.34,6),
	 ('AN9at3LlvDamqXq8dvHD4w==','game 3','ru',24,false,'2022-03-01',42.03,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,42.03,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-12-01',455.70,10);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('AN9at3LlvDamqXq8dvHD4w==','game 3','ru',24,false,'2022-04-01',64.50,'2022-03-01','2022-05-01','2022-05-01',42.03,'2022-03-01',NULL,NULL,NULL,NULL,NULL,22.47,NULL,NULL,NULL,'2022-03-01','2022-12-01',455.70,10),
	 ('AN9at3LlvDamqXq8dvHD4w==','game 3','ru',24,false,'2022-05-01',66.57,'2022-04-01','2022-06-01','2022-06-01',64.50,'2022-04-01',NULL,NULL,NULL,NULL,NULL,2.07,NULL,NULL,NULL,'2022-03-01','2022-12-01',455.70,10),
	 ('AN9at3LlvDamqXq8dvHD4w==','game 3','ru',24,false,'2022-06-01',18.99,'2022-05-01','2022-07-01','2022-07-01',66.57,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-47.58,NULL,NULL,'2022-03-01','2022-12-01',455.70,10),
	 ('AN9at3LlvDamqXq8dvHD4w==','game 3','ru',24,false,'2022-07-01',13.71,'2022-06-01','2022-08-01','2022-08-01',18.99,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-5.28,NULL,NULL,'2022-03-01','2022-12-01',455.70,10),
	 ('AN9at3LlvDamqXq8dvHD4w==','game 3','ru',24,false,'2022-08-01',43.23,'2022-07-01','2022-09-01','2022-09-01',13.71,'2022-07-01',NULL,NULL,NULL,NULL,NULL,29.52,NULL,NULL,NULL,'2022-03-01','2022-12-01',455.70,10),
	 ('AN9at3LlvDamqXq8dvHD4w==','game 3','ru',24,false,'2022-09-01',63.93,'2022-08-01','2022-10-01','2022-10-01',43.23,'2022-08-01',NULL,NULL,NULL,NULL,NULL,20.70,NULL,NULL,NULL,'2022-03-01','2022-12-01',455.70,10),
	 ('AN9at3LlvDamqXq8dvHD4w==','game 3','ru',24,false,'2022-10-01',13.83,'2022-09-01','2022-11-01','2022-11-01',63.93,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-50.10,NULL,NULL,'2022-03-01','2022-12-01',455.70,10),
	 ('AN9at3LlvDamqXq8dvHD4w==','game 3','ru',24,false,'2022-11-01',68.97,'2022-10-01','2022-12-01','2022-12-01',13.83,'2022-10-01',NULL,NULL,NULL,NULL,NULL,55.14,NULL,NULL,NULL,'2022-03-01','2022-12-01',455.70,10),
	 ('AN9at3LlvDamqXq8dvHD4w==','game 3','ru',24,false,'2022-12-01',59.94,'2022-11-01','2023-01-01',NULL,68.97,'2022-11-01',59.94,1,NULL,NULL,'2023-01-01',NULL,-9.03,NULL,NULL,'2022-03-01','2022-12-01',455.70,10),
	 ('/ANyXfGUGtUS/bPw0/nW/w==','game 3','uk',28,false,'2022-11-01',33.06,NULL,'2022-12-01',NULL,NULL,'2022-10-01',33.06,1,33.06,1,'2022-12-01',NULL,NULL,NULL,NULL,'2022-11-01','2022-11-01',33.06,1);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('aQDvOXzsDAJWi3Y47ptRPg==','game 3','ru',20,false,'2022-04-01',15.21,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,15.21,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-06-01',73.59,3),
	 ('aQDvOXzsDAJWi3Y47ptRPg==','game 3','ru',20,false,'2022-05-01',39.30,'2022-04-01','2022-06-01','2022-06-01',15.21,'2022-04-01',NULL,NULL,NULL,NULL,NULL,24.09,NULL,NULL,NULL,'2022-04-01','2022-06-01',73.59,3),
	 ('aQDvOXzsDAJWi3Y47ptRPg==','game 3','ru',20,false,'2022-06-01',19.08,'2022-05-01','2022-07-01',NULL,39.30,'2022-05-01',19.08,1,NULL,NULL,'2022-07-01',NULL,-20.22,NULL,NULL,'2022-04-01','2022-06-01',73.59,3),
	 ('aujnuJ9eBYK+yGF15TtUkw==','game 2','en',35,false,'2022-09-01',33.57,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,33.57,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-10-01',46.26,2),
	 ('aujnuJ9eBYK+yGF15TtUkw==','game 2','en',35,false,'2022-10-01',12.69,'2022-09-01','2022-11-01',NULL,33.57,'2022-09-01',12.69,1,NULL,NULL,'2022-11-01',NULL,-20.88,NULL,NULL,'2022-09-01','2022-10-01',46.26,2),
	 ('AuJNw7SH8b7lM4j46bNr8A==','game 3','en',28,false,'2022-09-01',18.33,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,18.33,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',199.86,4),
	 ('AuJNw7SH8b7lM4j46bNr8A==','game 3','en',28,false,'2022-10-01',25.77,'2022-09-01','2022-11-01','2022-11-01',18.33,'2022-09-01',NULL,NULL,NULL,NULL,NULL,7.44,NULL,NULL,NULL,'2022-09-01','2022-12-01',199.86,4),
	 ('AuJNw7SH8b7lM4j46bNr8A==','game 3','en',28,false,'2022-11-01',122.97,'2022-10-01','2022-12-01','2022-12-01',25.77,'2022-10-01',NULL,NULL,NULL,NULL,NULL,97.20,NULL,NULL,NULL,'2022-09-01','2022-12-01',199.86,4),
	 ('AuJNw7SH8b7lM4j46bNr8A==','game 3','en',28,false,'2022-12-01',32.79,'2022-11-01','2023-01-01',NULL,122.97,'2022-11-01',32.79,1,NULL,NULL,'2023-01-01',NULL,-90.18,NULL,NULL,'2022-09-01','2022-12-01',199.86,4),
	 ('+Awa0l8QDZ6iKBSRiA6dRQ==','game 3','ru',16,false,'2022-10-01',69.90,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,69.90,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-11-01',112.98,2);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('+Awa0l8QDZ6iKBSRiA6dRQ==','game 3','ru',16,false,'2022-11-01',43.08,'2022-10-01','2022-12-01',NULL,69.90,'2022-10-01',43.08,1,NULL,NULL,'2022-12-01',NULL,-26.82,NULL,NULL,'2022-10-01','2022-11-01',112.98,2),
	 ('b3TBQFxyCxxypmPajF+jXw==','game 3','uk',15,true,'2022-03-01',13.98,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,13.98,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-06-01',128.79,4),
	 ('b3TBQFxyCxxypmPajF+jXw==','game 3','uk',15,true,'2022-04-01',14.82,'2022-03-01','2022-05-01','2022-05-01',13.98,'2022-03-01',NULL,NULL,NULL,NULL,NULL,0.84,NULL,NULL,NULL,'2022-03-01','2022-06-01',128.79,4),
	 ('b3TBQFxyCxxypmPajF+jXw==','game 3','uk',15,true,'2022-05-01',28.68,'2022-04-01','2022-06-01','2022-06-01',14.82,'2022-04-01',NULL,NULL,NULL,NULL,NULL,13.86,NULL,NULL,NULL,'2022-03-01','2022-06-01',128.79,4),
	 ('b3TBQFxyCxxypmPajF+jXw==','game 3','uk',15,true,'2022-06-01',71.31,'2022-05-01','2022-07-01',NULL,28.68,'2022-05-01',71.31,1,NULL,NULL,'2022-07-01',42.63,NULL,NULL,NULL,'2022-03-01','2022-06-01',128.79,4),
	 ('B4b6v6eUHvAVOeAQk6EEiw==','game 3','ru',23,false,'2022-03-01',15.3,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,15.3,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-12-01',385.41,10),
	 ('B4b6v6eUHvAVOeAQk6EEiw==','game 3','ru',23,false,'2022-04-01',63.60,'2022-03-01','2022-05-01','2022-06-01',15.3,'2022-03-01',63.60,1,NULL,NULL,'2022-05-01',48.30,NULL,NULL,NULL,'2022-03-01','2022-12-01',385.41,10),
	 ('B4b6v6eUHvAVOeAQk6EEiw==','game 3','ru',23,false,'2022-06-01',96.33,'2022-04-01','2022-07-01','2022-07-01',63.60,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,96.33,1,'2022-03-01','2022-12-01',385.41,10),
	 ('B4b6v6eUHvAVOeAQk6EEiw==','game 3','ru',23,false,'2022-07-01',20.79,'2022-06-01','2022-08-01','2022-08-01',96.33,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-75.54,NULL,NULL,'2022-03-01','2022-12-01',385.41,10),
	 ('B4b6v6eUHvAVOeAQk6EEiw==','game 3','ru',23,false,'2022-08-01',64.80,'2022-07-01','2022-09-01','2022-09-01',20.79,'2022-07-01',NULL,NULL,NULL,NULL,NULL,44.01,NULL,NULL,NULL,'2022-03-01','2022-12-01',385.41,10);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('B4b6v6eUHvAVOeAQk6EEiw==','game 3','ru',23,false,'2022-09-01',44.67,'2022-08-01','2022-10-01','2022-10-01',64.80,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-20.13,NULL,NULL,'2022-03-01','2022-12-01',385.41,10),
	 ('B4b6v6eUHvAVOeAQk6EEiw==','game 3','ru',23,false,'2022-10-01',59.28,'2022-09-01','2022-11-01','2022-12-01',44.67,'2022-09-01',59.28,1,NULL,NULL,'2022-11-01',14.61,NULL,NULL,NULL,'2022-03-01','2022-12-01',385.41,10),
	 ('B4b6v6eUHvAVOeAQk6EEiw==','game 3','ru',23,false,'2022-12-01',20.64,'2022-10-01','2023-01-01',NULL,59.28,'2022-11-01',20.64,1,NULL,NULL,'2023-01-01',NULL,NULL,20.64,1,'2022-03-01','2022-12-01',385.41,10),
	 ('B4tGKx0IrkPGAUEnO6mMNA==','game 3','uk',19,false,'2022-11-01',55.08,NULL,'2022-12-01','2022-12-01',NULL,'2022-10-01',NULL,NULL,55.08,1,NULL,NULL,NULL,NULL,NULL,'2022-11-01','2022-12-01',69.45,2),
	 ('B4tGKx0IrkPGAUEnO6mMNA==','game 3','uk',19,false,'2022-12-01',14.37,'2022-11-01','2023-01-01',NULL,55.08,'2022-11-01',14.37,1,NULL,NULL,'2023-01-01',NULL,-40.71,NULL,NULL,'2022-11-01','2022-12-01',69.45,2),
	 ('b6lW5fOrJiJUE7dwhEp9VQ==','game 3','ru',17,false,'2022-05-01',94.11,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,94.11,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-12-01',432.60,8),
	 ('b6lW5fOrJiJUE7dwhEp9VQ==','game 3','ru',17,false,'2022-06-01',41.07,'2022-05-01','2022-07-01','2022-07-01',94.11,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-53.04,NULL,NULL,'2022-05-01','2022-12-01',432.60,8),
	 ('b6lW5fOrJiJUE7dwhEp9VQ==','game 3','ru',17,false,'2022-07-01',15.21,'2022-06-01','2022-08-01','2022-08-01',41.07,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-25.86,NULL,NULL,'2022-05-01','2022-12-01',432.60,8),
	 ('b6lW5fOrJiJUE7dwhEp9VQ==','game 3','ru',17,false,'2022-08-01',73.38,'2022-07-01','2022-09-01','2022-09-01',15.21,'2022-07-01',NULL,NULL,NULL,NULL,NULL,58.17,NULL,NULL,NULL,'2022-05-01','2022-12-01',432.60,8),
	 ('b6lW5fOrJiJUE7dwhEp9VQ==','game 3','ru',17,false,'2022-09-01',18.24,'2022-08-01','2022-10-01','2022-10-01',73.38,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-55.14,NULL,NULL,'2022-05-01','2022-12-01',432.60,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('b6lW5fOrJiJUE7dwhEp9VQ==','game 3','ru',17,false,'2022-10-01',46.20,'2022-09-01','2022-11-01','2022-11-01',18.24,'2022-09-01',NULL,NULL,NULL,NULL,NULL,27.96,NULL,NULL,NULL,'2022-05-01','2022-12-01',432.60,8),
	 ('b6lW5fOrJiJUE7dwhEp9VQ==','game 3','ru',17,false,'2022-11-01',102.18,'2022-10-01','2022-12-01','2022-12-01',46.20,'2022-10-01',NULL,NULL,NULL,NULL,NULL,55.98,NULL,NULL,NULL,'2022-05-01','2022-12-01',432.60,8),
	 ('b6lW5fOrJiJUE7dwhEp9VQ==','game 3','ru',17,false,'2022-12-01',42.21,'2022-11-01','2023-01-01',NULL,102.18,'2022-11-01',42.21,1,NULL,NULL,'2023-01-01',NULL,-59.97,NULL,NULL,'2022-05-01','2022-12-01',432.60,8),
	 ('B7ziVc7jLVg/+snNIp3hLQ==','game 3','uk',19,false,'2022-07-01',13.71,NULL,'2022-08-01',NULL,NULL,'2022-06-01',13.71,1,13.71,1,'2022-08-01',NULL,NULL,NULL,NULL,'2022-07-01','2022-07-01',13.71,1),
	 ('b85g/xLxpBpMH/joxym4fA==','game 3','uk',28,false,'2022-11-01',26.94,NULL,'2022-12-01',NULL,NULL,'2022-10-01',26.94,1,26.94,1,'2022-12-01',NULL,NULL,NULL,NULL,'2022-11-01','2022-11-01',26.94,1),
	 ('B8zuTsAC2iJ98u2nlv/fUw==','game 3','uk',21,true,'2022-05-01',39.96,NULL,'2022-06-01','2022-10-01',NULL,'2022-04-01',39.96,1,39.96,1,'2022-06-01',NULL,NULL,NULL,NULL,'2022-05-01','2022-10-01',96.24,6),
	 ('B8zuTsAC2iJ98u2nlv/fUw==','game 3','uk',21,true,'2022-10-01',56.28,'2022-05-01','2022-11-01',NULL,39.96,'2022-09-01',56.28,1,NULL,NULL,'2022-11-01',NULL,NULL,56.28,1,'2022-05-01','2022-10-01',96.24,6),
	 ('BbnuW+2kIgxo7dxg5BBIeQ==','game 3','ru',17,false,'2022-10-01',37.08,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,37.08,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',211.56,3),
	 ('BbnuW+2kIgxo7dxg5BBIeQ==','game 3','ru',17,false,'2022-11-01',53.07,'2022-10-01','2022-12-01','2022-12-01',37.08,'2022-10-01',NULL,NULL,NULL,NULL,NULL,15.99,NULL,NULL,NULL,'2022-10-01','2022-12-01',211.56,3),
	 ('BbnuW+2kIgxo7dxg5BBIeQ==','game 3','ru',17,false,'2022-12-01',121.41,'2022-11-01','2023-01-01',NULL,53.07,'2022-11-01',121.41,1,NULL,NULL,'2023-01-01',68.34,NULL,NULL,NULL,'2022-10-01','2022-12-01',211.56,3);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('bBOj8UKjraXzMIPrGBdCrQ==','game 3','uk',28,false,'2022-08-01',27.60,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,27.60,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',124.05,5),
	 ('bBOj8UKjraXzMIPrGBdCrQ==','game 3','uk',28,false,'2022-09-01',29.07,'2022-08-01','2022-10-01','2022-10-01',27.60,'2022-08-01',NULL,NULL,NULL,NULL,NULL,1.47,NULL,NULL,NULL,'2022-08-01','2022-12-01',124.05,5),
	 ('bBOj8UKjraXzMIPrGBdCrQ==','game 3','uk',28,false,'2022-10-01',12.21,'2022-09-01','2022-11-01','2022-11-01',29.07,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-16.86,NULL,NULL,'2022-08-01','2022-12-01',124.05,5),
	 ('bBOj8UKjraXzMIPrGBdCrQ==','game 3','uk',28,false,'2022-11-01',15.69,'2022-10-01','2022-12-01','2022-12-01',12.21,'2022-10-01',NULL,NULL,NULL,NULL,NULL,3.48,NULL,NULL,NULL,'2022-08-01','2022-12-01',124.05,5),
	 ('bBOj8UKjraXzMIPrGBdCrQ==','game 3','uk',28,false,'2022-12-01',39.48,'2022-11-01','2023-01-01',NULL,15.69,'2022-11-01',39.48,1,NULL,NULL,'2023-01-01',23.79,NULL,NULL,NULL,'2022-08-01','2022-12-01',124.05,5),
	 ('Bcs3CbYx2EpbL9otxlEUmg==','game 3','uk',18,true,'2022-03-01',89.22,NULL,'2022-04-01','2022-05-01',NULL,'2022-02-01',89.22,1,89.22,1,'2022-04-01',NULL,NULL,NULL,NULL,'2022-03-01','2022-10-01',504.15,8),
	 ('Bcs3CbYx2EpbL9otxlEUmg==','game 3','uk',18,true,'2022-05-01',30.72,'2022-03-01','2022-06-01','2022-06-01',89.22,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,30.72,1,'2022-03-01','2022-10-01',504.15,8),
	 ('Bcs3CbYx2EpbL9otxlEUmg==','game 3','uk',18,true,'2022-06-01',31.38,'2022-05-01','2022-07-01','2022-07-01',30.72,'2022-05-01',NULL,NULL,NULL,NULL,NULL,0.66,NULL,NULL,NULL,'2022-03-01','2022-10-01',504.15,8),
	 ('Bcs3CbYx2EpbL9otxlEUmg==','game 3','uk',18,true,'2022-07-01',106.59,'2022-06-01','2022-08-01','2022-08-01',31.38,'2022-06-01',NULL,NULL,NULL,NULL,NULL,75.21,NULL,NULL,NULL,'2022-03-01','2022-10-01',504.15,8),
	 ('Bcs3CbYx2EpbL9otxlEUmg==','game 3','uk',18,true,'2022-08-01',73.38,'2022-07-01','2022-09-01','2022-09-01',106.59,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-33.21,NULL,NULL,'2022-03-01','2022-10-01',504.15,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('Bcs3CbYx2EpbL9otxlEUmg==','game 3','uk',18,true,'2022-09-01',76.02,'2022-08-01','2022-10-01','2022-10-01',73.38,'2022-08-01',NULL,NULL,NULL,NULL,NULL,2.64,NULL,NULL,NULL,'2022-03-01','2022-10-01',504.15,8),
	 ('Bcs3CbYx2EpbL9otxlEUmg==','game 3','uk',18,true,'2022-10-01',96.84,'2022-09-01','2022-11-01',NULL,76.02,'2022-09-01',96.84,1,NULL,NULL,'2022-11-01',20.82,NULL,NULL,NULL,'2022-03-01','2022-10-01',504.15,8),
	 ('BDvlXttM/hbupcLic+5ZWg==','game 3','uk',29,false,'2022-05-01',12.93,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,12.93,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-12-01',199.98,8),
	 ('BDvlXttM/hbupcLic+5ZWg==','game 3','uk',29,false,'2022-06-01',46.53,'2022-05-01','2022-07-01','2022-08-01',12.93,'2022-05-01',46.53,1,NULL,NULL,'2022-07-01',33.60,NULL,NULL,NULL,'2022-05-01','2022-12-01',199.98,8),
	 ('BDvlXttM/hbupcLic+5ZWg==','game 3','uk',29,false,'2022-08-01',13.59,'2022-06-01','2022-09-01','2022-09-01',46.53,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,13.59,1,'2022-05-01','2022-12-01',199.98,8),
	 ('BDvlXttM/hbupcLic+5ZWg==','game 3','uk',29,false,'2022-09-01',41.55,'2022-08-01','2022-10-01','2022-10-01',13.59,'2022-08-01',NULL,NULL,NULL,NULL,NULL,27.96,NULL,NULL,NULL,'2022-05-01','2022-12-01',199.98,8),
	 ('BDvlXttM/hbupcLic+5ZWg==','game 3','uk',29,false,'2022-10-01',12.9,'2022-09-01','2022-11-01','2022-11-01',41.55,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-28.65,NULL,NULL,'2022-05-01','2022-12-01',199.98,8),
	 ('BDvlXttM/hbupcLic+5ZWg==','game 3','uk',29,false,'2022-11-01',58.98,'2022-10-01','2022-12-01','2022-12-01',12.9,'2022-10-01',NULL,NULL,NULL,NULL,NULL,46.08,NULL,NULL,NULL,'2022-05-01','2022-12-01',199.98,8),
	 ('BDvlXttM/hbupcLic+5ZWg==','game 3','uk',29,false,'2022-12-01',13.5,'2022-11-01','2023-01-01',NULL,58.98,'2022-11-01',13.5,1,NULL,NULL,'2023-01-01',NULL,-45.48,NULL,NULL,'2022-05-01','2022-12-01',199.98,8),
	 ('BE42Fj9cBAbbch80IpA8Dw==','game 3','uk',30,false,'2022-09-01',15.57,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,15.57,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-11-01',116.31,3);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('BE42Fj9cBAbbch80IpA8Dw==','game 3','uk',30,false,'2022-10-01',47.22,'2022-09-01','2022-11-01','2022-11-01',15.57,'2022-09-01',NULL,NULL,NULL,NULL,NULL,31.65,NULL,NULL,NULL,'2022-09-01','2022-11-01',116.31,3),
	 ('BE42Fj9cBAbbch80IpA8Dw==','game 3','uk',30,false,'2022-11-01',53.52,'2022-10-01','2022-12-01',NULL,47.22,'2022-10-01',53.52,1,NULL,NULL,'2022-12-01',6.30,NULL,NULL,NULL,'2022-09-01','2022-11-01',116.31,3),
	 ('bF11PeUgiQ6ebhHTaDNDJA==','game 3','ru',33,false,'2022-10-01',18.78,NULL,'2022-11-01',NULL,NULL,'2022-09-01',18.78,1,18.78,1,'2022-11-01',NULL,NULL,NULL,NULL,'2022-10-01','2022-10-01',18.78,1),
	 ('BH4aptg763J0WNnw0OS9hw==','game 3','ru',18,false,'2022-07-01',15.21,NULL,'2022-08-01',NULL,NULL,'2022-06-01',15.21,1,15.21,1,'2022-08-01',NULL,NULL,NULL,NULL,'2022-07-01','2022-07-01',15.21,1),
	 ('BJlqmsfEshc/QjsD7VgEjg==','game 3','ru',18,false,'2022-04-01',30.66,NULL,'2022-05-01','2022-06-01',NULL,'2022-03-01',30.66,1,30.66,1,'2022-05-01',NULL,NULL,NULL,NULL,'2022-04-01','2022-09-01',165.93,6),
	 ('BJlqmsfEshc/QjsD7VgEjg==','game 3','ru',18,false,'2022-06-01',113.76,'2022-04-01','2022-07-01','2022-09-01',30.66,'2022-05-01',113.76,1,NULL,NULL,'2022-07-01',NULL,NULL,113.76,1,'2022-04-01','2022-09-01',165.93,6),
	 ('BJlqmsfEshc/QjsD7VgEjg==','game 3','ru',18,false,'2022-09-01',21.51,'2022-06-01','2022-10-01',NULL,113.76,'2022-08-01',21.51,1,NULL,NULL,'2022-10-01',NULL,NULL,21.51,1,'2022-04-01','2022-09-01',165.93,6),
	 ('BLnx9pj0y+SVkckLR/01qw==','game 3','uk',25,false,'2022-09-01',41.55,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,41.55,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',185.04,4),
	 ('BLnx9pj0y+SVkckLR/01qw==','game 3','uk',25,false,'2022-10-01',85.20,'2022-09-01','2022-11-01','2022-11-01',41.55,'2022-09-01',NULL,NULL,NULL,NULL,NULL,43.65,NULL,NULL,NULL,'2022-09-01','2022-12-01',185.04,4),
	 ('BLnx9pj0y+SVkckLR/01qw==','game 3','uk',25,false,'2022-11-01',43.92,'2022-10-01','2022-12-01','2022-12-01',85.20,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-41.28,NULL,NULL,'2022-09-01','2022-12-01',185.04,4);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('BLnx9pj0y+SVkckLR/01qw==','game 3','uk',25,false,'2022-12-01',14.37,'2022-11-01','2023-01-01',NULL,43.92,'2022-11-01',14.37,1,NULL,NULL,'2023-01-01',NULL,-29.55,NULL,NULL,'2022-09-01','2022-12-01',185.04,4),
	 ('BOcGlFXXESDUbttxDzQIQw==','game 3','uk',32,false,'2022-08-01',88.29,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,88.29,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',290.19,5),
	 ('BOcGlFXXESDUbttxDzQIQw==','game 3','uk',32,false,'2022-09-01',99.45,'2022-08-01','2022-10-01','2022-10-01',88.29,'2022-08-01',NULL,NULL,NULL,NULL,NULL,11.16,NULL,NULL,NULL,'2022-08-01','2022-12-01',290.19,5),
	 ('BOcGlFXXESDUbttxDzQIQw==','game 3','uk',32,false,'2022-10-01',58.14,'2022-09-01','2022-11-01','2022-11-01',99.45,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-41.31,NULL,NULL,'2022-08-01','2022-12-01',290.19,5),
	 ('BOcGlFXXESDUbttxDzQIQw==','game 3','uk',32,false,'2022-11-01',27.42,'2022-10-01','2022-12-01','2022-12-01',58.14,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-30.72,NULL,NULL,'2022-08-01','2022-12-01',290.19,5),
	 ('BOcGlFXXESDUbttxDzQIQw==','game 3','uk',32,false,'2022-12-01',16.89,'2022-11-01','2023-01-01',NULL,27.42,'2022-11-01',16.89,1,NULL,NULL,'2023-01-01',NULL,-10.53,NULL,NULL,'2022-08-01','2022-12-01',290.19,5),
	 ('BTD3ZjLKfkT6ZRBT9zRwtg==','game 3','uk',14,true,'2022-05-01',65.73,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,65.73,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-12-01',264.96,8),
	 ('BTD3ZjLKfkT6ZRBT9zRwtg==','game 3','uk',14,true,'2022-06-01',46.20,'2022-05-01','2022-07-01','2022-07-01',65.73,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-19.53,NULL,NULL,'2022-05-01','2022-12-01',264.96,8),
	 ('BTD3ZjLKfkT6ZRBT9zRwtg==','game 3','uk',14,true,'2022-07-01',12.9,'2022-06-01','2022-08-01','2022-08-01',46.20,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-33.30,NULL,NULL,'2022-05-01','2022-12-01',264.96,8),
	 ('BTD3ZjLKfkT6ZRBT9zRwtg==','game 3','uk',14,true,'2022-08-01',35.79,'2022-07-01','2022-09-01','2022-10-01',12.9,'2022-07-01',35.79,1,NULL,NULL,'2022-09-01',22.89,NULL,NULL,NULL,'2022-05-01','2022-12-01',264.96,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('BTD3ZjLKfkT6ZRBT9zRwtg==','game 3','uk',14,true,'2022-10-01',27.00,'2022-08-01','2022-11-01','2022-11-01',35.79,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,27.00,1,'2022-05-01','2022-12-01',264.96,8),
	 ('BTD3ZjLKfkT6ZRBT9zRwtg==','game 3','uk',14,true,'2022-11-01',49.92,'2022-10-01','2022-12-01','2022-12-01',27.00,'2022-10-01',NULL,NULL,NULL,NULL,NULL,22.92,NULL,NULL,NULL,'2022-05-01','2022-12-01',264.96,8),
	 ('BTD3ZjLKfkT6ZRBT9zRwtg==','game 3','uk',14,true,'2022-12-01',27.42,'2022-11-01','2023-01-01',NULL,49.92,'2022-11-01',27.42,1,NULL,NULL,'2023-01-01',NULL,-22.50,NULL,NULL,'2022-05-01','2022-12-01',264.96,8),
	 ('bZDMuXKM3RFajmZa/yIpsw==','game 3','uk',23,false,'2022-09-01',14.55,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,14.55,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',186.96,4),
	 ('bZDMuXKM3RFajmZa/yIpsw==','game 3','uk',23,false,'2022-10-01',91.83,'2022-09-01','2022-11-01','2022-12-01',14.55,'2022-09-01',91.83,1,NULL,NULL,'2022-11-01',77.28,NULL,NULL,NULL,'2022-09-01','2022-12-01',186.96,4),
	 ('bZDMuXKM3RFajmZa/yIpsw==','game 3','uk',23,false,'2022-12-01',80.58,'2022-10-01','2023-01-01',NULL,91.83,'2022-11-01',80.58,1,NULL,NULL,'2023-01-01',NULL,NULL,80.58,1,'2022-09-01','2022-12-01',186.96,4),
	 ('c5qsNfxhW80Ws3aBXDa1nA==','game 3','uk',18,false,'2022-08-01',15.78,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,15.78,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',211.20,5),
	 ('c5qsNfxhW80Ws3aBXDa1nA==','game 3','uk',18,false,'2022-09-01',71.82,'2022-08-01','2022-10-01','2022-10-01',15.78,'2022-08-01',NULL,NULL,NULL,NULL,NULL,56.04,NULL,NULL,NULL,'2022-08-01','2022-12-01',211.20,5),
	 ('c5qsNfxhW80Ws3aBXDa1nA==','game 3','uk',18,false,'2022-10-01',83.16,'2022-09-01','2022-11-01','2022-11-01',71.82,'2022-09-01',NULL,NULL,NULL,NULL,NULL,11.34,NULL,NULL,NULL,'2022-08-01','2022-12-01',211.20,5),
	 ('c5qsNfxhW80Ws3aBXDa1nA==','game 3','uk',18,false,'2022-11-01',26.16,'2022-10-01','2022-12-01','2022-12-01',83.16,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-57.00,NULL,NULL,'2022-08-01','2022-12-01',211.20,5);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('c5qsNfxhW80Ws3aBXDa1nA==','game 3','uk',18,false,'2022-12-01',14.28,'2022-11-01','2023-01-01',NULL,26.16,'2022-11-01',14.28,1,NULL,NULL,'2023-01-01',NULL,-11.88,NULL,NULL,'2022-08-01','2022-12-01',211.20,5),
	 ('C6w5XTf8lIfc+VFmC7/bVw==','game 3','uk',40,false,'2022-07-01',14.25,NULL,'2022-08-01','2022-11-01',NULL,'2022-06-01',14.25,1,14.25,1,'2022-08-01',NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',69.30,6),
	 ('C6w5XTf8lIfc+VFmC7/bVw==','game 3','uk',40,false,'2022-11-01',29.22,'2022-07-01','2022-12-01','2022-12-01',14.25,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,29.22,1,'2022-07-01','2022-12-01',69.30,6),
	 ('C6w5XTf8lIfc+VFmC7/bVw==','game 3','uk',40,false,'2022-12-01',25.83,'2022-11-01','2023-01-01',NULL,29.22,'2022-11-01',25.83,1,NULL,NULL,'2023-01-01',NULL,-3.39,NULL,NULL,'2022-07-01','2022-12-01',69.30,6),
	 ('Cabfx2Uhcg6oOXYHLUa+rg==','game 3','uk',15,true,'2022-10-01',18.84,NULL,'2022-11-01',NULL,NULL,'2022-09-01',18.84,1,18.84,1,'2022-11-01',NULL,NULL,NULL,NULL,'2022-10-01','2022-10-01',18.84,1),
	 ('CCwTMcGtpirFFuqzSeTyaQ==','game 3','uk',18,false,'2022-03-01',15.84,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,15.84,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-04-01',36.60,2),
	 ('CCwTMcGtpirFFuqzSeTyaQ==','game 3','uk',18,false,'2022-04-01',20.76,'2022-03-01','2022-05-01',NULL,15.84,'2022-03-01',20.76,1,NULL,NULL,'2022-05-01',4.92,NULL,NULL,NULL,'2022-03-01','2022-04-01',36.60,2),
	 ('cDaRA0l0GtU4VtTO/DSe1g==','game 3','uk',21,false,'2022-11-01',33.33,NULL,'2022-12-01',NULL,NULL,'2022-10-01',33.33,1,33.33,1,'2022-12-01',NULL,NULL,NULL,NULL,'2022-11-01','2022-11-01',33.33,1),
	 ('cf1ykPUohKTUjtI6cAMhVw==','game 2','ru',21,true,'2022-10-01',12.24,NULL,'2022-11-01',NULL,NULL,'2022-09-01',12.24,1,12.24,1,'2022-11-01',NULL,NULL,NULL,NULL,'2022-10-01','2022-10-01',12.24,1),
	 ('cf5XFmP0Lfqw6irFBYfWwQ==','game 3','uk',19,false,'2022-11-01',32.25,NULL,'2022-12-01','2022-12-01',NULL,'2022-10-01',NULL,NULL,32.25,1,NULL,NULL,NULL,NULL,NULL,'2022-11-01','2022-12-01',53.28,2);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('cf5XFmP0Lfqw6irFBYfWwQ==','game 3','uk',19,false,'2022-12-01',21.03,'2022-11-01','2023-01-01',NULL,32.25,'2022-11-01',21.03,1,NULL,NULL,'2023-01-01',NULL,-11.22,NULL,NULL,'2022-11-01','2022-12-01',53.28,2),
	 ('CfgvA7ntuRJL/qdscwgMVw==','game 3','ru',24,false,'2022-09-01',43.83,NULL,'2022-10-01','2022-11-01',NULL,'2022-08-01',43.83,1,43.83,1,'2022-10-01',NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',160.38,4),
	 ('CfgvA7ntuRJL/qdscwgMVw==','game 3','ru',24,false,'2022-11-01',56.40,'2022-09-01','2022-12-01','2022-12-01',43.83,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,56.40,1,'2022-09-01','2022-12-01',160.38,4),
	 ('CfgvA7ntuRJL/qdscwgMVw==','game 3','ru',24,false,'2022-12-01',60.15,'2022-11-01','2023-01-01',NULL,56.40,'2022-11-01',60.15,1,NULL,NULL,'2023-01-01',3.75,NULL,NULL,NULL,'2022-09-01','2022-12-01',160.38,4),
	 ('cjAwQwy//1xm2O5pNRveqw==','game 3','ru',22,false,'2022-10-01',74.28,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,74.28,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',171.15,3),
	 ('cjAwQwy//1xm2O5pNRveqw==','game 3','ru',22,false,'2022-11-01',84.24,'2022-10-01','2022-12-01','2022-12-01',74.28,'2022-10-01',NULL,NULL,NULL,NULL,NULL,9.96,NULL,NULL,NULL,'2022-10-01','2022-12-01',171.15,3),
	 ('cjAwQwy//1xm2O5pNRveqw==','game 3','ru',22,false,'2022-12-01',12.63,'2022-11-01','2023-01-01',NULL,84.24,'2022-11-01',12.63,1,NULL,NULL,'2023-01-01',NULL,-71.61,NULL,NULL,'2022-10-01','2022-12-01',171.15,3),
	 ('cOCixiBbcAHemYgbNdoTcw==','game 3','uk',20,false,'2022-07-01',68.04,NULL,'2022-08-01','2022-09-01',NULL,'2022-06-01',68.04,1,68.04,1,'2022-08-01',NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',275.01,6),
	 ('cOCixiBbcAHemYgbNdoTcw==','game 3','uk',20,false,'2022-09-01',42.81,'2022-07-01','2022-10-01','2022-10-01',68.04,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,42.81,1,'2022-07-01','2022-12-01',275.01,6),
	 ('cOCixiBbcAHemYgbNdoTcw==','game 3','uk',20,false,'2022-10-01',66.09,'2022-09-01','2022-11-01','2022-11-01',42.81,'2022-09-01',NULL,NULL,NULL,NULL,NULL,23.28,NULL,NULL,NULL,'2022-07-01','2022-12-01',275.01,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('cOCixiBbcAHemYgbNdoTcw==','game 3','uk',20,false,'2022-11-01',82.68,'2022-10-01','2022-12-01','2022-12-01',66.09,'2022-10-01',NULL,NULL,NULL,NULL,NULL,16.59,NULL,NULL,NULL,'2022-07-01','2022-12-01',275.01,6),
	 ('cOCixiBbcAHemYgbNdoTcw==','game 3','uk',20,false,'2022-12-01',15.39,'2022-11-01','2023-01-01',NULL,82.68,'2022-11-01',15.39,1,NULL,NULL,'2023-01-01',NULL,-67.29,NULL,NULL,'2022-07-01','2022-12-01',275.01,6),
	 ('cp2QvW7HEEyNYKZRQ+RvyA==','game 3','uk',14,false,'2022-12-01',38.10,NULL,'2023-01-01',NULL,NULL,'2022-11-01',38.10,1,38.10,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',38.10,1),
	 ('crKNTIblJ0113SKEtSJQHw==','game 3','uk',16,false,'2022-05-01',93.99,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,93.99,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-12-01',423.36,8),
	 ('crKNTIblJ0113SKEtSJQHw==','game 3','uk',16,false,'2022-06-01',29.97,'2022-05-01','2022-07-01','2022-07-01',93.99,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-64.02,NULL,NULL,'2022-05-01','2022-12-01',423.36,8),
	 ('crKNTIblJ0113SKEtSJQHw==','game 3','uk',16,false,'2022-07-01',107.25,'2022-06-01','2022-08-01','2022-08-01',29.97,'2022-06-01',NULL,NULL,NULL,NULL,NULL,77.28,NULL,NULL,NULL,'2022-05-01','2022-12-01',423.36,8),
	 ('crKNTIblJ0113SKEtSJQHw==','game 3','uk',16,false,'2022-08-01',40.47,'2022-07-01','2022-09-01','2022-09-01',107.25,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-66.78,NULL,NULL,'2022-05-01','2022-12-01',423.36,8),
	 ('crKNTIblJ0113SKEtSJQHw==','game 3','uk',16,false,'2022-09-01',51.57,'2022-08-01','2022-10-01','2022-10-01',40.47,'2022-08-01',NULL,NULL,NULL,NULL,NULL,11.10,NULL,NULL,NULL,'2022-05-01','2022-12-01',423.36,8),
	 ('crKNTIblJ0113SKEtSJQHw==','game 3','uk',16,false,'2022-10-01',21.24,'2022-09-01','2022-11-01','2022-11-01',51.57,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-30.33,NULL,NULL,'2022-05-01','2022-12-01',423.36,8),
	 ('crKNTIblJ0113SKEtSJQHw==','game 3','uk',16,false,'2022-11-01',48.87,'2022-10-01','2022-12-01','2022-12-01',21.24,'2022-10-01',NULL,NULL,NULL,NULL,NULL,27.63,NULL,NULL,NULL,'2022-05-01','2022-12-01',423.36,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('crKNTIblJ0113SKEtSJQHw==','game 3','uk',16,false,'2022-12-01',30.00,'2022-11-01','2023-01-01',NULL,48.87,'2022-11-01',30.00,1,NULL,NULL,'2023-01-01',NULL,-18.87,NULL,NULL,'2022-05-01','2022-12-01',423.36,8),
	 ('cv6g2/jSkR+FwO58WY85DQ==','game 3','uk',20,false,'2022-08-01',55.47,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,55.47,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',133.77,5),
	 ('cv6g2/jSkR+FwO58WY85DQ==','game 3','uk',20,false,'2022-09-01',30.72,'2022-08-01','2022-10-01','2022-11-01',55.47,'2022-08-01',30.72,1,NULL,NULL,'2022-10-01',NULL,-24.75,NULL,NULL,'2022-08-01','2022-12-01',133.77,5),
	 ('cv6g2/jSkR+FwO58WY85DQ==','game 3','uk',20,false,'2022-11-01',23.28,'2022-09-01','2022-12-01','2022-12-01',30.72,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,23.28,1,'2022-08-01','2022-12-01',133.77,5),
	 ('cv6g2/jSkR+FwO58WY85DQ==','game 3','uk',20,false,'2022-12-01',24.3,'2022-11-01','2023-01-01',NULL,23.28,'2022-11-01',24.3,1,NULL,NULL,'2023-01-01',1.02,NULL,NULL,NULL,'2022-08-01','2022-12-01',133.77,5),
	 ('D0sawvsyqnyUMXNy+aXo7Q==','game 3','uk',19,false,'2022-10-01',72.69,NULL,'2022-11-01','2022-12-01',NULL,'2022-09-01',72.69,1,72.69,1,'2022-11-01',NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',120.87,3),
	 ('D0sawvsyqnyUMXNy+aXo7Q==','game 3','uk',19,false,'2022-12-01',48.18,'2022-10-01','2023-01-01',NULL,72.69,'2022-11-01',48.18,1,NULL,NULL,'2023-01-01',NULL,NULL,48.18,1,'2022-10-01','2022-12-01',120.87,3),
	 ('d7kiN4CYGndV2/L4yQeZ4g==','game 3','ru',19,false,'2022-08-01',42.60,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,42.60,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',289.17,5),
	 ('d7kiN4CYGndV2/L4yQeZ4g==','game 3','ru',19,false,'2022-09-01',26.64,'2022-08-01','2022-10-01','2022-10-01',42.60,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-15.96,NULL,NULL,'2022-08-01','2022-12-01',289.17,5),
	 ('d7kiN4CYGndV2/L4yQeZ4g==','game 3','ru',19,false,'2022-10-01',60.12,'2022-09-01','2022-11-01','2022-11-01',26.64,'2022-09-01',NULL,NULL,NULL,NULL,NULL,33.48,NULL,NULL,NULL,'2022-08-01','2022-12-01',289.17,5);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('d7kiN4CYGndV2/L4yQeZ4g==','game 3','ru',19,false,'2022-11-01',57.24,'2022-10-01','2022-12-01','2022-12-01',60.12,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-2.88,NULL,NULL,'2022-08-01','2022-12-01',289.17,5),
	 ('d7kiN4CYGndV2/L4yQeZ4g==','game 3','ru',19,false,'2022-12-01',102.57,'2022-11-01','2023-01-01',NULL,57.24,'2022-11-01',102.57,1,NULL,NULL,'2023-01-01',45.33,NULL,NULL,NULL,'2022-08-01','2022-12-01',289.17,5),
	 ('D9Bdgp+w/syZMU61LudzFQ==','game 3','uk',19,false,'2022-08-01',16.41,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,16.41,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-09-01',37.47,2),
	 ('D9Bdgp+w/syZMU61LudzFQ==','game 3','uk',19,false,'2022-09-01',21.06,'2022-08-01','2022-10-01',NULL,16.41,'2022-08-01',21.06,1,NULL,NULL,'2022-10-01',4.65,NULL,NULL,NULL,'2022-08-01','2022-09-01',37.47,2),
	 ('dAiAPbpgrBYKg4Rn7nbu4g==','game 3','uk',34,false,'2022-11-01',20.85,NULL,'2022-12-01',NULL,NULL,'2022-10-01',20.85,1,20.85,1,'2022-12-01',NULL,NULL,NULL,NULL,'2022-11-01','2022-11-01',20.85,1),
	 ('DAMO0tILVRlXZhYONdvs0Q==','game 3','uk',15,false,'2022-06-01',53.55,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,53.55,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-10-01',279.84,5),
	 ('DAMO0tILVRlXZhYONdvs0Q==','game 3','uk',15,false,'2022-07-01',53.31,'2022-06-01','2022-08-01','2022-08-01',53.55,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-0.24,NULL,NULL,'2022-06-01','2022-10-01',279.84,5),
	 ('DAMO0tILVRlXZhYONdvs0Q==','game 3','uk',15,false,'2022-08-01',48.21,'2022-07-01','2022-09-01','2022-09-01',53.31,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-5.10,NULL,NULL,'2022-06-01','2022-10-01',279.84,5),
	 ('DAMO0tILVRlXZhYONdvs0Q==','game 3','uk',15,false,'2022-09-01',54.15,'2022-08-01','2022-10-01','2022-10-01',48.21,'2022-08-01',NULL,NULL,NULL,NULL,NULL,5.94,NULL,NULL,NULL,'2022-06-01','2022-10-01',279.84,5),
	 ('DAMO0tILVRlXZhYONdvs0Q==','game 3','uk',15,false,'2022-10-01',70.62,'2022-09-01','2022-11-01',NULL,54.15,'2022-09-01',70.62,1,NULL,NULL,'2022-11-01',16.47,NULL,NULL,NULL,'2022-06-01','2022-10-01',279.84,5);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('Dbff3x5cRk6/tUY3WQdzFQ==','game 3','uk',21,false,'2022-04-01',60.57,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,60.57,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-09-01',335.76,6),
	 ('Dbff3x5cRk6/tUY3WQdzFQ==','game 3','uk',21,false,'2022-05-01',31.2,'2022-04-01','2022-06-01','2022-06-01',60.57,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-29.37,NULL,NULL,'2022-04-01','2022-09-01',335.76,6),
	 ('Dbff3x5cRk6/tUY3WQdzFQ==','game 3','uk',21,false,'2022-06-01',32.37,'2022-05-01','2022-07-01','2022-07-01',31.2,'2022-05-01',NULL,NULL,NULL,NULL,NULL,1.17,NULL,NULL,NULL,'2022-04-01','2022-09-01',335.76,6),
	 ('Dbff3x5cRk6/tUY3WQdzFQ==','game 3','uk',21,false,'2022-07-01',100.83,'2022-06-01','2022-08-01','2022-08-01',32.37,'2022-06-01',NULL,NULL,NULL,NULL,NULL,68.46,NULL,NULL,NULL,'2022-04-01','2022-09-01',335.76,6),
	 ('Dbff3x5cRk6/tUY3WQdzFQ==','game 3','uk',21,false,'2022-08-01',46.71,'2022-07-01','2022-09-01','2022-09-01',100.83,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-54.12,NULL,NULL,'2022-04-01','2022-09-01',335.76,6),
	 ('Dbff3x5cRk6/tUY3WQdzFQ==','game 3','uk',21,false,'2022-09-01',64.08,'2022-08-01','2022-10-01',NULL,46.71,'2022-08-01',64.08,1,NULL,NULL,'2022-10-01',17.37,NULL,NULL,NULL,'2022-04-01','2022-09-01',335.76,6),
	 ('DcYWdg5xq9/5Yd7SaaVhZw==','game 3','uk',32,false,'2022-08-01',29.49,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,29.49,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-11-01',62.46,4),
	 ('DcYWdg5xq9/5Yd7SaaVhZw==','game 3','uk',32,false,'2022-09-01',13.14,'2022-08-01','2022-10-01','2022-11-01',29.49,'2022-08-01',13.14,1,NULL,NULL,'2022-10-01',NULL,-16.35,NULL,NULL,'2022-08-01','2022-11-01',62.46,4),
	 ('DcYWdg5xq9/5Yd7SaaVhZw==','game 3','uk',32,false,'2022-11-01',19.83,'2022-09-01','2022-12-01',NULL,13.14,'2022-10-01',19.83,1,NULL,NULL,'2022-12-01',NULL,NULL,19.83,1,'2022-08-01','2022-11-01',62.46,4),
	 ('DorDcyqBWMg5IEaflqn5Xw==','game 3','ru',23,false,'2022-04-01',50.16,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,50.16,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-12-01',257.76,9);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('DorDcyqBWMg5IEaflqn5Xw==','game 3','ru',23,false,'2022-05-01',37.62,'2022-04-01','2022-06-01','2022-06-01',50.16,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-12.54,NULL,NULL,'2022-04-01','2022-12-01',257.76,9),
	 ('DorDcyqBWMg5IEaflqn5Xw==','game 3','ru',23,false,'2022-06-01',13.89,'2022-05-01','2022-07-01','2022-08-01',37.62,'2022-05-01',13.89,1,NULL,NULL,'2022-07-01',NULL,-23.73,NULL,NULL,'2022-04-01','2022-12-01',257.76,9),
	 ('DorDcyqBWMg5IEaflqn5Xw==','game 3','ru',23,false,'2022-08-01',58.92,'2022-06-01','2022-09-01','2022-09-01',13.89,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,58.92,1,'2022-04-01','2022-12-01',257.76,9),
	 ('DorDcyqBWMg5IEaflqn5Xw==','game 3','ru',23,false,'2022-09-01',85.05,'2022-08-01','2022-10-01','2022-12-01',58.92,'2022-08-01',85.05,1,NULL,NULL,'2022-10-01',26.13,NULL,NULL,NULL,'2022-04-01','2022-12-01',257.76,9),
	 ('DorDcyqBWMg5IEaflqn5Xw==','game 3','ru',23,false,'2022-12-01',12.12,'2022-09-01','2023-01-01',NULL,85.05,'2022-11-01',12.12,1,NULL,NULL,'2023-01-01',NULL,NULL,12.12,1,'2022-04-01','2022-12-01',257.76,9),
	 ('dp8g3Zsy2hCfov8GumRuWg==','game 3','ru',19,false,'2022-06-01',13.89,NULL,'2022-07-01',NULL,NULL,'2022-05-01',13.89,1,13.89,1,'2022-07-01',NULL,NULL,NULL,NULL,'2022-06-01','2022-06-01',13.89,1),
	 ('dpfu6t8G4blqMn55KM8bSg==','game 3','uk',16,false,'2022-04-01',33.03,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,33.03,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-11-01',400.32,8),
	 ('dpfu6t8G4blqMn55KM8bSg==','game 3','uk',16,false,'2022-05-01',33.15,'2022-04-01','2022-06-01','2022-06-01',33.03,'2022-04-01',NULL,NULL,NULL,NULL,NULL,0.12,NULL,NULL,NULL,'2022-04-01','2022-11-01',400.32,8),
	 ('dpfu6t8G4blqMn55KM8bSg==','game 3','uk',16,false,'2022-06-01',17.64,'2022-05-01','2022-07-01','2022-07-01',33.15,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-15.51,NULL,NULL,'2022-04-01','2022-11-01',400.32,8),
	 ('dpfu6t8G4blqMn55KM8bSg==','game 3','uk',16,false,'2022-07-01',12.03,'2022-06-01','2022-08-01','2022-08-01',17.64,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-5.61,NULL,NULL,'2022-04-01','2022-11-01',400.32,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('dpfu6t8G4blqMn55KM8bSg==','game 3','uk',16,false,'2022-08-01',92.13,'2022-07-01','2022-09-01','2022-09-01',12.03,'2022-07-01',NULL,NULL,NULL,NULL,NULL,80.10,NULL,NULL,NULL,'2022-04-01','2022-11-01',400.32,8),
	 ('dpfu6t8G4blqMn55KM8bSg==','game 3','uk',16,false,'2022-09-01',61.56,'2022-08-01','2022-10-01','2022-10-01',92.13,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-30.57,NULL,NULL,'2022-04-01','2022-11-01',400.32,8),
	 ('dpfu6t8G4blqMn55KM8bSg==','game 3','uk',16,false,'2022-10-01',112.20,'2022-09-01','2022-11-01','2022-11-01',61.56,'2022-09-01',NULL,NULL,NULL,NULL,NULL,50.64,NULL,NULL,NULL,'2022-04-01','2022-11-01',400.32,8),
	 ('dpfu6t8G4blqMn55KM8bSg==','game 3','uk',16,false,'2022-11-01',38.58,'2022-10-01','2022-12-01',NULL,112.20,'2022-10-01',38.58,1,NULL,NULL,'2022-12-01',NULL,-73.62,NULL,NULL,'2022-04-01','2022-11-01',400.32,8),
	 ('dQAFHVkiiCKfawYALbHZeA==','game 3','uk',26,false,'2022-07-01',16.38,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,16.38,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-10-01',49.02,4),
	 ('dQAFHVkiiCKfawYALbHZeA==','game 3','uk',26,false,'2022-08-01',14.64,'2022-07-01','2022-09-01','2022-10-01',16.38,'2022-07-01',14.64,1,NULL,NULL,'2022-09-01',NULL,-1.74,NULL,NULL,'2022-07-01','2022-10-01',49.02,4),
	 ('dQAFHVkiiCKfawYALbHZeA==','game 3','uk',26,false,'2022-10-01',18.0,'2022-08-01','2022-11-01',NULL,14.64,'2022-09-01',18.0,1,NULL,NULL,'2022-11-01',NULL,NULL,18.0,1,'2022-07-01','2022-10-01',49.02,4),
	 ('DqezK7HAqZ+GovyRuzxD1A==','game 3','uk',23,false,'2022-04-01',83.19,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,83.19,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-07-01',362.34,4),
	 ('DqezK7HAqZ+GovyRuzxD1A==','game 3','uk',23,false,'2022-05-01',72.15,'2022-04-01','2022-06-01','2022-06-01',83.19,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-11.04,NULL,NULL,'2022-04-01','2022-07-01',362.34,4),
	 ('DqezK7HAqZ+GovyRuzxD1A==','game 3','uk',23,false,'2022-06-01',86.49,'2022-05-01','2022-07-01','2022-07-01',72.15,'2022-05-01',NULL,NULL,NULL,NULL,NULL,14.34,NULL,NULL,NULL,'2022-04-01','2022-07-01',362.34,4);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('DqezK7HAqZ+GovyRuzxD1A==','game 3','uk',23,false,'2022-07-01',120.51,'2022-06-01','2022-08-01',NULL,86.49,'2022-06-01',120.51,1,NULL,NULL,'2022-08-01',34.02,NULL,NULL,NULL,'2022-04-01','2022-07-01',362.34,4),
	 ('dSGXNzIxO3joRVr1Eem+WQ==','game 3','uk',29,false,'2022-09-01',15.72,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,15.72,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-10-01',28.95,2),
	 ('dSGXNzIxO3joRVr1Eem+WQ==','game 3','uk',29,false,'2022-10-01',13.23,'2022-09-01','2022-11-01',NULL,15.72,'2022-09-01',13.23,1,NULL,NULL,'2022-11-01',NULL,-2.49,NULL,NULL,'2022-09-01','2022-10-01',28.95,2),
	 ('dUXVADLWvf2uvh+Q6TNrMw==','game 3','ru',19,false,'2022-07-01',12.15,NULL,'2022-08-01','2022-10-01',NULL,'2022-06-01',12.15,1,12.15,1,'2022-08-01',NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',190.32,6),
	 ('dUXVADLWvf2uvh+Q6TNrMw==','game 3','ru',19,false,'2022-10-01',36.63,'2022-07-01','2022-11-01','2022-11-01',12.15,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,36.63,1,'2022-07-01','2022-12-01',190.32,6),
	 ('dUXVADLWvf2uvh+Q6TNrMw==','game 3','ru',19,false,'2022-11-01',114.96,'2022-10-01','2022-12-01','2022-12-01',36.63,'2022-10-01',NULL,NULL,NULL,NULL,NULL,78.33,NULL,NULL,NULL,'2022-07-01','2022-12-01',190.32,6),
	 ('dUXVADLWvf2uvh+Q6TNrMw==','game 3','ru',19,false,'2022-12-01',26.58,'2022-11-01','2023-01-01',NULL,114.96,'2022-11-01',26.58,1,NULL,NULL,'2023-01-01',NULL,-88.38,NULL,NULL,'2022-07-01','2022-12-01',190.32,6),
	 ('dVTYjVpXbOM/sOgCq4CV0g==','game 3','uk',25,false,'2022-08-01',41.31,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,41.31,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',271.29,5),
	 ('dVTYjVpXbOM/sOgCq4CV0g==','game 3','uk',25,false,'2022-09-01',127.20,'2022-08-01','2022-10-01','2022-10-01',41.31,'2022-08-01',NULL,NULL,NULL,NULL,NULL,85.89,NULL,NULL,NULL,'2022-08-01','2022-12-01',271.29,5),
	 ('dVTYjVpXbOM/sOgCq4CV0g==','game 3','uk',25,false,'2022-10-01',75.54,'2022-09-01','2022-11-01','2022-11-01',127.20,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-51.66,NULL,NULL,'2022-08-01','2022-12-01',271.29,5);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('dVTYjVpXbOM/sOgCq4CV0g==','game 3','uk',25,false,'2022-11-01',14.73,'2022-10-01','2022-12-01','2022-12-01',75.54,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-60.81,NULL,NULL,'2022-08-01','2022-12-01',271.29,5),
	 ('dVTYjVpXbOM/sOgCq4CV0g==','game 3','uk',25,false,'2022-12-01',12.51,'2022-11-01','2023-01-01',NULL,14.73,'2022-11-01',12.51,1,NULL,NULL,'2023-01-01',NULL,-2.22,NULL,NULL,'2022-08-01','2022-12-01',271.29,5),
	 ('dxXTsxsoGNYPn+1rVBAUww==','game 3','uk',33,false,'2022-08-01',13.98,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,13.98,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-10-01',48.24,3),
	 ('dxXTsxsoGNYPn+1rVBAUww==','game 3','uk',33,false,'2022-09-01',16.05,'2022-08-01','2022-10-01','2022-10-01',13.98,'2022-08-01',NULL,NULL,NULL,NULL,NULL,2.07,NULL,NULL,NULL,'2022-08-01','2022-10-01',48.24,3),
	 ('dxXTsxsoGNYPn+1rVBAUww==','game 3','uk',33,false,'2022-10-01',18.21,'2022-09-01','2022-11-01',NULL,16.05,'2022-09-01',18.21,1,NULL,NULL,'2022-11-01',2.16,NULL,NULL,NULL,'2022-08-01','2022-10-01',48.24,3),
	 ('e/6IajqZ922YY1rh2ErMJQ==','game 3','en',25,false,'2022-06-01',33.51,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,33.51,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-12-01',876.60,7),
	 ('e/6IajqZ922YY1rh2ErMJQ==','game 3','en',25,false,'2022-07-01',148.98,'2022-06-01','2022-08-01','2022-08-01',33.51,'2022-06-01',NULL,NULL,NULL,NULL,NULL,115.47,NULL,NULL,NULL,'2022-06-01','2022-12-01',876.60,7),
	 ('e/6IajqZ922YY1rh2ErMJQ==','game 3','en',25,false,'2022-08-01',78.39,'2022-07-01','2022-09-01','2022-09-01',148.98,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-70.59,NULL,NULL,'2022-06-01','2022-12-01',876.60,7),
	 ('e/6IajqZ922YY1rh2ErMJQ==','game 3','en',25,false,'2022-09-01',70.14,'2022-08-01','2022-10-01','2022-10-01',78.39,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-8.25,NULL,NULL,'2022-06-01','2022-12-01',876.60,7),
	 ('e/6IajqZ922YY1rh2ErMJQ==','game 3','en',25,false,'2022-10-01',49.08,'2022-09-01','2022-11-01','2022-11-01',70.14,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-21.06,NULL,NULL,'2022-06-01','2022-12-01',876.60,7);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('e/6IajqZ922YY1rh2ErMJQ==','game 3','en',25,false,'2022-11-01',376.56,'2022-10-01','2022-12-01','2022-12-01',49.08,'2022-10-01',NULL,NULL,NULL,NULL,NULL,327.48,NULL,NULL,NULL,'2022-06-01','2022-12-01',876.60,7),
	 ('e/6IajqZ922YY1rh2ErMJQ==','game 3','en',25,false,'2022-12-01',119.94,'2022-11-01','2023-01-01',NULL,376.56,'2022-11-01',119.94,1,NULL,NULL,'2023-01-01',NULL,-256.62,NULL,NULL,'2022-06-01','2022-12-01',876.60,7),
	 ('e6LTrwXMl/v1epsRPDa9Fg==','game 2','uk',30,false,'2022-12-01',15.93,NULL,'2023-01-01',NULL,NULL,'2022-11-01',15.93,1,15.93,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',15.93,1),
	 ('eCd4MBHIR4qUWapg05TFLQ==','game 3','ru',18,false,'2022-04-01',23.04,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,23.04,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-11-01',242.04,8),
	 ('eCd4MBHIR4qUWapg05TFLQ==','game 3','ru',18,false,'2022-05-01',14.55,'2022-04-01','2022-06-01','2022-06-01',23.04,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-8.49,NULL,NULL,'2022-04-01','2022-11-01',242.04,8),
	 ('eCd4MBHIR4qUWapg05TFLQ==','game 3','ru',18,false,'2022-06-01',25.65,'2022-05-01','2022-07-01','2022-07-01',14.55,'2022-05-01',NULL,NULL,NULL,NULL,NULL,11.10,NULL,NULL,NULL,'2022-04-01','2022-11-01',242.04,8),
	 ('eCd4MBHIR4qUWapg05TFLQ==','game 3','ru',18,false,'2022-07-01',31.86,'2022-06-01','2022-08-01','2022-08-01',25.65,'2022-06-01',NULL,NULL,NULL,NULL,NULL,6.21,NULL,NULL,NULL,'2022-04-01','2022-11-01',242.04,8),
	 ('eCd4MBHIR4qUWapg05TFLQ==','game 3','ru',18,false,'2022-08-01',40.14,'2022-07-01','2022-09-01','2022-09-01',31.86,'2022-07-01',NULL,NULL,NULL,NULL,NULL,8.28,NULL,NULL,NULL,'2022-04-01','2022-11-01',242.04,8),
	 ('eCd4MBHIR4qUWapg05TFLQ==','game 3','ru',18,false,'2022-09-01',22.92,'2022-08-01','2022-10-01','2022-10-01',40.14,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-17.22,NULL,NULL,'2022-04-01','2022-11-01',242.04,8),
	 ('eCd4MBHIR4qUWapg05TFLQ==','game 3','ru',18,false,'2022-10-01',70.95,'2022-09-01','2022-11-01','2022-11-01',22.92,'2022-09-01',NULL,NULL,NULL,NULL,NULL,48.03,NULL,NULL,NULL,'2022-04-01','2022-11-01',242.04,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('eCd4MBHIR4qUWapg05TFLQ==','game 3','ru',18,false,'2022-11-01',12.93,'2022-10-01','2022-12-01',NULL,70.95,'2022-10-01',12.93,1,NULL,NULL,'2022-12-01',NULL,-58.02,NULL,NULL,'2022-04-01','2022-11-01',242.04,8),
	 ('Ej00UDBb0OBlQliAnSIp+g==','game 3','uk',15,false,'2022-09-01',42.54,NULL,'2022-10-01',NULL,NULL,'2022-08-01',42.54,1,42.54,1,'2022-10-01',NULL,NULL,NULL,NULL,'2022-09-01','2022-09-01',42.54,1),
	 ('eLWkkjmSeHVGjb9tp+CJpQ==','game 3','uk',19,false,'2022-07-01',22.5,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,22.5,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-09-01',115.74,3),
	 ('eLWkkjmSeHVGjb9tp+CJpQ==','game 3','uk',19,false,'2022-08-01',61.95,'2022-07-01','2022-09-01','2022-09-01',22.5,'2022-07-01',NULL,NULL,NULL,NULL,NULL,39.45,NULL,NULL,NULL,'2022-07-01','2022-09-01',115.74,3),
	 ('eLWkkjmSeHVGjb9tp+CJpQ==','game 3','uk',19,false,'2022-09-01',31.29,'2022-08-01','2022-10-01',NULL,61.95,'2022-08-01',31.29,1,NULL,NULL,'2022-10-01',NULL,-30.66,NULL,NULL,'2022-07-01','2022-09-01',115.74,3),
	 ('eoqO46DzxSrKA2rredUNyQ==','game 3','uk',24,false,'2022-06-01',13.5,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,13.5,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-10-01',320.94,5),
	 ('eoqO46DzxSrKA2rredUNyQ==','game 3','uk',24,false,'2022-07-01',60.72,'2022-06-01','2022-08-01','2022-08-01',13.5,'2022-06-01',NULL,NULL,NULL,NULL,NULL,47.22,NULL,NULL,NULL,'2022-06-01','2022-10-01',320.94,5),
	 ('eoqO46DzxSrKA2rredUNyQ==','game 3','uk',24,false,'2022-08-01',43.71,'2022-07-01','2022-09-01','2022-09-01',60.72,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-17.01,NULL,NULL,'2022-06-01','2022-10-01',320.94,5),
	 ('eoqO46DzxSrKA2rredUNyQ==','game 3','uk',24,false,'2022-09-01',13.89,'2022-08-01','2022-10-01','2022-10-01',43.71,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-29.82,NULL,NULL,'2022-06-01','2022-10-01',320.94,5),
	 ('eoqO46DzxSrKA2rredUNyQ==','game 3','uk',24,false,'2022-10-01',189.12,'2022-09-01','2022-11-01',NULL,13.89,'2022-09-01',189.12,1,NULL,NULL,'2022-11-01',175.23,NULL,NULL,NULL,'2022-06-01','2022-10-01',320.94,5);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('EPRgsEIjWdzmRbzsHZ48zg==','game 3','uk',25,false,'2022-09-01',62.16,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,62.16,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',266.58,4),
	 ('EPRgsEIjWdzmRbzsHZ48zg==','game 3','uk',25,false,'2022-10-01',130.77,'2022-09-01','2022-11-01','2022-11-01',62.16,'2022-09-01',NULL,NULL,NULL,NULL,NULL,68.61,NULL,NULL,NULL,'2022-09-01','2022-12-01',266.58,4),
	 ('EPRgsEIjWdzmRbzsHZ48zg==','game 3','uk',25,false,'2022-11-01',43.11,'2022-10-01','2022-12-01','2022-12-01',130.77,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-87.66,NULL,NULL,'2022-09-01','2022-12-01',266.58,4),
	 ('EPRgsEIjWdzmRbzsHZ48zg==','game 3','uk',25,false,'2022-12-01',30.54,'2022-11-01','2023-01-01',NULL,43.11,'2022-11-01',30.54,1,NULL,NULL,'2023-01-01',NULL,-12.57,NULL,NULL,'2022-09-01','2022-12-01',266.58,4),
	 ('er3/fOrRpmyqiRaC0CaFcg==','game 3','uk',21,false,'2022-05-01',47.22,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,47.22,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-12-01',412.17,8),
	 ('er3/fOrRpmyqiRaC0CaFcg==','game 3','uk',21,false,'2022-06-01',103.71,'2022-05-01','2022-07-01','2022-07-01',47.22,'2022-05-01',NULL,NULL,NULL,NULL,NULL,56.49,NULL,NULL,NULL,'2022-05-01','2022-12-01',412.17,8),
	 ('er3/fOrRpmyqiRaC0CaFcg==','game 3','uk',21,false,'2022-07-01',39.87,'2022-06-01','2022-08-01','2022-08-01',103.71,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-63.84,NULL,NULL,'2022-05-01','2022-12-01',412.17,8),
	 ('er3/fOrRpmyqiRaC0CaFcg==','game 3','uk',21,false,'2022-08-01',65.52,'2022-07-01','2022-09-01','2022-09-01',39.87,'2022-07-01',NULL,NULL,NULL,NULL,NULL,25.65,NULL,NULL,NULL,'2022-05-01','2022-12-01',412.17,8),
	 ('er3/fOrRpmyqiRaC0CaFcg==','game 3','uk',21,false,'2022-09-01',57.27,'2022-08-01','2022-10-01','2022-11-01',65.52,'2022-08-01',57.27,1,NULL,NULL,'2022-10-01',NULL,-8.25,NULL,NULL,'2022-05-01','2022-12-01',412.17,8),
	 ('er3/fOrRpmyqiRaC0CaFcg==','game 3','uk',21,false,'2022-11-01',74.37,'2022-09-01','2022-12-01','2022-12-01',57.27,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,74.37,1,'2022-05-01','2022-12-01',412.17,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('er3/fOrRpmyqiRaC0CaFcg==','game 3','uk',21,false,'2022-12-01',24.21,'2022-11-01','2023-01-01',NULL,74.37,'2022-11-01',24.21,1,NULL,NULL,'2023-01-01',NULL,-50.16,NULL,NULL,'2022-05-01','2022-12-01',412.17,8),
	 ('F03P4YcFbbtcWUlujjIQmQ==','game 3','ru',20,true,'2022-07-01',33.24,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,33.24,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',392.49,6),
	 ('F03P4YcFbbtcWUlujjIQmQ==','game 3','ru',20,true,'2022-08-01',37.23,'2022-07-01','2022-09-01','2022-09-01',33.24,'2022-07-01',NULL,NULL,NULL,NULL,NULL,3.99,NULL,NULL,NULL,'2022-07-01','2022-12-01',392.49,6),
	 ('F03P4YcFbbtcWUlujjIQmQ==','game 3','ru',20,true,'2022-09-01',79.08,'2022-08-01','2022-10-01','2022-10-01',37.23,'2022-08-01',NULL,NULL,NULL,NULL,NULL,41.85,NULL,NULL,NULL,'2022-07-01','2022-12-01',392.49,6),
	 ('F03P4YcFbbtcWUlujjIQmQ==','game 3','ru',20,true,'2022-10-01',136.86,'2022-09-01','2022-11-01','2022-11-01',79.08,'2022-09-01',NULL,NULL,NULL,NULL,NULL,57.78,NULL,NULL,NULL,'2022-07-01','2022-12-01',392.49,6),
	 ('F03P4YcFbbtcWUlujjIQmQ==','game 3','ru',20,true,'2022-11-01',58.95,'2022-10-01','2022-12-01','2022-12-01',136.86,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-77.91,NULL,NULL,'2022-07-01','2022-12-01',392.49,6),
	 ('F03P4YcFbbtcWUlujjIQmQ==','game 3','ru',20,true,'2022-12-01',47.13,'2022-11-01','2023-01-01',NULL,58.95,'2022-11-01',47.13,1,NULL,NULL,'2023-01-01',NULL,-11.82,NULL,NULL,'2022-07-01','2022-12-01',392.49,6),
	 ('F7cC4XEymgoRKeijWu63+w==','game 3','uk',16,false,'2022-12-01',24.33,NULL,'2023-01-01',NULL,NULL,'2022-11-01',24.33,1,24.33,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',24.33,1),
	 ('f9cWBjiN4c8lXAkBhdqK6Q==','game 3','uk',21,false,'2022-09-01',23.13,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,23.13,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-11-01',189.30,3),
	 ('f9cWBjiN4c8lXAkBhdqK6Q==','game 3','uk',21,false,'2022-10-01',111.36,'2022-09-01','2022-11-01','2022-11-01',23.13,'2022-09-01',NULL,NULL,NULL,NULL,NULL,88.23,NULL,NULL,NULL,'2022-09-01','2022-11-01',189.30,3);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('f9cWBjiN4c8lXAkBhdqK6Q==','game 3','uk',21,false,'2022-11-01',54.81,'2022-10-01','2022-12-01',NULL,111.36,'2022-10-01',54.81,1,NULL,NULL,'2022-12-01',NULL,-56.55,NULL,NULL,'2022-09-01','2022-11-01',189.30,3),
	 ('F9Jtg6+0qPUKWDgBJxG8cA==','game 3','ru',18,false,'2022-04-01',48.45,NULL,'2022-05-01','2022-06-01',NULL,'2022-03-01',48.45,1,48.45,1,'2022-05-01',NULL,NULL,NULL,NULL,'2022-04-01','2022-11-01',221.64,8),
	 ('F9Jtg6+0qPUKWDgBJxG8cA==','game 3','ru',18,false,'2022-06-01',89.07,'2022-04-01','2022-07-01','2022-07-01',48.45,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,89.07,1,'2022-04-01','2022-11-01',221.64,8),
	 ('F9Jtg6+0qPUKWDgBJxG8cA==','game 3','ru',18,false,'2022-07-01',31.59,'2022-06-01','2022-08-01','2022-08-01',89.07,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-57.48,NULL,NULL,'2022-04-01','2022-11-01',221.64,8),
	 ('F9Jtg6+0qPUKWDgBJxG8cA==','game 3','ru',18,false,'2022-08-01',30.39,'2022-07-01','2022-09-01','2022-11-01',31.59,'2022-07-01',30.39,1,NULL,NULL,'2022-09-01',NULL,-1.20,NULL,NULL,'2022-04-01','2022-11-01',221.64,8),
	 ('F9Jtg6+0qPUKWDgBJxG8cA==','game 3','ru',18,false,'2022-11-01',22.14,'2022-08-01','2022-12-01',NULL,30.39,'2022-10-01',22.14,1,NULL,NULL,'2022-12-01',NULL,NULL,22.14,1,'2022-04-01','2022-11-01',221.64,8),
	 ('FbbhrtuL39vfmatF2ObVfA==','game 3','uk',16,false,'2022-09-01',42.60,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,42.60,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',284.22,4),
	 ('FbbhrtuL39vfmatF2ObVfA==','game 3','uk',16,false,'2022-10-01',114.09,'2022-09-01','2022-11-01','2022-11-01',42.60,'2022-09-01',NULL,NULL,NULL,NULL,NULL,71.49,NULL,NULL,NULL,'2022-09-01','2022-12-01',284.22,4),
	 ('FbbhrtuL39vfmatF2ObVfA==','game 3','uk',16,false,'2022-11-01',112.86,'2022-10-01','2022-12-01','2022-12-01',114.09,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-1.23,NULL,NULL,'2022-09-01','2022-12-01',284.22,4),
	 ('FbbhrtuL39vfmatF2ObVfA==','game 3','uk',16,false,'2022-12-01',14.67,'2022-11-01','2023-01-01',NULL,112.86,'2022-11-01',14.67,1,NULL,NULL,'2023-01-01',NULL,-98.19,NULL,NULL,'2022-09-01','2022-12-01',284.22,4);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('fCdEizmUtnjNYQLbx81H8g==','game 3','ru',16,false,'2022-04-01',18.12,NULL,'2022-05-01',NULL,NULL,'2022-03-01',18.12,1,18.12,1,'2022-05-01',NULL,NULL,NULL,NULL,'2022-04-01','2022-04-01',18.12,1),
	 ('fDgyPW0yy0+9ietMvl0vmA==','game 3','ru',18,false,'2022-06-01',19.98,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,19.98,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-11-01',152.97,6),
	 ('fDgyPW0yy0+9ietMvl0vmA==','game 3','ru',18,false,'2022-07-01',32.94,'2022-06-01','2022-08-01','2022-08-01',19.98,'2022-06-01',NULL,NULL,NULL,NULL,NULL,12.96,NULL,NULL,NULL,'2022-06-01','2022-11-01',152.97,6),
	 ('fDgyPW0yy0+9ietMvl0vmA==','game 3','ru',18,false,'2022-08-01',65.34,'2022-07-01','2022-09-01','2022-11-01',32.94,'2022-07-01',65.34,1,NULL,NULL,'2022-09-01',32.40,NULL,NULL,NULL,'2022-06-01','2022-11-01',152.97,6),
	 ('fDgyPW0yy0+9ietMvl0vmA==','game 3','ru',18,false,'2022-11-01',34.71,'2022-08-01','2022-12-01',NULL,65.34,'2022-10-01',34.71,1,NULL,NULL,'2022-12-01',NULL,NULL,34.71,1,'2022-06-01','2022-11-01',152.97,6),
	 ('FfphIhReAA2romBynjqxqw==','game 3','uk',19,false,'2022-09-01',70.80,NULL,'2022-10-01',NULL,NULL,'2022-08-01',70.80,1,70.80,1,'2022-10-01',NULL,NULL,NULL,NULL,'2022-09-01','2022-09-01',70.80,1),
	 ('fFqrZjaytcDUnW57W7PRJA==','game 3','uk',22,false,'2022-12-01',76.14,NULL,'2023-01-01',NULL,NULL,'2022-11-01',76.14,1,76.14,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',76.14,1),
	 ('FgwYf9VO+gnaxZ7EXY0CkQ==','game 3','uk',39,false,'2022-09-01',14.88,NULL,'2022-10-01','2022-11-01',NULL,'2022-08-01',14.88,1,14.88,1,'2022-10-01',NULL,NULL,NULL,NULL,'2022-09-01','2022-11-01',28.17,3),
	 ('FgwYf9VO+gnaxZ7EXY0CkQ==','game 3','uk',39,false,'2022-11-01',13.29,'2022-09-01','2022-12-01',NULL,14.88,'2022-10-01',13.29,1,NULL,NULL,'2022-12-01',NULL,NULL,13.29,1,'2022-09-01','2022-11-01',28.17,3),
	 ('fH7uxifYBCx0TULRrcqajg==','game 3','uk',23,false,'2022-11-01',15.51,NULL,'2022-12-01','2022-12-01',NULL,'2022-10-01',NULL,NULL,15.51,1,NULL,NULL,NULL,NULL,NULL,'2022-11-01','2022-12-01',33.87,2);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('fH7uxifYBCx0TULRrcqajg==','game 3','uk',23,false,'2022-12-01',18.36,'2022-11-01','2023-01-01',NULL,15.51,'2022-11-01',18.36,1,NULL,NULL,'2023-01-01',2.85,NULL,NULL,NULL,'2022-11-01','2022-12-01',33.87,2),
	 ('FLqAK4qKiMkvlLBgGwbBnQ==','game 3','ru',31,false,'2022-05-01',24.36,NULL,'2022-06-01','2022-08-01',NULL,'2022-04-01',24.36,1,24.36,1,'2022-06-01',NULL,NULL,NULL,NULL,'2022-05-01','2022-10-01',138.39,6),
	 ('FLqAK4qKiMkvlLBgGwbBnQ==','game 3','ru',31,false,'2022-08-01',53.28,'2022-05-01','2022-09-01','2022-09-01',24.36,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,53.28,1,'2022-05-01','2022-10-01',138.39,6),
	 ('FLqAK4qKiMkvlLBgGwbBnQ==','game 3','ru',31,false,'2022-09-01',44.70,'2022-08-01','2022-10-01','2022-10-01',53.28,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-8.58,NULL,NULL,'2022-05-01','2022-10-01',138.39,6),
	 ('FLqAK4qKiMkvlLBgGwbBnQ==','game 3','ru',31,false,'2022-10-01',16.05,'2022-09-01','2022-11-01',NULL,44.70,'2022-09-01',16.05,1,NULL,NULL,'2022-11-01',NULL,-28.65,NULL,NULL,'2022-05-01','2022-10-01',138.39,6),
	 ('FnaqKQlPHm2pH1+S+K+Gfg==','game 3','uk',19,false,'2022-10-01',15.48,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,15.48,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',76.53,3),
	 ('FnaqKQlPHm2pH1+S+K+Gfg==','game 3','uk',19,false,'2022-11-01',37.20,'2022-10-01','2022-12-01','2022-12-01',15.48,'2022-10-01',NULL,NULL,NULL,NULL,NULL,21.72,NULL,NULL,NULL,'2022-10-01','2022-12-01',76.53,3),
	 ('FnaqKQlPHm2pH1+S+K+Gfg==','game 3','uk',19,false,'2022-12-01',23.85,'2022-11-01','2023-01-01',NULL,37.20,'2022-11-01',23.85,1,NULL,NULL,'2023-01-01',NULL,-13.35,NULL,NULL,'2022-10-01','2022-12-01',76.53,3),
	 ('fNc4x9raJu2OBcbtEloM7A==','game 3','ru',35,false,'2022-08-01',15.84,NULL,'2022-09-01',NULL,NULL,'2022-07-01',15.84,1,15.84,1,'2022-09-01',NULL,NULL,NULL,NULL,'2022-08-01','2022-08-01',15.84,1),
	 ('fq8oNQ55zdVqL3GK0IjuYg==','game 3','uk',25,false,'2022-10-01',31.74,NULL,'2022-11-01',NULL,NULL,'2022-09-01',31.74,1,31.74,1,'2022-11-01',NULL,NULL,NULL,NULL,'2022-10-01','2022-10-01',31.74,1);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('Fqu+/F0rn1G4YP3f3yHA1Q==','game 3','uk',21,false,'2022-04-01',26.28,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,26.28,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-12-01',198.33,9),
	 ('Fqu+/F0rn1G4YP3f3yHA1Q==','game 3','uk',21,false,'2022-05-01',20.73,'2022-04-01','2022-06-01','2022-07-01',26.28,'2022-04-01',20.73,1,NULL,NULL,'2022-06-01',NULL,-5.55,NULL,NULL,'2022-04-01','2022-12-01',198.33,9),
	 ('Fqu+/F0rn1G4YP3f3yHA1Q==','game 3','uk',21,false,'2022-07-01',36.66,'2022-05-01','2022-08-01','2022-09-01',20.73,'2022-06-01',36.66,1,NULL,NULL,'2022-08-01',NULL,NULL,36.66,1,'2022-04-01','2022-12-01',198.33,9),
	 ('Fqu+/F0rn1G4YP3f3yHA1Q==','game 3','uk',21,false,'2022-09-01',29.34,'2022-07-01','2022-10-01','2022-10-01',36.66,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,29.34,1,'2022-04-01','2022-12-01',198.33,9),
	 ('Fqu+/F0rn1G4YP3f3yHA1Q==','game 3','uk',21,false,'2022-10-01',33.69,'2022-09-01','2022-11-01','2022-11-01',29.34,'2022-09-01',NULL,NULL,NULL,NULL,NULL,4.35,NULL,NULL,NULL,'2022-04-01','2022-12-01',198.33,9),
	 ('Fqu+/F0rn1G4YP3f3yHA1Q==','game 3','uk',21,false,'2022-11-01',25.47,'2022-10-01','2022-12-01','2022-12-01',33.69,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-8.22,NULL,NULL,'2022-04-01','2022-12-01',198.33,9),
	 ('Fqu+/F0rn1G4YP3f3yHA1Q==','game 3','uk',21,false,'2022-12-01',26.16,'2022-11-01','2023-01-01',NULL,25.47,'2022-11-01',26.16,1,NULL,NULL,'2023-01-01',0.69,NULL,NULL,NULL,'2022-04-01','2022-12-01',198.33,9),
	 ('fuL+cD0zV6Gn4ypTYmXUgw==','game 3','uk',16,false,'2022-07-01',57.39,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,57.39,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',397.95,6),
	 ('fuL+cD0zV6Gn4ypTYmXUgw==','game 3','uk',16,false,'2022-08-01',57.60,'2022-07-01','2022-09-01','2022-09-01',57.39,'2022-07-01',NULL,NULL,NULL,NULL,NULL,0.21,NULL,NULL,NULL,'2022-07-01','2022-12-01',397.95,6),
	 ('fuL+cD0zV6Gn4ypTYmXUgw==','game 3','uk',16,false,'2022-09-01',96.66,'2022-08-01','2022-10-01','2022-10-01',57.60,'2022-08-01',NULL,NULL,NULL,NULL,NULL,39.06,NULL,NULL,NULL,'2022-07-01','2022-12-01',397.95,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('fuL+cD0zV6Gn4ypTYmXUgw==','game 3','uk',16,false,'2022-10-01',86.01,'2022-09-01','2022-11-01','2022-11-01',96.66,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-10.65,NULL,NULL,'2022-07-01','2022-12-01',397.95,6),
	 ('fuL+cD0zV6Gn4ypTYmXUgw==','game 3','uk',16,false,'2022-11-01',85.32,'2022-10-01','2022-12-01','2022-12-01',86.01,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-0.69,NULL,NULL,'2022-07-01','2022-12-01',397.95,6),
	 ('fuL+cD0zV6Gn4ypTYmXUgw==','game 3','uk',16,false,'2022-12-01',14.97,'2022-11-01','2023-01-01',NULL,85.32,'2022-11-01',14.97,1,NULL,NULL,'2023-01-01',NULL,-70.35,NULL,NULL,'2022-07-01','2022-12-01',397.95,6),
	 ('fvYhEtD56gROaXqCi9/z/Q==','game 3','uk',19,false,'2022-07-01',72.57,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,72.57,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',552.51,6),
	 ('fvYhEtD56gROaXqCi9/z/Q==','game 3','uk',19,false,'2022-08-01',133.05,'2022-07-01','2022-09-01','2022-09-01',72.57,'2022-07-01',NULL,NULL,NULL,NULL,NULL,60.48,NULL,NULL,NULL,'2022-07-01','2022-12-01',552.51,6),
	 ('fvYhEtD56gROaXqCi9/z/Q==','game 3','uk',19,false,'2022-09-01',52.32,'2022-08-01','2022-10-01','2022-10-01',133.05,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-80.73,NULL,NULL,'2022-07-01','2022-12-01',552.51,6),
	 ('fvYhEtD56gROaXqCi9/z/Q==','game 3','uk',19,false,'2022-10-01',67.17,'2022-09-01','2022-11-01','2022-11-01',52.32,'2022-09-01',NULL,NULL,NULL,NULL,NULL,14.85,NULL,NULL,NULL,'2022-07-01','2022-12-01',552.51,6),
	 ('fvYhEtD56gROaXqCi9/z/Q==','game 3','uk',19,false,'2022-11-01',96.30,'2022-10-01','2022-12-01','2022-12-01',67.17,'2022-10-01',NULL,NULL,NULL,NULL,NULL,29.13,NULL,NULL,NULL,'2022-07-01','2022-12-01',552.51,6),
	 ('fvYhEtD56gROaXqCi9/z/Q==','game 3','uk',19,false,'2022-12-01',131.10,'2022-11-01','2023-01-01',NULL,96.30,'2022-11-01',131.10,1,NULL,NULL,'2023-01-01',34.80,NULL,NULL,NULL,'2022-07-01','2022-12-01',552.51,6),
	 ('Fx9+2aYPOHAS3fdXpLQ9Pg==','game 3','ru',35,false,'2022-03-01',12.54,NULL,'2022-04-01','2022-05-01',NULL,'2022-02-01',12.54,1,12.54,1,'2022-04-01',NULL,NULL,NULL,NULL,'2022-03-01','2022-05-01',44.10,3);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('Fx9+2aYPOHAS3fdXpLQ9Pg==','game 3','ru',35,false,'2022-05-01',31.56,'2022-03-01','2022-06-01',NULL,12.54,'2022-04-01',31.56,1,NULL,NULL,'2022-06-01',NULL,NULL,31.56,1,'2022-03-01','2022-05-01',44.10,3),
	 ('fXlo39/YD2z9SEVShTXp6w==','game 3','uk',34,false,'2022-05-01',17.34,NULL,'2022-06-01',NULL,NULL,'2022-04-01',17.34,1,17.34,1,'2022-06-01',NULL,NULL,NULL,NULL,'2022-05-01','2022-05-01',17.34,1),
	 ('G073LR6lQoatStpZMzNVOQ==','game 3','uk',25,false,'2022-09-01',35.10,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,35.10,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',235.77,4),
	 ('G073LR6lQoatStpZMzNVOQ==','game 3','uk',25,false,'2022-10-01',16.65,'2022-09-01','2022-11-01','2022-11-01',35.10,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-18.45,NULL,NULL,'2022-09-01','2022-12-01',235.77,4),
	 ('G073LR6lQoatStpZMzNVOQ==','game 3','uk',25,false,'2022-11-01',94.32,'2022-10-01','2022-12-01','2022-12-01',16.65,'2022-10-01',NULL,NULL,NULL,NULL,NULL,77.67,NULL,NULL,NULL,'2022-09-01','2022-12-01',235.77,4),
	 ('G073LR6lQoatStpZMzNVOQ==','game 3','uk',25,false,'2022-12-01',89.70,'2022-11-01','2023-01-01',NULL,94.32,'2022-11-01',89.70,1,NULL,NULL,'2023-01-01',NULL,-4.62,NULL,NULL,'2022-09-01','2022-12-01',235.77,4),
	 ('G9053rs6jbKItKUhrUdLew==','game 3','uk',27,false,'2022-07-01',47.01,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,47.01,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',275.04,6),
	 ('G9053rs6jbKItKUhrUdLew==','game 3','uk',27,false,'2022-08-01',41.94,'2022-07-01','2022-09-01','2022-09-01',47.01,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-5.07,NULL,NULL,'2022-07-01','2022-12-01',275.04,6),
	 ('G9053rs6jbKItKUhrUdLew==','game 3','uk',27,false,'2022-09-01',64.95,'2022-08-01','2022-10-01','2022-11-01',41.94,'2022-08-01',64.95,1,NULL,NULL,'2022-10-01',23.01,NULL,NULL,NULL,'2022-07-01','2022-12-01',275.04,6),
	 ('G9053rs6jbKItKUhrUdLew==','game 3','uk',27,false,'2022-11-01',103.92,'2022-09-01','2022-12-01','2022-12-01',64.95,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,103.92,1,'2022-07-01','2022-12-01',275.04,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('G9053rs6jbKItKUhrUdLew==','game 3','uk',27,false,'2022-12-01',17.22,'2022-11-01','2023-01-01',NULL,103.92,'2022-11-01',17.22,1,NULL,NULL,'2023-01-01',NULL,-86.70,NULL,NULL,'2022-07-01','2022-12-01',275.04,6),
	 ('GEAVJz1gd3SThbDZR01fcA==','game 3','uk',14,false,'2022-04-01',87.36,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,87.36,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-10-01',333.36,7),
	 ('GEAVJz1gd3SThbDZR01fcA==','game 3','uk',14,false,'2022-05-01',48.30,'2022-04-01','2022-06-01','2022-06-01',87.36,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-39.06,NULL,NULL,'2022-04-01','2022-10-01',333.36,7),
	 ('GEAVJz1gd3SThbDZR01fcA==','game 3','uk',14,false,'2022-06-01',36.06,'2022-05-01','2022-07-01','2022-07-01',48.30,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-12.24,NULL,NULL,'2022-04-01','2022-10-01',333.36,7),
	 ('GEAVJz1gd3SThbDZR01fcA==','game 3','uk',14,false,'2022-07-01',75.36,'2022-06-01','2022-08-01','2022-09-01',36.06,'2022-06-01',75.36,1,NULL,NULL,'2022-08-01',39.30,NULL,NULL,NULL,'2022-04-01','2022-10-01',333.36,7),
	 ('GEAVJz1gd3SThbDZR01fcA==','game 3','uk',14,false,'2022-09-01',60.06,'2022-07-01','2022-10-01','2022-10-01',75.36,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,60.06,1,'2022-04-01','2022-10-01',333.36,7),
	 ('GEAVJz1gd3SThbDZR01fcA==','game 3','uk',14,false,'2022-10-01',26.22,'2022-09-01','2022-11-01',NULL,60.06,'2022-09-01',26.22,1,NULL,NULL,'2022-11-01',NULL,-33.84,NULL,NULL,'2022-04-01','2022-10-01',333.36,7),
	 ('geIiJ1L04w2qAE0qzQUb2g==','game 3','uk',23,false,'2022-06-01',51.24,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,51.24,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-11-01',270.12,6),
	 ('geIiJ1L04w2qAE0qzQUb2g==','game 3','uk',23,false,'2022-07-01',107.07,'2022-06-01','2022-08-01','2022-08-01',51.24,'2022-06-01',NULL,NULL,NULL,NULL,NULL,55.83,NULL,NULL,NULL,'2022-06-01','2022-11-01',270.12,6),
	 ('geIiJ1L04w2qAE0qzQUb2g==','game 3','uk',23,false,'2022-08-01',30.18,'2022-07-01','2022-09-01','2022-09-01',107.07,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-76.89,NULL,NULL,'2022-06-01','2022-11-01',270.12,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('geIiJ1L04w2qAE0qzQUb2g==','game 3','uk',23,false,'2022-09-01',22.92,'2022-08-01','2022-10-01','2022-10-01',30.18,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-7.26,NULL,NULL,'2022-06-01','2022-11-01',270.12,6),
	 ('geIiJ1L04w2qAE0qzQUb2g==','game 3','uk',23,false,'2022-10-01',37.17,'2022-09-01','2022-11-01','2022-11-01',22.92,'2022-09-01',NULL,NULL,NULL,NULL,NULL,14.25,NULL,NULL,NULL,'2022-06-01','2022-11-01',270.12,6),
	 ('geIiJ1L04w2qAE0qzQUb2g==','game 3','uk',23,false,'2022-11-01',21.54,'2022-10-01','2022-12-01',NULL,37.17,'2022-10-01',21.54,1,NULL,NULL,'2022-12-01',NULL,-15.63,NULL,NULL,'2022-06-01','2022-11-01',270.12,6),
	 ('GeLWEsTiQ25xFxDGxLyEJg==','game 3','uk',26,false,'2022-12-01',16.5,NULL,'2023-01-01',NULL,NULL,'2022-11-01',16.5,1,16.5,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',16.5,1),
	 ('GetHmCsisRTAnwhuBEMa9Q==','game 3','ru',16,false,'2022-11-01',119.55,NULL,'2022-12-01','2022-12-01',NULL,'2022-10-01',NULL,NULL,119.55,1,NULL,NULL,NULL,NULL,NULL,'2022-11-01','2022-12-01',279.93,2),
	 ('GetHmCsisRTAnwhuBEMa9Q==','game 3','ru',16,false,'2022-12-01',160.38,'2022-11-01','2023-01-01',NULL,119.55,'2022-11-01',160.38,1,NULL,NULL,'2023-01-01',40.83,NULL,NULL,NULL,'2022-11-01','2022-12-01',279.93,2),
	 ('Ghk2iJmzSUW4qLsmJgwOcw==','game 3','uk',16,false,'2022-03-01',17.13,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,17.13,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-12-01',696.72,10),
	 ('Ghk2iJmzSUW4qLsmJgwOcw==','game 3','uk',16,false,'2022-04-01',128.40,'2022-03-01','2022-05-01','2022-05-01',17.13,'2022-03-01',NULL,NULL,NULL,NULL,NULL,111.27,NULL,NULL,NULL,'2022-03-01','2022-12-01',696.72,10),
	 ('Ghk2iJmzSUW4qLsmJgwOcw==','game 3','uk',16,false,'2022-05-01',67.29,'2022-04-01','2022-06-01','2022-06-01',128.40,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-61.11,NULL,NULL,'2022-03-01','2022-12-01',696.72,10),
	 ('Ghk2iJmzSUW4qLsmJgwOcw==','game 3','uk',16,false,'2022-06-01',82.80,'2022-05-01','2022-07-01','2022-07-01',67.29,'2022-05-01',NULL,NULL,NULL,NULL,NULL,15.51,NULL,NULL,NULL,'2022-03-01','2022-12-01',696.72,10);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('Ghk2iJmzSUW4qLsmJgwOcw==','game 3','uk',16,false,'2022-07-01',45.96,'2022-06-01','2022-08-01','2022-08-01',82.80,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-36.84,NULL,NULL,'2022-03-01','2022-12-01',696.72,10),
	 ('Ghk2iJmzSUW4qLsmJgwOcw==','game 3','uk',16,false,'2022-08-01',77.82,'2022-07-01','2022-09-01','2022-10-01',45.96,'2022-07-01',77.82,1,NULL,NULL,'2022-09-01',31.86,NULL,NULL,NULL,'2022-03-01','2022-12-01',696.72,10),
	 ('Ghk2iJmzSUW4qLsmJgwOcw==','game 3','uk',16,false,'2022-10-01',152.43,'2022-08-01','2022-11-01','2022-11-01',77.82,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,152.43,1,'2022-03-01','2022-12-01',696.72,10),
	 ('Ghk2iJmzSUW4qLsmJgwOcw==','game 3','uk',16,false,'2022-11-01',76.14,'2022-10-01','2022-12-01','2022-12-01',152.43,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-76.29,NULL,NULL,'2022-03-01','2022-12-01',696.72,10),
	 ('Ghk2iJmzSUW4qLsmJgwOcw==','game 3','uk',16,false,'2022-12-01',48.75,'2022-11-01','2023-01-01',NULL,76.14,'2022-11-01',48.75,1,NULL,NULL,'2023-01-01',NULL,-27.39,NULL,NULL,'2022-03-01','2022-12-01',696.72,10),
	 ('GjL6ipu28pHPFxZJPuplNQ==','game 3','uk',28,false,'2022-08-01',16.44,NULL,'2022-09-01',NULL,NULL,'2022-07-01',16.44,1,16.44,1,'2022-09-01',NULL,NULL,NULL,NULL,'2022-08-01','2022-08-01',16.44,1),
	 ('GOl6BQXsy0zvbvIWIoKEQw==','game 3','ru',18,false,'2022-05-01',64.65,NULL,'2022-06-01','2022-07-01',NULL,'2022-04-01',64.65,1,64.65,1,'2022-06-01',NULL,NULL,NULL,NULL,'2022-05-01','2022-11-01',467.07,7),
	 ('GOl6BQXsy0zvbvIWIoKEQw==','game 3','ru',18,false,'2022-07-01',114.75,'2022-05-01','2022-08-01','2022-08-01',64.65,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,114.75,1,'2022-05-01','2022-11-01',467.07,7),
	 ('GOl6BQXsy0zvbvIWIoKEQw==','game 3','ru',18,false,'2022-08-01',76.23,'2022-07-01','2022-09-01','2022-09-01',114.75,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-38.52,NULL,NULL,'2022-05-01','2022-11-01',467.07,7),
	 ('GOl6BQXsy0zvbvIWIoKEQw==','game 3','ru',18,false,'2022-09-01',18.27,'2022-08-01','2022-10-01','2022-10-01',76.23,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-57.96,NULL,NULL,'2022-05-01','2022-11-01',467.07,7);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('GOl6BQXsy0zvbvIWIoKEQw==','game 3','ru',18,false,'2022-10-01',139.68,'2022-09-01','2022-11-01','2022-11-01',18.27,'2022-09-01',NULL,NULL,NULL,NULL,NULL,121.41,NULL,NULL,NULL,'2022-05-01','2022-11-01',467.07,7),
	 ('GOl6BQXsy0zvbvIWIoKEQw==','game 3','ru',18,false,'2022-11-01',53.49,'2022-10-01','2022-12-01',NULL,139.68,'2022-10-01',53.49,1,NULL,NULL,'2022-12-01',NULL,-86.19,NULL,NULL,'2022-05-01','2022-11-01',467.07,7),
	 ('G+PCL1Jo+k4D3zpLGa3+aQ==','game 3','uk',25,true,'2022-09-01',18.12,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,18.12,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',116.88,4),
	 ('G+PCL1Jo+k4D3zpLGa3+aQ==','game 3','uk',25,true,'2022-10-01',23.1,'2022-09-01','2022-11-01','2022-11-01',18.12,'2022-09-01',NULL,NULL,NULL,NULL,NULL,4.98,NULL,NULL,NULL,'2022-09-01','2022-12-01',116.88,4),
	 ('G+PCL1Jo+k4D3zpLGa3+aQ==','game 3','uk',25,true,'2022-11-01',21.66,'2022-10-01','2022-12-01','2022-12-01',23.1,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-1.44,NULL,NULL,'2022-09-01','2022-12-01',116.88,4),
	 ('G+PCL1Jo+k4D3zpLGa3+aQ==','game 3','uk',25,true,'2022-12-01',54.00,'2022-11-01','2023-01-01',NULL,21.66,'2022-11-01',54.00,1,NULL,NULL,'2023-01-01',32.34,NULL,NULL,NULL,'2022-09-01','2022-12-01',116.88,4),
	 ('gPRMy8HkmaiyX+13OxuP/A==','game 3','ru',21,false,'2022-04-01',55.86,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,55.86,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-11-01',343.20,8),
	 ('gPRMy8HkmaiyX+13OxuP/A==','game 3','ru',21,false,'2022-05-01',22.17,'2022-04-01','2022-06-01','2022-06-01',55.86,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-33.69,NULL,NULL,'2022-04-01','2022-11-01',343.20,8),
	 ('gPRMy8HkmaiyX+13OxuP/A==','game 3','ru',21,false,'2022-06-01',41.52,'2022-05-01','2022-07-01','2022-07-01',22.17,'2022-05-01',NULL,NULL,NULL,NULL,NULL,19.35,NULL,NULL,NULL,'2022-04-01','2022-11-01',343.20,8),
	 ('gPRMy8HkmaiyX+13OxuP/A==','game 3','ru',21,false,'2022-07-01',85.17,'2022-06-01','2022-08-01','2022-08-01',41.52,'2022-06-01',NULL,NULL,NULL,NULL,NULL,43.65,NULL,NULL,NULL,'2022-04-01','2022-11-01',343.20,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('gPRMy8HkmaiyX+13OxuP/A==','game 3','ru',21,false,'2022-08-01',17.4,'2022-07-01','2022-09-01','2022-09-01',85.17,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-67.77,NULL,NULL,'2022-04-01','2022-11-01',343.20,8),
	 ('gPRMy8HkmaiyX+13OxuP/A==','game 3','ru',21,false,'2022-09-01',53.52,'2022-08-01','2022-10-01','2022-10-01',17.4,'2022-08-01',NULL,NULL,NULL,NULL,NULL,36.12,NULL,NULL,NULL,'2022-04-01','2022-11-01',343.20,8),
	 ('gPRMy8HkmaiyX+13OxuP/A==','game 3','ru',21,false,'2022-10-01',38.22,'2022-09-01','2022-11-01','2022-11-01',53.52,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-15.30,NULL,NULL,'2022-04-01','2022-11-01',343.20,8),
	 ('gPRMy8HkmaiyX+13OxuP/A==','game 3','ru',21,false,'2022-11-01',29.34,'2022-10-01','2022-12-01',NULL,38.22,'2022-10-01',29.34,1,NULL,NULL,'2022-12-01',NULL,-8.88,NULL,NULL,'2022-04-01','2022-11-01',343.20,8),
	 ('Grpkzd4XIHh+ZbTMNxnUGg==','game 3','ru',30,false,'2022-04-01',35.55,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,35.55,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-10-01',109.08,7),
	 ('Grpkzd4XIHh+ZbTMNxnUGg==','game 3','ru',30,false,'2022-05-01',41.88,'2022-04-01','2022-06-01','2022-06-01',35.55,'2022-04-01',NULL,NULL,NULL,NULL,NULL,6.33,NULL,NULL,NULL,'2022-04-01','2022-10-01',109.08,7),
	 ('Grpkzd4XIHh+ZbTMNxnUGg==','game 3','ru',30,false,'2022-06-01',14.49,'2022-05-01','2022-07-01','2022-10-01',41.88,'2022-05-01',14.49,1,NULL,NULL,'2022-07-01',NULL,-27.39,NULL,NULL,'2022-04-01','2022-10-01',109.08,7),
	 ('Grpkzd4XIHh+ZbTMNxnUGg==','game 3','ru',30,false,'2022-10-01',17.16,'2022-06-01','2022-11-01',NULL,14.49,'2022-09-01',17.16,1,NULL,NULL,'2022-11-01',NULL,NULL,17.16,1,'2022-04-01','2022-10-01',109.08,7),
	 ('gT0iqDKuIXNm4ceMd9eZ1A==','game 3','uk',20,false,'2022-07-01',92.19,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,92.19,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',310.26,6),
	 ('gT0iqDKuIXNm4ceMd9eZ1A==','game 3','uk',20,false,'2022-08-01',57.78,'2022-07-01','2022-09-01','2022-09-01',92.19,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-34.41,NULL,NULL,'2022-07-01','2022-12-01',310.26,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('gT0iqDKuIXNm4ceMd9eZ1A==','game 3','uk',20,false,'2022-09-01',49.95,'2022-08-01','2022-10-01','2022-10-01',57.78,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-7.83,NULL,NULL,'2022-07-01','2022-12-01',310.26,6),
	 ('gT0iqDKuIXNm4ceMd9eZ1A==','game 3','uk',20,false,'2022-10-01',38.85,'2022-09-01','2022-11-01','2022-11-01',49.95,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-11.10,NULL,NULL,'2022-07-01','2022-12-01',310.26,6),
	 ('gT0iqDKuIXNm4ceMd9eZ1A==','game 3','uk',20,false,'2022-11-01',48.15,'2022-10-01','2022-12-01','2022-12-01',38.85,'2022-10-01',NULL,NULL,NULL,NULL,NULL,9.30,NULL,NULL,NULL,'2022-07-01','2022-12-01',310.26,6),
	 ('gT0iqDKuIXNm4ceMd9eZ1A==','game 3','uk',20,false,'2022-12-01',23.34,'2022-11-01','2023-01-01',NULL,48.15,'2022-11-01',23.34,1,NULL,NULL,'2023-01-01',NULL,-24.81,NULL,NULL,'2022-07-01','2022-12-01',310.26,6),
	 ('GUNmu9bjwltT1/vYgzDEDQ==','game 3','uk',16,true,'2022-06-01',13.56,NULL,'2022-07-01',NULL,NULL,'2022-05-01',13.56,1,13.56,1,'2022-07-01',NULL,NULL,NULL,NULL,'2022-06-01','2022-06-01',13.56,1),
	 ('gxZPbCoYIu8slavUm05KGA==','game 3','ru',14,false,'2022-08-01',19.8,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,19.8,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',147.57,5),
	 ('gxZPbCoYIu8slavUm05KGA==','game 3','ru',14,false,'2022-09-01',49.50,'2022-08-01','2022-10-01','2022-10-01',19.8,'2022-08-01',NULL,NULL,NULL,NULL,NULL,29.70,NULL,NULL,NULL,'2022-08-01','2022-12-01',147.57,5),
	 ('gxZPbCoYIu8slavUm05KGA==','game 3','ru',14,false,'2022-10-01',14.91,'2022-09-01','2022-11-01','2022-11-01',49.50,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-34.59,NULL,NULL,'2022-08-01','2022-12-01',147.57,5),
	 ('gxZPbCoYIu8slavUm05KGA==','game 3','ru',14,false,'2022-11-01',29.22,'2022-10-01','2022-12-01','2022-12-01',14.91,'2022-10-01',NULL,NULL,NULL,NULL,NULL,14.31,NULL,NULL,NULL,'2022-08-01','2022-12-01',147.57,5),
	 ('gxZPbCoYIu8slavUm05KGA==','game 3','ru',14,false,'2022-12-01',34.14,'2022-11-01','2023-01-01',NULL,29.22,'2022-11-01',34.14,1,NULL,NULL,'2023-01-01',4.92,NULL,NULL,NULL,'2022-08-01','2022-12-01',147.57,5);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('H2Tik+BqoLgAQX4uSw/8vA==','game 3','uk',30,false,'2022-04-01',14.34,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,14.34,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-09-01',122.49,6),
	 ('H2Tik+BqoLgAQX4uSw/8vA==','game 3','uk',30,false,'2022-05-01',12.09,'2022-04-01','2022-06-01','2022-06-01',14.34,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-2.25,NULL,NULL,'2022-04-01','2022-09-01',122.49,6),
	 ('H2Tik+BqoLgAQX4uSw/8vA==','game 3','uk',30,false,'2022-06-01',51.21,'2022-05-01','2022-07-01','2022-07-01',12.09,'2022-05-01',NULL,NULL,NULL,NULL,NULL,39.12,NULL,NULL,NULL,'2022-04-01','2022-09-01',122.49,6),
	 ('H2Tik+BqoLgAQX4uSw/8vA==','game 3','uk',30,false,'2022-07-01',18.12,'2022-06-01','2022-08-01','2022-09-01',51.21,'2022-06-01',18.12,1,NULL,NULL,'2022-08-01',NULL,-33.09,NULL,NULL,'2022-04-01','2022-09-01',122.49,6),
	 ('H2Tik+BqoLgAQX4uSw/8vA==','game 3','uk',30,false,'2022-09-01',26.73,'2022-07-01','2022-10-01',NULL,18.12,'2022-08-01',26.73,1,NULL,NULL,'2022-10-01',NULL,NULL,26.73,1,'2022-04-01','2022-09-01',122.49,6),
	 ('H44DjZG42orzuBXLai7JkA==','game 3','ru',29,false,'2022-03-01',13.32,NULL,'2022-04-01',NULL,NULL,'2022-02-01',13.32,1,13.32,1,'2022-04-01',NULL,NULL,NULL,NULL,'2022-03-01','2022-03-01',13.32,1),
	 ('Hamw6F2EZmJfI2glmE2NEg==','game 3','ru',24,true,'2022-04-01',42.24,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,42.24,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-11-01',242.97,8),
	 ('Hamw6F2EZmJfI2glmE2NEg==','game 3','ru',24,true,'2022-05-01',15.6,'2022-04-01','2022-06-01','2022-06-01',42.24,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-26.64,NULL,NULL,'2022-04-01','2022-11-01',242.97,8),
	 ('Hamw6F2EZmJfI2glmE2NEg==','game 3','ru',24,true,'2022-06-01',32.07,'2022-05-01','2022-07-01','2022-07-01',15.6,'2022-05-01',NULL,NULL,NULL,NULL,NULL,16.47,NULL,NULL,NULL,'2022-04-01','2022-11-01',242.97,8),
	 ('Hamw6F2EZmJfI2glmE2NEg==','game 3','ru',24,true,'2022-07-01',55.89,'2022-06-01','2022-08-01','2022-08-01',32.07,'2022-06-01',NULL,NULL,NULL,NULL,NULL,23.82,NULL,NULL,NULL,'2022-04-01','2022-11-01',242.97,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('Hamw6F2EZmJfI2glmE2NEg==','game 3','ru',24,true,'2022-08-01',36.27,'2022-07-01','2022-09-01','2022-09-01',55.89,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-19.62,NULL,NULL,'2022-04-01','2022-11-01',242.97,8),
	 ('Hamw6F2EZmJfI2glmE2NEg==','game 3','ru',24,true,'2022-09-01',20.91,'2022-08-01','2022-10-01','2022-10-01',36.27,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-15.36,NULL,NULL,'2022-04-01','2022-11-01',242.97,8),
	 ('Hamw6F2EZmJfI2glmE2NEg==','game 3','ru',24,true,'2022-10-01',19.02,'2022-09-01','2022-11-01','2022-11-01',20.91,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-1.89,NULL,NULL,'2022-04-01','2022-11-01',242.97,8),
	 ('Hamw6F2EZmJfI2glmE2NEg==','game 3','ru',24,true,'2022-11-01',20.97,'2022-10-01','2022-12-01',NULL,19.02,'2022-10-01',20.97,1,NULL,NULL,'2022-12-01',1.95,NULL,NULL,NULL,'2022-04-01','2022-11-01',242.97,8),
	 ('hi1ErLiMLDP0HWvMqLKv6g==','game 3','ru',18,false,'2022-07-01',117.78,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,117.78,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',429.54,6),
	 ('hi1ErLiMLDP0HWvMqLKv6g==','game 3','ru',18,false,'2022-08-01',32.13,'2022-07-01','2022-09-01','2022-09-01',117.78,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-85.65,NULL,NULL,'2022-07-01','2022-12-01',429.54,6),
	 ('hi1ErLiMLDP0HWvMqLKv6g==','game 3','ru',18,false,'2022-09-01',79.56,'2022-08-01','2022-10-01','2022-10-01',32.13,'2022-08-01',NULL,NULL,NULL,NULL,NULL,47.43,NULL,NULL,NULL,'2022-07-01','2022-12-01',429.54,6),
	 ('hi1ErLiMLDP0HWvMqLKv6g==','game 3','ru',18,false,'2022-10-01',55.11,'2022-09-01','2022-11-01','2022-11-01',79.56,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-24.45,NULL,NULL,'2022-07-01','2022-12-01',429.54,6),
	 ('hi1ErLiMLDP0HWvMqLKv6g==','game 3','ru',18,false,'2022-11-01',62.55,'2022-10-01','2022-12-01','2022-12-01',55.11,'2022-10-01',NULL,NULL,NULL,NULL,NULL,7.44,NULL,NULL,NULL,'2022-07-01','2022-12-01',429.54,6),
	 ('hi1ErLiMLDP0HWvMqLKv6g==','game 3','ru',18,false,'2022-12-01',82.41,'2022-11-01','2023-01-01',NULL,62.55,'2022-11-01',82.41,1,NULL,NULL,'2023-01-01',19.86,NULL,NULL,NULL,'2022-07-01','2022-12-01',429.54,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('HJccOn6v5KHqBa8wRu42oQ==','game 3','uk',20,false,'2022-03-01',27.6,NULL,'2022-04-01','2022-05-01',NULL,'2022-02-01',27.6,1,27.6,1,'2022-04-01',NULL,NULL,NULL,NULL,'2022-03-01','2022-09-01',99.78,7),
	 ('HJccOn6v5KHqBa8wRu42oQ==','game 3','uk',20,false,'2022-05-01',18.84,'2022-03-01','2022-06-01','2022-07-01',27.6,'2022-04-01',18.84,1,NULL,NULL,'2022-06-01',NULL,NULL,18.84,1,'2022-03-01','2022-09-01',99.78,7),
	 ('HJccOn6v5KHqBa8wRu42oQ==','game 3','uk',20,false,'2022-07-01',25.2,'2022-05-01','2022-08-01','2022-09-01',18.84,'2022-06-01',25.2,1,NULL,NULL,'2022-08-01',NULL,NULL,25.2,1,'2022-03-01','2022-09-01',99.78,7),
	 ('HJccOn6v5KHqBa8wRu42oQ==','game 3','uk',20,false,'2022-09-01',28.14,'2022-07-01','2022-10-01',NULL,25.2,'2022-08-01',28.14,1,NULL,NULL,'2022-10-01',NULL,NULL,28.14,1,'2022-03-01','2022-09-01',99.78,7),
	 ('hJC/g1L2PFnPlGoqsvD2/g==','game 3','ru',26,false,'2022-10-01',28.95,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,28.95,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-11-01',65.88,2),
	 ('hJC/g1L2PFnPlGoqsvD2/g==','game 3','ru',26,false,'2022-11-01',36.93,'2022-10-01','2022-12-01',NULL,28.95,'2022-10-01',36.93,1,NULL,NULL,'2022-12-01',7.98,NULL,NULL,NULL,'2022-10-01','2022-11-01',65.88,2),
	 ('HjI8n/FVfaGZ4bIEwrZPGw==','game 3','ru',29,false,'2022-06-01',31.80,NULL,'2022-07-01',NULL,NULL,'2022-05-01',31.80,1,31.80,1,'2022-07-01',NULL,NULL,NULL,NULL,'2022-06-01','2022-06-01',31.80,1),
	 ('hkNuy6dTFIFcsQQfT5YkwQ==','game 3','uk',21,false,'2022-04-01',20.25,NULL,'2022-05-01',NULL,NULL,'2022-03-01',20.25,1,20.25,1,'2022-05-01',NULL,NULL,NULL,NULL,'2022-04-01','2022-04-01',20.25,1),
	 ('HQB3hZuYcu0z8jVIl5bbug==','game 3','uk',17,false,'2022-10-01',61.80,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,61.80,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',96.87,3),
	 ('HQB3hZuYcu0z8jVIl5bbug==','game 3','uk',17,false,'2022-11-01',12.81,'2022-10-01','2022-12-01','2022-12-01',61.80,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-48.99,NULL,NULL,'2022-10-01','2022-12-01',96.87,3);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('HQB3hZuYcu0z8jVIl5bbug==','game 3','uk',17,false,'2022-12-01',22.26,'2022-11-01','2023-01-01',NULL,12.81,'2022-11-01',22.26,1,NULL,NULL,'2023-01-01',9.45,NULL,NULL,NULL,'2022-10-01','2022-12-01',96.87,3),
	 ('HRBsRwGu5mkTvZBTNpA0tQ==','game 3','ru',17,false,'2022-04-01',59.64,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,59.64,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-05-01',80.49,2),
	 ('HRBsRwGu5mkTvZBTNpA0tQ==','game 3','ru',17,false,'2022-05-01',20.85,'2022-04-01','2022-06-01',NULL,59.64,'2022-04-01',20.85,1,NULL,NULL,'2022-06-01',NULL,-38.79,NULL,NULL,'2022-04-01','2022-05-01',80.49,2),
	 ('hRkRI5YBVIH6bbqIDTbung==','game 3','uk',19,false,'2022-04-01',67.26,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,67.26,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-05-01',83.70,2),
	 ('hRkRI5YBVIH6bbqIDTbung==','game 3','uk',19,false,'2022-05-01',16.44,'2022-04-01','2022-06-01',NULL,67.26,'2022-04-01',16.44,1,NULL,NULL,'2022-06-01',NULL,-50.82,NULL,NULL,'2022-04-01','2022-05-01',83.70,2),
	 ('hvvcK5gx+FdZE6DZA3df+Q==','game 3','uk',29,false,'2022-07-01',13.92,NULL,'2022-08-01',NULL,NULL,'2022-06-01',13.92,1,13.92,1,'2022-08-01',NULL,NULL,NULL,NULL,'2022-07-01','2022-07-01',13.92,1),
	 ('HWpnvfSvYzUsQCcCKhetIg==','game 3','uk',19,false,'2022-07-01',28.23,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,28.23,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',399.60,6),
	 ('HWpnvfSvYzUsQCcCKhetIg==','game 3','uk',19,false,'2022-08-01',102.48,'2022-07-01','2022-09-01','2022-09-01',28.23,'2022-07-01',NULL,NULL,NULL,NULL,NULL,74.25,NULL,NULL,NULL,'2022-07-01','2022-12-01',399.60,6),
	 ('HWpnvfSvYzUsQCcCKhetIg==','game 3','uk',19,false,'2022-09-01',36.90,'2022-08-01','2022-10-01','2022-10-01',102.48,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-65.58,NULL,NULL,'2022-07-01','2022-12-01',399.60,6),
	 ('HWpnvfSvYzUsQCcCKhetIg==','game 3','uk',19,false,'2022-10-01',67.02,'2022-09-01','2022-11-01','2022-11-01',36.90,'2022-09-01',NULL,NULL,NULL,NULL,NULL,30.12,NULL,NULL,NULL,'2022-07-01','2022-12-01',399.60,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('HWpnvfSvYzUsQCcCKhetIg==','game 3','uk',19,false,'2022-11-01',73.20,'2022-10-01','2022-12-01','2022-12-01',67.02,'2022-10-01',NULL,NULL,NULL,NULL,NULL,6.18,NULL,NULL,NULL,'2022-07-01','2022-12-01',399.60,6),
	 ('HWpnvfSvYzUsQCcCKhetIg==','game 3','uk',19,false,'2022-12-01',91.77,'2022-11-01','2023-01-01',NULL,73.20,'2022-11-01',91.77,1,NULL,NULL,'2023-01-01',18.57,NULL,NULL,NULL,'2022-07-01','2022-12-01',399.60,6),
	 ('HxWcXHURvvtOJkrXAcDxQg==','game 3','uk',15,false,'2022-03-01',66.18,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,66.18,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-12-01',612.63,10),
	 ('HxWcXHURvvtOJkrXAcDxQg==','game 3','uk',15,false,'2022-04-01',82.53,'2022-03-01','2022-05-01','2022-05-01',66.18,'2022-03-01',NULL,NULL,NULL,NULL,NULL,16.35,NULL,NULL,NULL,'2022-03-01','2022-12-01',612.63,10),
	 ('HxWcXHURvvtOJkrXAcDxQg==','game 3','uk',15,false,'2022-05-01',122.94,'2022-04-01','2022-06-01','2022-06-01',82.53,'2022-04-01',NULL,NULL,NULL,NULL,NULL,40.41,NULL,NULL,NULL,'2022-03-01','2022-12-01',612.63,10),
	 ('HxWcXHURvvtOJkrXAcDxQg==','game 3','uk',15,false,'2022-06-01',66.96,'2022-05-01','2022-07-01','2022-07-01',122.94,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-55.98,NULL,NULL,'2022-03-01','2022-12-01',612.63,10),
	 ('HxWcXHURvvtOJkrXAcDxQg==','game 3','uk',15,false,'2022-07-01',41.67,'2022-06-01','2022-08-01','2022-08-01',66.96,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-25.29,NULL,NULL,'2022-03-01','2022-12-01',612.63,10),
	 ('HxWcXHURvvtOJkrXAcDxQg==','game 3','uk',15,false,'2022-08-01',71.64,'2022-07-01','2022-09-01','2022-09-01',41.67,'2022-07-01',NULL,NULL,NULL,NULL,NULL,29.97,NULL,NULL,NULL,'2022-03-01','2022-12-01',612.63,10),
	 ('HxWcXHURvvtOJkrXAcDxQg==','game 3','uk',15,false,'2022-09-01',42.72,'2022-08-01','2022-10-01','2022-10-01',71.64,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-28.92,NULL,NULL,'2022-03-01','2022-12-01',612.63,10),
	 ('HxWcXHURvvtOJkrXAcDxQg==','game 3','uk',15,false,'2022-10-01',38.40,'2022-09-01','2022-11-01','2022-11-01',42.72,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-4.32,NULL,NULL,'2022-03-01','2022-12-01',612.63,10);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('HxWcXHURvvtOJkrXAcDxQg==','game 3','uk',15,false,'2022-11-01',62.07,'2022-10-01','2022-12-01','2022-12-01',38.40,'2022-10-01',NULL,NULL,NULL,NULL,NULL,23.67,NULL,NULL,NULL,'2022-03-01','2022-12-01',612.63,10),
	 ('HxWcXHURvvtOJkrXAcDxQg==','game 3','uk',15,false,'2022-12-01',17.52,'2022-11-01','2023-01-01',NULL,62.07,'2022-11-01',17.52,1,NULL,NULL,'2023-01-01',NULL,-44.55,NULL,NULL,'2022-03-01','2022-12-01',612.63,10),
	 ('hZgZSp9Xf7/Bsye+tOipCA==','game 3','ru',19,false,'2022-12-01',62.82,NULL,'2023-01-01',NULL,NULL,'2022-11-01',62.82,1,62.82,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',62.82,1),
	 ('HZqx1XVZ1mb7lM9T61x+DA==','game 3','ru',43,false,'2022-04-01',14.61,NULL,'2022-05-01','2022-08-01',NULL,'2022-03-01',14.61,1,14.61,1,'2022-05-01',NULL,NULL,NULL,NULL,'2022-04-01','2022-11-01',41.94,8),
	 ('HZqx1XVZ1mb7lM9T61x+DA==','game 3','ru',43,false,'2022-08-01',13.47,'2022-04-01','2022-09-01','2022-11-01',14.61,'2022-07-01',13.47,1,NULL,NULL,'2022-09-01',NULL,NULL,13.47,1,'2022-04-01','2022-11-01',41.94,8),
	 ('HZqx1XVZ1mb7lM9T61x+DA==','game 3','ru',43,false,'2022-11-01',13.86,'2022-08-01','2022-12-01',NULL,13.47,'2022-10-01',13.86,1,NULL,NULL,'2022-12-01',NULL,NULL,13.86,1,'2022-04-01','2022-11-01',41.94,8),
	 ('i0Pv5hwwYBxiPeCQ/AmnxQ==','game 3','ru',17,false,'2022-12-01',62.61,NULL,'2023-01-01',NULL,NULL,'2022-11-01',62.61,1,62.61,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',62.61,1),
	 ('I8yTxTfERu6jtLOfWB0dFQ==','game 3','ru',33,false,'2022-09-01',43.29,NULL,'2022-10-01',NULL,NULL,'2022-08-01',43.29,1,43.29,1,'2022-10-01',NULL,NULL,NULL,NULL,'2022-09-01','2022-09-01',43.29,1),
	 ('ICBVvRc9TR+qF7IoBfEWsQ==','game 3','uk',18,true,'2022-08-01',44.37,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,44.37,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-11-01',198.99,4),
	 ('ICBVvRc9TR+qF7IoBfEWsQ==','game 3','uk',18,true,'2022-09-01',41.91,'2022-08-01','2022-10-01','2022-10-01',44.37,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-2.46,NULL,NULL,'2022-08-01','2022-11-01',198.99,4);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('ICBVvRc9TR+qF7IoBfEWsQ==','game 3','uk',18,true,'2022-10-01',80.73,'2022-09-01','2022-11-01','2022-11-01',41.91,'2022-09-01',NULL,NULL,NULL,NULL,NULL,38.82,NULL,NULL,NULL,'2022-08-01','2022-11-01',198.99,4),
	 ('ICBVvRc9TR+qF7IoBfEWsQ==','game 3','uk',18,true,'2022-11-01',31.98,'2022-10-01','2022-12-01',NULL,80.73,'2022-10-01',31.98,1,NULL,NULL,'2022-12-01',NULL,-48.75,NULL,NULL,'2022-08-01','2022-11-01',198.99,4),
	 ('IdKyooyTjAbvCA7p+ujKCw==','game 3','uk',19,false,'2022-05-01',153.54,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,153.54,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-12-01',483.54,8),
	 ('IdKyooyTjAbvCA7p+ujKCw==','game 3','uk',19,false,'2022-06-01',103.14,'2022-05-01','2022-07-01','2022-07-01',153.54,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-50.40,NULL,NULL,'2022-05-01','2022-12-01',483.54,8),
	 ('IdKyooyTjAbvCA7p+ujKCw==','game 3','uk',19,false,'2022-07-01',84.45,'2022-06-01','2022-08-01','2022-08-01',103.14,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-18.69,NULL,NULL,'2022-05-01','2022-12-01',483.54,8),
	 ('IdKyooyTjAbvCA7p+ujKCw==','game 3','uk',19,false,'2022-08-01',54.24,'2022-07-01','2022-09-01','2022-09-01',84.45,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-30.21,NULL,NULL,'2022-05-01','2022-12-01',483.54,8),
	 ('IdKyooyTjAbvCA7p+ujKCw==','game 3','uk',19,false,'2022-09-01',41.61,'2022-08-01','2022-10-01','2022-12-01',54.24,'2022-08-01',41.61,1,NULL,NULL,'2022-10-01',NULL,-12.63,NULL,NULL,'2022-05-01','2022-12-01',483.54,8),
	 ('IdKyooyTjAbvCA7p+ujKCw==','game 3','uk',19,false,'2022-12-01',46.56,'2022-09-01','2023-01-01',NULL,41.61,'2022-11-01',46.56,1,NULL,NULL,'2023-01-01',NULL,NULL,46.56,1,'2022-05-01','2022-12-01',483.54,8),
	 ('iFFApiXZ2wPdS666BLpKZw==','game 3','uk',18,false,'2022-03-01',26.85,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,26.85,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-10-01',248.28,8),
	 ('iFFApiXZ2wPdS666BLpKZw==','game 3','uk',18,false,'2022-04-01',49.92,'2022-03-01','2022-05-01','2022-06-01',26.85,'2022-03-01',49.92,1,NULL,NULL,'2022-05-01',23.07,NULL,NULL,NULL,'2022-03-01','2022-10-01',248.28,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('iFFApiXZ2wPdS666BLpKZw==','game 3','uk',18,false,'2022-06-01',34.89,'2022-04-01','2022-07-01','2022-07-01',49.92,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,34.89,1,'2022-03-01','2022-10-01',248.28,8),
	 ('iFFApiXZ2wPdS666BLpKZw==','game 3','uk',18,false,'2022-07-01',48.78,'2022-06-01','2022-08-01','2022-08-01',34.89,'2022-06-01',NULL,NULL,NULL,NULL,NULL,13.89,NULL,NULL,NULL,'2022-03-01','2022-10-01',248.28,8),
	 ('iFFApiXZ2wPdS666BLpKZw==','game 3','uk',18,false,'2022-08-01',18.42,'2022-07-01','2022-09-01','2022-09-01',48.78,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-30.36,NULL,NULL,'2022-03-01','2022-10-01',248.28,8),
	 ('iFFApiXZ2wPdS666BLpKZw==','game 3','uk',18,false,'2022-09-01',53.94,'2022-08-01','2022-10-01','2022-10-01',18.42,'2022-08-01',NULL,NULL,NULL,NULL,NULL,35.52,NULL,NULL,NULL,'2022-03-01','2022-10-01',248.28,8),
	 ('iFFApiXZ2wPdS666BLpKZw==','game 3','uk',18,false,'2022-10-01',15.48,'2022-09-01','2022-11-01',NULL,53.94,'2022-09-01',15.48,1,NULL,NULL,'2022-11-01',NULL,-38.46,NULL,NULL,'2022-03-01','2022-10-01',248.28,8),
	 ('iFnn4bfYgNs8OS5MCcLjeA==','game 3','uk',28,false,'2022-04-01',18.39,NULL,'2022-05-01','2022-07-01',NULL,'2022-03-01',18.39,1,18.39,1,'2022-05-01',NULL,NULL,NULL,NULL,'2022-04-01','2022-11-01',144.48,8),
	 ('iFnn4bfYgNs8OS5MCcLjeA==','game 3','uk',28,false,'2022-07-01',21.39,'2022-04-01','2022-08-01','2022-09-01',18.39,'2022-06-01',21.39,1,NULL,NULL,'2022-08-01',NULL,NULL,21.39,1,'2022-04-01','2022-11-01',144.48,8),
	 ('iFnn4bfYgNs8OS5MCcLjeA==','game 3','uk',28,false,'2022-09-01',27.93,'2022-07-01','2022-10-01','2022-10-01',21.39,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,27.93,1,'2022-04-01','2022-11-01',144.48,8),
	 ('iFnn4bfYgNs8OS5MCcLjeA==','game 3','uk',28,false,'2022-10-01',61.77,'2022-09-01','2022-11-01','2022-11-01',27.93,'2022-09-01',NULL,NULL,NULL,NULL,NULL,33.84,NULL,NULL,NULL,'2022-04-01','2022-11-01',144.48,8),
	 ('iFnn4bfYgNs8OS5MCcLjeA==','game 3','uk',28,false,'2022-11-01',15.0,'2022-10-01','2022-12-01',NULL,61.77,'2022-10-01',15.0,1,NULL,NULL,'2022-12-01',NULL,-46.77,NULL,NULL,'2022-04-01','2022-11-01',144.48,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('iG1GfeiUaaoT1pZksh8QKw==','game 3','uk',39,false,'2022-11-01',13.65,NULL,'2022-12-01',NULL,NULL,'2022-10-01',13.65,1,13.65,1,'2022-12-01',NULL,NULL,NULL,NULL,'2022-11-01','2022-11-01',13.65,1),
	 ('iIytnKqiHLJVVoC/S4HgPQ==','game 3','ru',24,false,'2022-07-01',12.51,NULL,'2022-08-01',NULL,NULL,'2022-06-01',12.51,1,12.51,1,'2022-08-01',NULL,NULL,NULL,NULL,'2022-07-01','2022-07-01',12.51,1),
	 ('ildaqkizLaFesmkjCvlzmQ==','game 3','uk',24,false,'2022-06-01',54.54,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,54.54,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-11-01',192.15,6),
	 ('ildaqkizLaFesmkjCvlzmQ==','game 3','uk',24,false,'2022-07-01',17.07,'2022-06-01','2022-08-01','2022-08-01',54.54,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-37.47,NULL,NULL,'2022-06-01','2022-11-01',192.15,6),
	 ('ildaqkizLaFesmkjCvlzmQ==','game 3','uk',24,false,'2022-08-01',58.23,'2022-07-01','2022-09-01','2022-09-01',17.07,'2022-07-01',NULL,NULL,NULL,NULL,NULL,41.16,NULL,NULL,NULL,'2022-06-01','2022-11-01',192.15,6),
	 ('ildaqkizLaFesmkjCvlzmQ==','game 3','uk',24,false,'2022-09-01',50.19,'2022-08-01','2022-10-01','2022-11-01',58.23,'2022-08-01',50.19,1,NULL,NULL,'2022-10-01',NULL,-8.04,NULL,NULL,'2022-06-01','2022-11-01',192.15,6),
	 ('ildaqkizLaFesmkjCvlzmQ==','game 3','uk',24,false,'2022-11-01',12.12,'2022-09-01','2022-12-01',NULL,50.19,'2022-10-01',12.12,1,NULL,NULL,'2022-12-01',NULL,NULL,12.12,1,'2022-06-01','2022-11-01',192.15,6),
	 ('ilnMSoPJHAYMegDX02XG+w==','game 3','uk',25,false,'2022-04-01',54.03,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,54.03,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-05-01',118.89,2),
	 ('ilnMSoPJHAYMegDX02XG+w==','game 3','uk',25,false,'2022-05-01',64.86,'2022-04-01','2022-06-01',NULL,54.03,'2022-04-01',64.86,1,NULL,NULL,'2022-06-01',10.83,NULL,NULL,NULL,'2022-04-01','2022-05-01',118.89,2),
	 ('IS/yKhM20myJT0Ua+1Rk1w==','game 1','uk',26,false,'2022-11-01',30.54,NULL,'2022-12-01',NULL,NULL,'2022-10-01',30.54,1,30.54,1,'2022-12-01',NULL,NULL,NULL,NULL,'2022-11-01','2022-11-01',30.54,1);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('iw2tiT4Ar7pk2PlF0Jd6Yw==','game 3','ru',25,false,'2022-12-01',78.00,NULL,'2023-01-01',NULL,NULL,'2022-11-01',78.00,1,78.00,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',78.00,1),
	 ('J6WNl39fdxaY8ZtvV8wNkw==','game 3','uk',18,true,'2022-03-01',16.14,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,16.14,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-06-01',101.40,4),
	 ('J6WNl39fdxaY8ZtvV8wNkw==','game 3','uk',18,true,'2022-04-01',18.42,'2022-03-01','2022-05-01','2022-05-01',16.14,'2022-03-01',NULL,NULL,NULL,NULL,NULL,2.28,NULL,NULL,NULL,'2022-03-01','2022-06-01',101.40,4),
	 ('J6WNl39fdxaY8ZtvV8wNkw==','game 3','uk',18,true,'2022-05-01',24.99,'2022-04-01','2022-06-01','2022-06-01',18.42,'2022-04-01',NULL,NULL,NULL,NULL,NULL,6.57,NULL,NULL,NULL,'2022-03-01','2022-06-01',101.40,4),
	 ('J6WNl39fdxaY8ZtvV8wNkw==','game 3','uk',18,true,'2022-06-01',41.85,'2022-05-01','2022-07-01',NULL,24.99,'2022-05-01',41.85,1,NULL,NULL,'2022-07-01',16.86,NULL,NULL,NULL,'2022-03-01','2022-06-01',101.40,4),
	 ('JBV4ilPNTtWevrqq146kyg==','game 3','uk',43,false,'2022-06-01',16.38,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,16.38,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-07-01',50.97,2),
	 ('JBV4ilPNTtWevrqq146kyg==','game 3','uk',43,false,'2022-07-01',34.59,'2022-06-01','2022-08-01',NULL,16.38,'2022-06-01',34.59,1,NULL,NULL,'2022-08-01',18.21,NULL,NULL,NULL,'2022-06-01','2022-07-01',50.97,2),
	 ('jKSOgyMP0Yzld1pVpvyYrg==','game 3','uk',36,false,'2022-05-01',15.06,NULL,'2022-06-01','2022-08-01',NULL,'2022-04-01',15.06,1,15.06,1,'2022-06-01',NULL,NULL,NULL,NULL,'2022-05-01','2022-11-01',53.97,7),
	 ('jKSOgyMP0Yzld1pVpvyYrg==','game 3','uk',36,false,'2022-08-01',26.31,'2022-05-01','2022-09-01','2022-11-01',15.06,'2022-07-01',26.31,1,NULL,NULL,'2022-09-01',NULL,NULL,26.31,1,'2022-05-01','2022-11-01',53.97,7),
	 ('jKSOgyMP0Yzld1pVpvyYrg==','game 3','uk',36,false,'2022-11-01',12.6,'2022-08-01','2022-12-01',NULL,26.31,'2022-10-01',12.6,1,NULL,NULL,'2022-12-01',NULL,NULL,12.6,1,'2022-05-01','2022-11-01',53.97,7);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('jM8s8LsWXTBSKnIgg7UVjQ==','game 3','uk',30,false,'2022-12-01',12.6,NULL,'2023-01-01',NULL,NULL,'2022-11-01',12.6,1,12.6,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',12.6,1),
	 ('Jp0hnV9XOJGVV5jpFhlqgQ==','game 3','uk',25,false,'2022-03-01',122.64,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,122.64,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-11-01',422.28,9),
	 ('Jp0hnV9XOJGVV5jpFhlqgQ==','game 3','uk',25,false,'2022-04-01',56.16,'2022-03-01','2022-05-01','2022-05-01',122.64,'2022-03-01',NULL,NULL,NULL,NULL,NULL,NULL,-66.48,NULL,NULL,'2022-03-01','2022-11-01',422.28,9),
	 ('Jp0hnV9XOJGVV5jpFhlqgQ==','game 3','uk',25,false,'2022-05-01',18.06,'2022-04-01','2022-06-01','2022-06-01',56.16,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-38.10,NULL,NULL,'2022-03-01','2022-11-01',422.28,9),
	 ('Jp0hnV9XOJGVV5jpFhlqgQ==','game 3','uk',25,false,'2022-06-01',63.39,'2022-05-01','2022-07-01','2022-08-01',18.06,'2022-05-01',63.39,1,NULL,NULL,'2022-07-01',45.33,NULL,NULL,NULL,'2022-03-01','2022-11-01',422.28,9),
	 ('Jp0hnV9XOJGVV5jpFhlqgQ==','game 3','uk',25,false,'2022-08-01',56.10,'2022-06-01','2022-09-01','2022-10-01',63.39,'2022-07-01',56.10,1,NULL,NULL,'2022-09-01',NULL,NULL,56.10,1,'2022-03-01','2022-11-01',422.28,9),
	 ('Jp0hnV9XOJGVV5jpFhlqgQ==','game 3','uk',25,false,'2022-10-01',46.89,'2022-08-01','2022-11-01','2022-11-01',56.10,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,46.89,1,'2022-03-01','2022-11-01',422.28,9),
	 ('Jp0hnV9XOJGVV5jpFhlqgQ==','game 3','uk',25,false,'2022-11-01',59.04,'2022-10-01','2022-12-01',NULL,46.89,'2022-10-01',59.04,1,NULL,NULL,'2022-12-01',12.15,NULL,NULL,NULL,'2022-03-01','2022-11-01',422.28,9),
	 ('jQW6YmVUlZdePPY7F9NgMg==','game 3','uk',30,false,'2022-09-01',12.12,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,12.12,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-11-01',111.36,3),
	 ('jQW6YmVUlZdePPY7F9NgMg==','game 3','uk',30,false,'2022-10-01',40.92,'2022-09-01','2022-11-01','2022-11-01',12.12,'2022-09-01',NULL,NULL,NULL,NULL,NULL,28.80,NULL,NULL,NULL,'2022-09-01','2022-11-01',111.36,3);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('jQW6YmVUlZdePPY7F9NgMg==','game 3','uk',30,false,'2022-11-01',58.32,'2022-10-01','2022-12-01',NULL,40.92,'2022-10-01',58.32,1,NULL,NULL,'2022-12-01',17.40,NULL,NULL,NULL,'2022-09-01','2022-11-01',111.36,3),
	 ('juwM8fLyplCQTgKTP8dJgQ==','game 3','ru',34,false,'2022-07-01',15.45,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,15.45,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-11-01',150.93,5),
	 ('juwM8fLyplCQTgKTP8dJgQ==','game 3','ru',34,false,'2022-08-01',13.65,'2022-07-01','2022-09-01','2022-09-01',15.45,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-1.80,NULL,NULL,'2022-07-01','2022-11-01',150.93,5),
	 ('juwM8fLyplCQTgKTP8dJgQ==','game 3','ru',34,false,'2022-09-01',49.89,'2022-08-01','2022-10-01','2022-10-01',13.65,'2022-08-01',NULL,NULL,NULL,NULL,NULL,36.24,NULL,NULL,NULL,'2022-07-01','2022-11-01',150.93,5),
	 ('juwM8fLyplCQTgKTP8dJgQ==','game 3','ru',34,false,'2022-10-01',55.50,'2022-09-01','2022-11-01','2022-11-01',49.89,'2022-09-01',NULL,NULL,NULL,NULL,NULL,5.61,NULL,NULL,NULL,'2022-07-01','2022-11-01',150.93,5),
	 ('juwM8fLyplCQTgKTP8dJgQ==','game 3','ru',34,false,'2022-11-01',16.44,'2022-10-01','2022-12-01',NULL,55.50,'2022-10-01',16.44,1,NULL,NULL,'2022-12-01',NULL,-39.06,NULL,NULL,'2022-07-01','2022-11-01',150.93,5),
	 ('jVhb69DTRT5TSWYEiUrlbg==','game 3','uk',20,false,'2022-03-01',17.46,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,17.46,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-12-01',443.16,10),
	 ('jVhb69DTRT5TSWYEiUrlbg==','game 3','uk',20,false,'2022-04-01',58.44,'2022-03-01','2022-05-01','2022-05-01',17.46,'2022-03-01',NULL,NULL,NULL,NULL,NULL,40.98,NULL,NULL,NULL,'2022-03-01','2022-12-01',443.16,10),
	 ('jVhb69DTRT5TSWYEiUrlbg==','game 3','uk',20,false,'2022-05-01',54.27,'2022-04-01','2022-06-01','2022-06-01',58.44,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-4.17,NULL,NULL,'2022-03-01','2022-12-01',443.16,10),
	 ('jVhb69DTRT5TSWYEiUrlbg==','game 3','uk',20,false,'2022-06-01',66.45,'2022-05-01','2022-07-01','2022-07-01',54.27,'2022-05-01',NULL,NULL,NULL,NULL,NULL,12.18,NULL,NULL,NULL,'2022-03-01','2022-12-01',443.16,10);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('jVhb69DTRT5TSWYEiUrlbg==','game 3','uk',20,false,'2022-07-01',36.21,'2022-06-01','2022-08-01','2022-08-01',66.45,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-30.24,NULL,NULL,'2022-03-01','2022-12-01',443.16,10),
	 ('jVhb69DTRT5TSWYEiUrlbg==','game 3','uk',20,false,'2022-08-01',24.09,'2022-07-01','2022-09-01','2022-09-01',36.21,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-12.12,NULL,NULL,'2022-03-01','2022-12-01',443.16,10),
	 ('jVhb69DTRT5TSWYEiUrlbg==','game 3','uk',20,false,'2022-09-01',42.39,'2022-08-01','2022-10-01','2022-10-01',24.09,'2022-08-01',NULL,NULL,NULL,NULL,NULL,18.30,NULL,NULL,NULL,'2022-03-01','2022-12-01',443.16,10),
	 ('jVhb69DTRT5TSWYEiUrlbg==','game 3','uk',20,false,'2022-10-01',78.48,'2022-09-01','2022-11-01','2022-11-01',42.39,'2022-09-01',NULL,NULL,NULL,NULL,NULL,36.09,NULL,NULL,NULL,'2022-03-01','2022-12-01',443.16,10),
	 ('jVhb69DTRT5TSWYEiUrlbg==','game 3','uk',20,false,'2022-11-01',25.38,'2022-10-01','2022-12-01','2022-12-01',78.48,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-53.10,NULL,NULL,'2022-03-01','2022-12-01',443.16,10),
	 ('jVhb69DTRT5TSWYEiUrlbg==','game 3','uk',20,false,'2022-12-01',39.99,'2022-11-01','2023-01-01',NULL,25.38,'2022-11-01',39.99,1,NULL,NULL,'2023-01-01',14.61,NULL,NULL,NULL,'2022-03-01','2022-12-01',443.16,10),
	 ('JZddlB04roDQYT2zrRPBcA==','game 3','uk',44,false,'2022-08-01',12.45,NULL,'2022-09-01',NULL,NULL,'2022-07-01',12.45,1,12.45,1,'2022-09-01',NULL,NULL,NULL,NULL,'2022-08-01','2022-08-01',12.45,1),
	 ('K5c4Zypq0/6iQYmv/Dqm5A==','game 3','uk',21,false,'2022-10-01',24.96,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,24.96,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-11-01',43.08,2),
	 ('K5c4Zypq0/6iQYmv/Dqm5A==','game 3','uk',21,false,'2022-11-01',18.12,'2022-10-01','2022-12-01',NULL,24.96,'2022-10-01',18.12,1,NULL,NULL,'2022-12-01',NULL,-6.84,NULL,NULL,'2022-10-01','2022-11-01',43.08,2),
	 ('K/6KHxREKTlFZXRfBNVNuQ==','game 3','ru',19,false,'2022-04-01',41.46,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,41.46,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-10-01',155.79,7);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('K/6KHxREKTlFZXRfBNVNuQ==','game 3','ru',19,false,'2022-05-01',13.26,'2022-04-01','2022-06-01','2022-06-01',41.46,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-28.20,NULL,NULL,'2022-04-01','2022-10-01',155.79,7),
	 ('K/6KHxREKTlFZXRfBNVNuQ==','game 3','ru',19,false,'2022-06-01',14.64,'2022-05-01','2022-07-01','2022-07-01',13.26,'2022-05-01',NULL,NULL,NULL,NULL,NULL,1.38,NULL,NULL,NULL,'2022-04-01','2022-10-01',155.79,7),
	 ('K/6KHxREKTlFZXRfBNVNuQ==','game 3','ru',19,false,'2022-07-01',38.07,'2022-06-01','2022-08-01','2022-09-01',14.64,'2022-06-01',38.07,1,NULL,NULL,'2022-08-01',23.43,NULL,NULL,NULL,'2022-04-01','2022-10-01',155.79,7),
	 ('K/6KHxREKTlFZXRfBNVNuQ==','game 3','ru',19,false,'2022-09-01',31.53,'2022-07-01','2022-10-01','2022-10-01',38.07,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,31.53,1,'2022-04-01','2022-10-01',155.79,7),
	 ('K/6KHxREKTlFZXRfBNVNuQ==','game 3','ru',19,false,'2022-10-01',16.83,'2022-09-01','2022-11-01',NULL,31.53,'2022-09-01',16.83,1,NULL,NULL,'2022-11-01',NULL,-14.70,NULL,NULL,'2022-04-01','2022-10-01',155.79,7),
	 ('kAGCRMpNBghYDdEZ7r3Ptg==','game 2','en',31,false,'2022-08-01',12.93,NULL,'2022-09-01',NULL,NULL,'2022-07-01',12.93,1,12.93,1,'2022-09-01',NULL,NULL,NULL,NULL,'2022-08-01','2022-08-01',12.93,1),
	 ('KFO5m0KyIyGE1D5YZHC8Wg==','game 1','uk',21,true,'2022-10-01',25.71,NULL,'2022-11-01',NULL,NULL,'2022-09-01',25.71,1,25.71,1,'2022-11-01',NULL,NULL,NULL,NULL,'2022-10-01','2022-10-01',25.71,1),
	 ('kGxMA4SONgR8wL4JeeX8PQ==','game 3','uk',23,false,'2022-12-01',32.37,NULL,'2023-01-01',NULL,NULL,'2022-11-01',32.37,1,32.37,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',32.37,1),
	 ('k+mv8oxK5y+607GU9LGO+A==','game 3','uk',17,false,'2022-10-01',49.65,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,49.65,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-11-01',82.41,2),
	 ('k+mv8oxK5y+607GU9LGO+A==','game 3','uk',17,false,'2022-11-01',32.76,'2022-10-01','2022-12-01',NULL,49.65,'2022-10-01',32.76,1,NULL,NULL,'2022-12-01',NULL,-16.89,NULL,NULL,'2022-10-01','2022-11-01',82.41,2);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('Krr8Kwf65LaX8LctHRsFWg==','game 3','ru',16,false,'2022-10-01',72.36,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,72.36,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',185.64,3),
	 ('Krr8Kwf65LaX8LctHRsFWg==','game 3','ru',16,false,'2022-11-01',65.40,'2022-10-01','2022-12-01','2022-12-01',72.36,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-6.96,NULL,NULL,'2022-10-01','2022-12-01',185.64,3),
	 ('Krr8Kwf65LaX8LctHRsFWg==','game 3','ru',16,false,'2022-12-01',47.88,'2022-11-01','2023-01-01',NULL,65.40,'2022-11-01',47.88,1,NULL,NULL,'2023-01-01',NULL,-17.52,NULL,NULL,'2022-10-01','2022-12-01',185.64,3),
	 ('l3sFUsG2qpcnrEzwRnjvtQ==','game 3','ru',15,false,'2022-03-01',38.10,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,38.10,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-04-01',97.83,2),
	 ('l3sFUsG2qpcnrEzwRnjvtQ==','game 3','ru',15,false,'2022-04-01',59.73,'2022-03-01','2022-05-01',NULL,38.10,'2022-03-01',59.73,1,NULL,NULL,'2022-05-01',21.63,NULL,NULL,NULL,'2022-03-01','2022-04-01',97.83,2),
	 ('L3waZ4UDUTOCMfVcL29lGQ==','game 3','en',29,false,'2022-12-01',45.06,NULL,'2023-01-01',NULL,NULL,'2022-11-01',45.06,1,45.06,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',45.06,1),
	 ('L8+KU8u6xftnkFVO501X7w==','game 3','uk',30,false,'2022-07-01',14.04,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,14.04,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-08-01',28.59,2),
	 ('L8+KU8u6xftnkFVO501X7w==','game 3','uk',30,false,'2022-08-01',14.55,'2022-07-01','2022-09-01',NULL,14.04,'2022-07-01',14.55,1,NULL,NULL,'2022-09-01',0.51,NULL,NULL,NULL,'2022-07-01','2022-08-01',28.59,2),
	 ('lCD23Awt3KotauWenCRr5w==','game 3','uk',20,false,'2022-04-01',47.94,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,47.94,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-07-01',161.67,4),
	 ('lCD23Awt3KotauWenCRr5w==','game 3','uk',20,false,'2022-05-01',90.75,'2022-04-01','2022-06-01','2022-07-01',47.94,'2022-04-01',90.75,1,NULL,NULL,'2022-06-01',42.81,NULL,NULL,NULL,'2022-04-01','2022-07-01',161.67,4);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('lCD23Awt3KotauWenCRr5w==','game 3','uk',20,false,'2022-07-01',22.98,'2022-05-01','2022-08-01',NULL,90.75,'2022-06-01',22.98,1,NULL,NULL,'2022-08-01',NULL,NULL,22.98,1,'2022-04-01','2022-07-01',161.67,4),
	 ('lGI5+OCzV6nnDMpyZWtZAg==','game 3','ru',18,false,'2022-05-01',17.25,NULL,'2022-06-01',NULL,NULL,'2022-04-01',17.25,1,17.25,1,'2022-06-01',NULL,NULL,NULL,NULL,'2022-05-01','2022-05-01',17.25,1),
	 ('lHTzlMgVj6HJZc31yCCDng==','game 3','uk',19,false,'2022-10-01',46.29,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,46.29,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-11-01',61.02,2),
	 ('lHTzlMgVj6HJZc31yCCDng==','game 3','uk',19,false,'2022-11-01',14.73,'2022-10-01','2022-12-01',NULL,46.29,'2022-10-01',14.73,1,NULL,NULL,'2022-12-01',NULL,-31.56,NULL,NULL,'2022-10-01','2022-11-01',61.02,2),
	 ('lJW2nxFOiXDfsmSrwGsFQw==','game 3','uk',20,false,'2022-08-01',69.18,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,69.18,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',190.68,5),
	 ('lJW2nxFOiXDfsmSrwGsFQw==','game 3','uk',20,false,'2022-09-01',66.33,'2022-08-01','2022-10-01','2022-10-01',69.18,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-2.85,NULL,NULL,'2022-08-01','2022-12-01',190.68,5),
	 ('lJW2nxFOiXDfsmSrwGsFQw==','game 3','uk',20,false,'2022-10-01',23.79,'2022-09-01','2022-11-01','2022-12-01',66.33,'2022-09-01',23.79,1,NULL,NULL,'2022-11-01',NULL,-42.54,NULL,NULL,'2022-08-01','2022-12-01',190.68,5),
	 ('lJW2nxFOiXDfsmSrwGsFQw==','game 3','uk',20,false,'2022-12-01',31.38,'2022-10-01','2023-01-01',NULL,23.79,'2022-11-01',31.38,1,NULL,NULL,'2023-01-01',NULL,NULL,31.38,1,'2022-08-01','2022-12-01',190.68,5),
	 ('LO9NuZYI6zP2HXEBAS4wpw==','game 3','uk',23,false,'2022-09-01',15.78,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,15.78,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',141.45,4),
	 ('LO9NuZYI6zP2HXEBAS4wpw==','game 3','uk',23,false,'2022-10-01',29.31,'2022-09-01','2022-11-01','2022-11-01',15.78,'2022-09-01',NULL,NULL,NULL,NULL,NULL,13.53,NULL,NULL,NULL,'2022-09-01','2022-12-01',141.45,4);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('LO9NuZYI6zP2HXEBAS4wpw==','game 3','uk',23,false,'2022-11-01',50.76,'2022-10-01','2022-12-01','2022-12-01',29.31,'2022-10-01',NULL,NULL,NULL,NULL,NULL,21.45,NULL,NULL,NULL,'2022-09-01','2022-12-01',141.45,4),
	 ('LO9NuZYI6zP2HXEBAS4wpw==','game 3','uk',23,false,'2022-12-01',45.60,'2022-11-01','2023-01-01',NULL,50.76,'2022-11-01',45.60,1,NULL,NULL,'2023-01-01',NULL,-5.16,NULL,NULL,'2022-09-01','2022-12-01',141.45,4),
	 ('lP6BWSFF4OZeWp0jrAHY9g==','game 3','uk',29,false,'2022-05-01',13.2,NULL,'2022-06-01','2022-11-01',NULL,'2022-04-01',13.2,1,13.2,1,'2022-06-01',NULL,NULL,NULL,NULL,'2022-05-01','2022-12-01',78.96,8),
	 ('lP6BWSFF4OZeWp0jrAHY9g==','game 3','uk',29,false,'2022-11-01',29.16,'2022-05-01','2022-12-01','2022-12-01',13.2,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,29.16,1,'2022-05-01','2022-12-01',78.96,8),
	 ('lP6BWSFF4OZeWp0jrAHY9g==','game 3','uk',29,false,'2022-12-01',36.6,'2022-11-01','2023-01-01',NULL,29.16,'2022-11-01',36.6,1,NULL,NULL,'2023-01-01',7.44,NULL,NULL,NULL,'2022-05-01','2022-12-01',78.96,8),
	 ('LuDHi0aoGmgpUtTGreh0fQ==','game 3','uk',22,true,'2022-12-01',12.09,NULL,'2023-01-01',NULL,NULL,'2022-11-01',12.09,1,12.09,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',12.09,1),
	 ('Lug+Yg90jslWgHEN6dc+Ng==','game 3','uk',21,false,'2022-04-01',82.23,NULL,'2022-05-01','2022-06-01',NULL,'2022-03-01',82.23,1,82.23,1,'2022-05-01',NULL,NULL,NULL,NULL,'2022-04-01','2022-12-01',298.92,9),
	 ('Lug+Yg90jslWgHEN6dc+Ng==','game 3','uk',21,false,'2022-06-01',18.66,'2022-04-01','2022-07-01','2022-07-01',82.23,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,18.66,1,'2022-04-01','2022-12-01',298.92,9),
	 ('Lug+Yg90jslWgHEN6dc+Ng==','game 3','uk',21,false,'2022-07-01',93.36,'2022-06-01','2022-08-01','2022-08-01',18.66,'2022-06-01',NULL,NULL,NULL,NULL,NULL,74.70,NULL,NULL,NULL,'2022-04-01','2022-12-01',298.92,9),
	 ('Lug+Yg90jslWgHEN6dc+Ng==','game 3','uk',21,false,'2022-08-01',58.50,'2022-07-01','2022-09-01','2022-11-01',93.36,'2022-07-01',58.50,1,NULL,NULL,'2022-09-01',NULL,-34.86,NULL,NULL,'2022-04-01','2022-12-01',298.92,9);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('Lug+Yg90jslWgHEN6dc+Ng==','game 3','uk',21,false,'2022-11-01',13.08,'2022-08-01','2022-12-01','2022-12-01',58.50,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,13.08,1,'2022-04-01','2022-12-01',298.92,9),
	 ('Lug+Yg90jslWgHEN6dc+Ng==','game 3','uk',21,false,'2022-12-01',33.09,'2022-11-01','2023-01-01',NULL,13.08,'2022-11-01',33.09,1,NULL,NULL,'2023-01-01',20.01,NULL,NULL,NULL,'2022-04-01','2022-12-01',298.92,9),
	 ('L+wA3BIaEKSpxf2uqmtJxQ==','game 3','uk',25,true,'2022-11-01',68.43,NULL,'2022-12-01','2022-12-01',NULL,'2022-10-01',NULL,NULL,68.43,1,NULL,NULL,NULL,NULL,NULL,'2022-11-01','2022-12-01',105.57,2),
	 ('L+wA3BIaEKSpxf2uqmtJxQ==','game 3','uk',25,true,'2022-12-01',37.14,'2022-11-01','2023-01-01',NULL,68.43,'2022-11-01',37.14,1,NULL,NULL,'2023-01-01',NULL,-31.29,NULL,NULL,'2022-11-01','2022-12-01',105.57,2),
	 ('LWAxWBdiFs/25YxI4ZGthA==','game 3','ru',17,true,'2022-05-01',86.46,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,86.46,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-06-01',105.00,2),
	 ('LWAxWBdiFs/25YxI4ZGthA==','game 3','ru',17,true,'2022-06-01',18.54,'2022-05-01','2022-07-01',NULL,86.46,'2022-05-01',18.54,1,NULL,NULL,'2022-07-01',NULL,-67.92,NULL,NULL,'2022-05-01','2022-06-01',105.00,2),
	 ('lx3SsUV7NOrv93tCexVp5A==','game 3','uk',16,false,'2022-07-01',36.21,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,36.21,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',123.33,6),
	 ('lx3SsUV7NOrv93tCexVp5A==','game 3','uk',16,false,'2022-08-01',17.22,'2022-07-01','2022-09-01','2022-09-01',36.21,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-18.99,NULL,NULL,'2022-07-01','2022-12-01',123.33,6),
	 ('lx3SsUV7NOrv93tCexVp5A==','game 3','uk',16,false,'2022-09-01',23.85,'2022-08-01','2022-10-01','2022-10-01',17.22,'2022-08-01',NULL,NULL,NULL,NULL,NULL,6.63,NULL,NULL,NULL,'2022-07-01','2022-12-01',123.33,6),
	 ('lx3SsUV7NOrv93tCexVp5A==','game 3','uk',16,false,'2022-10-01',29.85,'2022-09-01','2022-11-01','2022-12-01',23.85,'2022-09-01',29.85,1,NULL,NULL,'2022-11-01',6.00,NULL,NULL,NULL,'2022-07-01','2022-12-01',123.33,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('lx3SsUV7NOrv93tCexVp5A==','game 3','uk',16,false,'2022-12-01',16.2,'2022-10-01','2023-01-01',NULL,29.85,'2022-11-01',16.2,1,NULL,NULL,'2023-01-01',NULL,NULL,16.2,1,'2022-07-01','2022-12-01',123.33,6),
	 ('m7Hk77dySHBbxrKgro1Hjg==','game 3','uk',30,false,'2022-07-01',22.77,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,22.77,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-11-01',55.50,5),
	 ('m7Hk77dySHBbxrKgro1Hjg==','game 3','uk',30,false,'2022-08-01',18.84,'2022-07-01','2022-09-01','2022-11-01',22.77,'2022-07-01',18.84,1,NULL,NULL,'2022-09-01',NULL,-3.93,NULL,NULL,'2022-07-01','2022-11-01',55.50,5),
	 ('m7Hk77dySHBbxrKgro1Hjg==','game 3','uk',30,false,'2022-11-01',13.89,'2022-08-01','2022-12-01',NULL,18.84,'2022-10-01',13.89,1,NULL,NULL,'2022-12-01',NULL,NULL,13.89,1,'2022-07-01','2022-11-01',55.50,5),
	 ('MAkig8NeMsTs73r6K0uDpA==','game 3','uk',20,false,'2022-09-01',14.55,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,14.55,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',126.54,4),
	 ('MAkig8NeMsTs73r6K0uDpA==','game 3','uk',20,false,'2022-10-01',48.27,'2022-09-01','2022-11-01','2022-11-01',14.55,'2022-09-01',NULL,NULL,NULL,NULL,NULL,33.72,NULL,NULL,NULL,'2022-09-01','2022-12-01',126.54,4),
	 ('MAkig8NeMsTs73r6K0uDpA==','game 3','uk',20,false,'2022-11-01',45.72,'2022-10-01','2022-12-01','2022-12-01',48.27,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-2.55,NULL,NULL,'2022-09-01','2022-12-01',126.54,4),
	 ('MAkig8NeMsTs73r6K0uDpA==','game 3','uk',20,false,'2022-12-01',18.0,'2022-11-01','2023-01-01',NULL,45.72,'2022-11-01',18.0,1,NULL,NULL,'2023-01-01',NULL,-27.72,NULL,NULL,'2022-09-01','2022-12-01',126.54,4),
	 ('mcbWtEz8ADI9GXCi1lfaSA==','game 3','uk',17,true,'2022-08-01',16.05,NULL,'2022-09-01',NULL,NULL,'2022-07-01',16.05,1,16.05,1,'2022-09-01',NULL,NULL,NULL,NULL,'2022-08-01','2022-08-01',16.05,1),
	 ('mEqQ5vHXzsdrqHAQT3zs+g==','game 3','uk',25,true,'2022-11-01',12.54,NULL,'2022-12-01','2022-12-01',NULL,'2022-10-01',NULL,NULL,12.54,1,NULL,NULL,NULL,NULL,NULL,'2022-11-01','2022-12-01',27.42,2);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('mEqQ5vHXzsdrqHAQT3zs+g==','game 3','uk',25,true,'2022-12-01',14.88,'2022-11-01','2023-01-01',NULL,12.54,'2022-11-01',14.88,1,NULL,NULL,'2023-01-01',2.34,NULL,NULL,NULL,'2022-11-01','2022-12-01',27.42,2),
	 ('mEtO8F+CRPGmaJ8SHa7BbA==','game 3','uk',32,false,'2022-08-01',26.70,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,26.70,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-11-01',107.13,4),
	 ('mEtO8F+CRPGmaJ8SHa7BbA==','game 3','uk',32,false,'2022-09-01',27.12,'2022-08-01','2022-10-01','2022-10-01',26.70,'2022-08-01',NULL,NULL,NULL,NULL,NULL,0.42,NULL,NULL,NULL,'2022-08-01','2022-11-01',107.13,4),
	 ('mEtO8F+CRPGmaJ8SHa7BbA==','game 3','uk',32,false,'2022-10-01',31.17,'2022-09-01','2022-11-01','2022-11-01',27.12,'2022-09-01',NULL,NULL,NULL,NULL,NULL,4.05,NULL,NULL,NULL,'2022-08-01','2022-11-01',107.13,4),
	 ('mEtO8F+CRPGmaJ8SHa7BbA==','game 3','uk',32,false,'2022-11-01',22.14,'2022-10-01','2022-12-01',NULL,31.17,'2022-10-01',22.14,1,NULL,NULL,'2022-12-01',NULL,-9.03,NULL,NULL,'2022-08-01','2022-11-01',107.13,4),
	 ('MJrNeNCAIVBe/OSRGhrelw==','game 3','uk',21,true,'2022-10-01',69.78,NULL,'2022-11-01',NULL,NULL,'2022-09-01',69.78,1,69.78,1,'2022-11-01',NULL,NULL,NULL,NULL,'2022-10-01','2022-10-01',69.78,1),
	 ('MjzYQ3OFStqCMS3HzrxA2g==','game 3','ru',27,false,'2022-09-01',15.33,NULL,'2022-10-01','2022-11-01',NULL,'2022-08-01',15.33,1,15.33,1,'2022-10-01',NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',49.50,4),
	 ('MjzYQ3OFStqCMS3HzrxA2g==','game 3','ru',27,false,'2022-11-01',21.45,'2022-09-01','2022-12-01','2022-12-01',15.33,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,21.45,1,'2022-09-01','2022-12-01',49.50,4),
	 ('MjzYQ3OFStqCMS3HzrxA2g==','game 3','ru',27,false,'2022-12-01',12.72,'2022-11-01','2023-01-01',NULL,21.45,'2022-11-01',12.72,1,NULL,NULL,'2023-01-01',NULL,-8.73,NULL,NULL,'2022-09-01','2022-12-01',49.50,4),
	 ('mq7MyR1XHK5rM4mgtKjsgg==','game 3','uk',40,false,'2022-10-01',12.51,NULL,'2022-11-01',NULL,NULL,'2022-09-01',12.51,1,12.51,1,'2022-11-01',NULL,NULL,NULL,NULL,'2022-10-01','2022-10-01',12.51,1);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('MRcEXu/KG95hsIyJM/816A==','game 3','uk',32,false,'2022-05-01',37.98,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,37.98,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-11-01',186.93,7),
	 ('MRcEXu/KG95hsIyJM/816A==','game 3','uk',32,false,'2022-06-01',23.4,'2022-05-01','2022-07-01','2022-07-01',37.98,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-14.58,NULL,NULL,'2022-05-01','2022-11-01',186.93,7),
	 ('MRcEXu/KG95hsIyJM/816A==','game 3','uk',32,false,'2022-07-01',14.73,'2022-06-01','2022-08-01','2022-08-01',23.4,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-8.67,NULL,NULL,'2022-05-01','2022-11-01',186.93,7),
	 ('MRcEXu/KG95hsIyJM/816A==','game 3','uk',32,false,'2022-08-01',26.13,'2022-07-01','2022-09-01','2022-09-01',14.73,'2022-07-01',NULL,NULL,NULL,NULL,NULL,11.40,NULL,NULL,NULL,'2022-05-01','2022-11-01',186.93,7),
	 ('MRcEXu/KG95hsIyJM/816A==','game 3','uk',32,false,'2022-09-01',14.67,'2022-08-01','2022-10-01','2022-10-01',26.13,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-11.46,NULL,NULL,'2022-05-01','2022-11-01',186.93,7),
	 ('MRcEXu/KG95hsIyJM/816A==','game 3','uk',32,false,'2022-10-01',32.10,'2022-09-01','2022-11-01','2022-11-01',14.67,'2022-09-01',NULL,NULL,NULL,NULL,NULL,17.43,NULL,NULL,NULL,'2022-05-01','2022-11-01',186.93,7),
	 ('MRcEXu/KG95hsIyJM/816A==','game 3','uk',32,false,'2022-11-01',37.92,'2022-10-01','2022-12-01',NULL,32.10,'2022-10-01',37.92,1,NULL,NULL,'2022-12-01',5.82,NULL,NULL,NULL,'2022-05-01','2022-11-01',186.93,7),
	 ('mRT725ZK68AhE3Sk9xH5cw==','game 3','ru',29,false,'2022-10-01',43.68,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,43.68,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',111.24,3),
	 ('mRT725ZK68AhE3Sk9xH5cw==','game 3','ru',29,false,'2022-11-01',17.28,'2022-10-01','2022-12-01','2022-12-01',43.68,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-26.40,NULL,NULL,'2022-10-01','2022-12-01',111.24,3),
	 ('mRT725ZK68AhE3Sk9xH5cw==','game 3','ru',29,false,'2022-12-01',50.28,'2022-11-01','2023-01-01',NULL,17.28,'2022-11-01',50.28,1,NULL,NULL,'2023-01-01',33.00,NULL,NULL,NULL,'2022-10-01','2022-12-01',111.24,3);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('MSxDpyVU8A+9Wgmnb8b1IQ==','game 3','uk',14,false,'2022-08-01',68.43,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,68.43,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',224.85,5),
	 ('MSxDpyVU8A+9Wgmnb8b1IQ==','game 3','uk',14,false,'2022-09-01',27.54,'2022-08-01','2022-10-01','2022-10-01',68.43,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-40.89,NULL,NULL,'2022-08-01','2022-12-01',224.85,5),
	 ('MSxDpyVU8A+9Wgmnb8b1IQ==','game 3','uk',14,false,'2022-10-01',68.58,'2022-09-01','2022-11-01','2022-11-01',27.54,'2022-09-01',NULL,NULL,NULL,NULL,NULL,41.04,NULL,NULL,NULL,'2022-08-01','2022-12-01',224.85,5),
	 ('MSxDpyVU8A+9Wgmnb8b1IQ==','game 3','uk',14,false,'2022-11-01',28.08,'2022-10-01','2022-12-01','2022-12-01',68.58,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-40.50,NULL,NULL,'2022-08-01','2022-12-01',224.85,5),
	 ('MSxDpyVU8A+9Wgmnb8b1IQ==','game 3','uk',14,false,'2022-12-01',32.22,'2022-11-01','2023-01-01',NULL,28.08,'2022-11-01',32.22,1,NULL,NULL,'2023-01-01',4.14,NULL,NULL,NULL,'2022-08-01','2022-12-01',224.85,5),
	 ('mTha7D/MRe45dQaUAEKV3g==','game 3','uk',42,false,'2022-08-01',14.73,NULL,'2022-09-01',NULL,NULL,'2022-07-01',14.73,1,14.73,1,'2022-09-01',NULL,NULL,NULL,NULL,'2022-08-01','2022-08-01',14.73,1),
	 ('mXihLMwkG8RgO1jsFnJXnA==','game 3','uk',32,false,'2022-08-01',12.75,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,12.75,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-09-01',39.06,2),
	 ('mXihLMwkG8RgO1jsFnJXnA==','game 3','uk',32,false,'2022-09-01',26.31,'2022-08-01','2022-10-01',NULL,12.75,'2022-08-01',26.31,1,NULL,NULL,'2022-10-01',13.56,NULL,NULL,NULL,'2022-08-01','2022-09-01',39.06,2),
	 ('mY631USB1Y3/I1dHNhoEyA==','game 3','uk',22,false,'2022-11-01',15.3,NULL,'2022-12-01','2022-12-01',NULL,'2022-10-01',NULL,NULL,15.3,1,NULL,NULL,NULL,NULL,NULL,'2022-11-01','2022-12-01',51.66,2),
	 ('mY631USB1Y3/I1dHNhoEyA==','game 3','uk',22,false,'2022-12-01',36.36,'2022-11-01','2023-01-01',NULL,15.3,'2022-11-01',36.36,1,NULL,NULL,'2023-01-01',21.06,NULL,NULL,NULL,'2022-11-01','2022-12-01',51.66,2);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('mzGpnrpyuOB+qfwTJ0XliQ==','game 3','ru',16,false,'2022-10-01',77.70,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,77.70,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',146.01,3),
	 ('mzGpnrpyuOB+qfwTJ0XliQ==','game 3','ru',16,false,'2022-11-01',42.57,'2022-10-01','2022-12-01','2022-12-01',77.70,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-35.13,NULL,NULL,'2022-10-01','2022-12-01',146.01,3),
	 ('mzGpnrpyuOB+qfwTJ0XliQ==','game 3','ru',16,false,'2022-12-01',25.74,'2022-11-01','2023-01-01',NULL,42.57,'2022-11-01',25.74,1,NULL,NULL,'2023-01-01',NULL,-16.83,NULL,NULL,'2022-10-01','2022-12-01',146.01,3),
	 ('n8oSWohH4Vi8muIgqbRC+Q==','game 3','uk',14,false,'2022-12-01',26.7,NULL,'2023-01-01',NULL,NULL,'2022-11-01',26.7,1,26.7,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',26.7,1),
	 ('NBaV27MmzBu99zAeNFSjUA==','game 3','uk',26,false,'2022-11-01',12.6,NULL,'2022-12-01','2022-12-01',NULL,'2022-10-01',NULL,NULL,12.6,1,NULL,NULL,NULL,NULL,NULL,'2022-11-01','2022-12-01',25.98,2),
	 ('NBaV27MmzBu99zAeNFSjUA==','game 3','uk',26,false,'2022-12-01',13.38,'2022-11-01','2023-01-01',NULL,12.6,'2022-11-01',13.38,1,NULL,NULL,'2023-01-01',0.78,NULL,NULL,NULL,'2022-11-01','2022-12-01',25.98,2),
	 ('nfIwLLLuemHymdg1HYidrA==','game 3','uk',19,false,'2022-10-01',72.78,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,72.78,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',151.20,3),
	 ('nfIwLLLuemHymdg1HYidrA==','game 3','uk',19,false,'2022-11-01',64.50,'2022-10-01','2022-12-01','2022-12-01',72.78,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-8.28,NULL,NULL,'2022-10-01','2022-12-01',151.20,3),
	 ('nfIwLLLuemHymdg1HYidrA==','game 3','uk',19,false,'2022-12-01',13.92,'2022-11-01','2023-01-01',NULL,64.50,'2022-11-01',13.92,1,NULL,NULL,'2023-01-01',NULL,-50.58,NULL,NULL,'2022-10-01','2022-12-01',151.20,3),
	 ('ngOdQ8biXsraLxTHS862fw==','game 3','ru',25,false,'2022-07-01',13.92,NULL,'2022-08-01',NULL,NULL,'2022-06-01',13.92,1,13.92,1,'2022-08-01',NULL,NULL,NULL,NULL,'2022-07-01','2022-07-01',13.92,1);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('ni2+3lFt9yVqbt5Vtc8BMQ==','game 3','uk',18,false,'2022-07-01',17.76,NULL,'2022-08-01',NULL,NULL,'2022-06-01',17.76,1,17.76,1,'2022-08-01',NULL,NULL,NULL,NULL,'2022-07-01','2022-07-01',17.76,1),
	 ('njexPkl3G77JLZwwcq2UVA==','game 3','uk',28,false,'2022-11-01',28.08,NULL,'2022-12-01','2022-12-01',NULL,'2022-10-01',NULL,NULL,28.08,1,NULL,NULL,NULL,NULL,NULL,'2022-11-01','2022-12-01',46.11,2),
	 ('njexPkl3G77JLZwwcq2UVA==','game 3','uk',28,false,'2022-12-01',18.03,'2022-11-01','2023-01-01',NULL,28.08,'2022-11-01',18.03,1,NULL,NULL,'2023-01-01',NULL,-10.05,NULL,NULL,'2022-11-01','2022-12-01',46.11,2),
	 ('nklUUkirU5GYU5ZtNOgx8w==','game 3','ru',20,true,'2022-04-01',19.11,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,19.11,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-11-01',164.22,8),
	 ('nklUUkirU5GYU5ZtNOgx8w==','game 3','ru',20,true,'2022-05-01',40.62,'2022-04-01','2022-06-01','2022-08-01',19.11,'2022-04-01',40.62,1,NULL,NULL,'2022-06-01',21.51,NULL,NULL,NULL,'2022-04-01','2022-11-01',164.22,8),
	 ('nklUUkirU5GYU5ZtNOgx8w==','game 3','ru',20,true,'2022-08-01',42.84,'2022-05-01','2022-09-01','2022-10-01',40.62,'2022-07-01',42.84,1,NULL,NULL,'2022-09-01',NULL,NULL,42.84,1,'2022-04-01','2022-11-01',164.22,8),
	 ('nklUUkirU5GYU5ZtNOgx8w==','game 3','ru',20,true,'2022-10-01',30.57,'2022-08-01','2022-11-01','2022-11-01',42.84,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,30.57,1,'2022-04-01','2022-11-01',164.22,8),
	 ('nklUUkirU5GYU5ZtNOgx8w==','game 3','ru',20,true,'2022-11-01',31.08,'2022-10-01','2022-12-01',NULL,30.57,'2022-10-01',31.08,1,NULL,NULL,'2022-12-01',0.51,NULL,NULL,NULL,'2022-04-01','2022-11-01',164.22,8),
	 ('NMmQVq8bB84KydONJjvTfQ==','game 3','uk',18,true,'2022-03-01',15.33,NULL,'2022-04-01',NULL,NULL,'2022-02-01',15.33,1,15.33,1,'2022-04-01',NULL,NULL,NULL,NULL,'2022-03-01','2022-03-01',15.33,1),
	 ('NntDesROB4ANrudTCXEScA==','game 3','ru',37,false,'2022-07-01',39.12,NULL,'2022-08-01','2022-10-01',NULL,'2022-06-01',39.12,1,39.12,1,'2022-08-01',NULL,NULL,NULL,NULL,'2022-07-01','2022-11-01',114.54,5);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('NntDesROB4ANrudTCXEScA==','game 3','ru',37,false,'2022-10-01',47.79,'2022-07-01','2022-11-01','2022-11-01',39.12,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,47.79,1,'2022-07-01','2022-11-01',114.54,5),
	 ('NntDesROB4ANrudTCXEScA==','game 3','ru',37,false,'2022-11-01',27.63,'2022-10-01','2022-12-01',NULL,47.79,'2022-10-01',27.63,1,NULL,NULL,'2022-12-01',NULL,-20.16,NULL,NULL,'2022-07-01','2022-11-01',114.54,5),
	 ('nNZDz4XCOjUv0OfYF+AAGg==','game 3','uk',25,false,'2022-09-01',40.38,NULL,'2022-10-01','2022-11-01',NULL,'2022-08-01',40.38,1,40.38,1,'2022-10-01',NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',124.41,4),
	 ('nNZDz4XCOjUv0OfYF+AAGg==','game 3','uk',25,false,'2022-11-01',18.39,'2022-09-01','2022-12-01','2022-12-01',40.38,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,18.39,1,'2022-09-01','2022-12-01',124.41,4),
	 ('nNZDz4XCOjUv0OfYF+AAGg==','game 3','uk',25,false,'2022-12-01',65.64,'2022-11-01','2023-01-01',NULL,18.39,'2022-11-01',65.64,1,NULL,NULL,'2023-01-01',47.25,NULL,NULL,NULL,'2022-09-01','2022-12-01',124.41,4),
	 ('Np8MbaAllrt9d2F+g1ZvJQ==','game 3','uk',22,false,'2022-09-01',121.02,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,121.02,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',354.63,4),
	 ('Np8MbaAllrt9d2F+g1ZvJQ==','game 3','uk',22,false,'2022-10-01',53.82,'2022-09-01','2022-11-01','2022-11-01',121.02,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-67.20,NULL,NULL,'2022-09-01','2022-12-01',354.63,4),
	 ('Np8MbaAllrt9d2F+g1ZvJQ==','game 3','uk',22,false,'2022-11-01',71.10,'2022-10-01','2022-12-01','2022-12-01',53.82,'2022-10-01',NULL,NULL,NULL,NULL,NULL,17.28,NULL,NULL,NULL,'2022-09-01','2022-12-01',354.63,4),
	 ('Np8MbaAllrt9d2F+g1ZvJQ==','game 3','uk',22,false,'2022-12-01',108.69,'2022-11-01','2023-01-01',NULL,71.10,'2022-11-01',108.69,1,NULL,NULL,'2023-01-01',37.59,NULL,NULL,NULL,'2022-09-01','2022-12-01',354.63,4),
	 ('nPrRQwP3UZo2KBlM2mJ8fg==','game 3','uk',24,false,'2022-04-01',31.68,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,31.68,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-12-01',483.72,9);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('nPrRQwP3UZo2KBlM2mJ8fg==','game 3','uk',24,false,'2022-05-01',70.08,'2022-04-01','2022-06-01','2022-06-01',31.68,'2022-04-01',NULL,NULL,NULL,NULL,NULL,38.40,NULL,NULL,NULL,'2022-04-01','2022-12-01',483.72,9),
	 ('nPrRQwP3UZo2KBlM2mJ8fg==','game 3','uk',24,false,'2022-06-01',65.25,'2022-05-01','2022-07-01','2022-07-01',70.08,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-4.83,NULL,NULL,'2022-04-01','2022-12-01',483.72,9),
	 ('nPrRQwP3UZo2KBlM2mJ8fg==','game 3','uk',24,false,'2022-07-01',83.70,'2022-06-01','2022-08-01','2022-08-01',65.25,'2022-06-01',NULL,NULL,NULL,NULL,NULL,18.45,NULL,NULL,NULL,'2022-04-01','2022-12-01',483.72,9),
	 ('nPrRQwP3UZo2KBlM2mJ8fg==','game 3','uk',24,false,'2022-08-01',15.33,'2022-07-01','2022-09-01','2022-09-01',83.70,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-68.37,NULL,NULL,'2022-04-01','2022-12-01',483.72,9),
	 ('nPrRQwP3UZo2KBlM2mJ8fg==','game 3','uk',24,false,'2022-09-01',17.16,'2022-08-01','2022-10-01','2022-10-01',15.33,'2022-08-01',NULL,NULL,NULL,NULL,NULL,1.83,NULL,NULL,NULL,'2022-04-01','2022-12-01',483.72,9),
	 ('nPrRQwP3UZo2KBlM2mJ8fg==','game 3','uk',24,false,'2022-10-01',60.03,'2022-09-01','2022-11-01','2022-11-01',17.16,'2022-09-01',NULL,NULL,NULL,NULL,NULL,42.87,NULL,NULL,NULL,'2022-04-01','2022-12-01',483.72,9),
	 ('nPrRQwP3UZo2KBlM2mJ8fg==','game 3','uk',24,false,'2022-11-01',15.21,'2022-10-01','2022-12-01','2022-12-01',60.03,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-44.82,NULL,NULL,'2022-04-01','2022-12-01',483.72,9),
	 ('nPrRQwP3UZo2KBlM2mJ8fg==','game 3','uk',24,false,'2022-12-01',125.28,'2022-11-01','2023-01-01',NULL,15.21,'2022-11-01',125.28,1,NULL,NULL,'2023-01-01',110.07,NULL,NULL,NULL,'2022-04-01','2022-12-01',483.72,9),
	 ('nS8ODZHVyaod50PqOekmOw==','game 3','ru',44,false,'2022-10-01',12.6,NULL,'2022-11-01',NULL,NULL,'2022-09-01',12.6,1,12.6,1,'2022-11-01',NULL,NULL,NULL,NULL,'2022-10-01','2022-10-01',12.6,1),
	 ('o55dseByUOl9s5IQCz1kuQ==','game 3','uk',22,false,'2022-03-01',23.16,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,23.16,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-08-01',170.19,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('o55dseByUOl9s5IQCz1kuQ==','game 3','uk',22,false,'2022-04-01',86.88,'2022-03-01','2022-05-01','2022-05-01',23.16,'2022-03-01',NULL,NULL,NULL,NULL,NULL,63.72,NULL,NULL,NULL,'2022-03-01','2022-08-01',170.19,6),
	 ('o55dseByUOl9s5IQCz1kuQ==','game 3','uk',22,false,'2022-05-01',16.44,'2022-04-01','2022-06-01','2022-06-01',86.88,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-70.44,NULL,NULL,'2022-03-01','2022-08-01',170.19,6),
	 ('o55dseByUOl9s5IQCz1kuQ==','game 3','uk',22,false,'2022-06-01',13.26,'2022-05-01','2022-07-01','2022-07-01',16.44,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-3.18,NULL,NULL,'2022-03-01','2022-08-01',170.19,6),
	 ('o55dseByUOl9s5IQCz1kuQ==','game 3','uk',22,false,'2022-07-01',15.03,'2022-06-01','2022-08-01','2022-08-01',13.26,'2022-06-01',NULL,NULL,NULL,NULL,NULL,1.77,NULL,NULL,NULL,'2022-03-01','2022-08-01',170.19,6),
	 ('o55dseByUOl9s5IQCz1kuQ==','game 3','uk',22,false,'2022-08-01',15.42,'2022-07-01','2022-09-01',NULL,15.03,'2022-07-01',15.42,1,NULL,NULL,'2022-09-01',0.39,NULL,NULL,NULL,'2022-03-01','2022-08-01',170.19,6),
	 ('O6owe/pXDy1Bk5nfxuCZyw==','game 3','ru',20,false,'2022-08-01',39.30,NULL,'2022-09-01',NULL,NULL,'2022-07-01',39.30,1,39.30,1,'2022-09-01',NULL,NULL,NULL,NULL,'2022-08-01','2022-08-01',39.30,1),
	 ('OAAGTJfPU2ECPJT1KYm2ZQ==','game 3','uk',22,false,'2022-09-01',22.14,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,22.14,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',200.73,4),
	 ('OAAGTJfPU2ECPJT1KYm2ZQ==','game 3','uk',22,false,'2022-10-01',17.64,'2022-09-01','2022-11-01','2022-11-01',22.14,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-4.50,NULL,NULL,'2022-09-01','2022-12-01',200.73,4),
	 ('OAAGTJfPU2ECPJT1KYm2ZQ==','game 3','uk',22,false,'2022-11-01',42.15,'2022-10-01','2022-12-01','2022-12-01',17.64,'2022-10-01',NULL,NULL,NULL,NULL,NULL,24.51,NULL,NULL,NULL,'2022-09-01','2022-12-01',200.73,4),
	 ('OAAGTJfPU2ECPJT1KYm2ZQ==','game 3','uk',22,false,'2022-12-01',118.80,'2022-11-01','2023-01-01',NULL,42.15,'2022-11-01',118.80,1,NULL,NULL,'2023-01-01',76.65,NULL,NULL,NULL,'2022-09-01','2022-12-01',200.73,4);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('ojVPXYZw2oeGtcmG7LcLGA==','game 3','en',20,false,'2022-04-01',21.33,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,21.33,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-09-01',345.33,6),
	 ('ojVPXYZw2oeGtcmG7LcLGA==','game 3','en',20,false,'2022-05-01',75.90,'2022-04-01','2022-06-01','2022-06-01',21.33,'2022-04-01',NULL,NULL,NULL,NULL,NULL,54.57,NULL,NULL,NULL,'2022-04-01','2022-09-01',345.33,6),
	 ('ojVPXYZw2oeGtcmG7LcLGA==','game 3','en',20,false,'2022-06-01',98.37,'2022-05-01','2022-07-01','2022-07-01',75.90,'2022-05-01',NULL,NULL,NULL,NULL,NULL,22.47,NULL,NULL,NULL,'2022-04-01','2022-09-01',345.33,6),
	 ('ojVPXYZw2oeGtcmG7LcLGA==','game 3','en',20,false,'2022-07-01',56.04,'2022-06-01','2022-08-01','2022-08-01',98.37,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-42.33,NULL,NULL,'2022-04-01','2022-09-01',345.33,6),
	 ('ojVPXYZw2oeGtcmG7LcLGA==','game 3','en',20,false,'2022-08-01',58.02,'2022-07-01','2022-09-01','2022-09-01',56.04,'2022-07-01',NULL,NULL,NULL,NULL,NULL,1.98,NULL,NULL,NULL,'2022-04-01','2022-09-01',345.33,6),
	 ('ojVPXYZw2oeGtcmG7LcLGA==','game 3','en',20,false,'2022-09-01',35.67,'2022-08-01','2022-10-01',NULL,58.02,'2022-08-01',35.67,1,NULL,NULL,'2022-10-01',NULL,-22.35,NULL,NULL,'2022-04-01','2022-09-01',345.33,6),
	 ('oKLGTNuEKW70rLmudZaTGQ==','game 3','uk',18,false,'2022-12-01',32.25,NULL,'2023-01-01',NULL,NULL,'2022-11-01',32.25,1,32.25,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',32.25,1),
	 ('omF221BxDxXFh233yUEVeQ==','game 3','uk',27,false,'2022-12-01',22.8,NULL,'2023-01-01',NULL,NULL,'2022-11-01',22.8,1,22.8,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',22.8,1),
	 ('oQQmPjqm7DR+exPmp6xDhg==','game 3','uk',30,false,'2022-07-01',12.42,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,12.42,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',52.68,6),
	 ('oQQmPjqm7DR+exPmp6xDhg==','game 3','uk',30,false,'2022-08-01',13.2,'2022-07-01','2022-09-01','2022-11-01',12.42,'2022-07-01',13.2,1,NULL,NULL,'2022-09-01',0.78,NULL,NULL,NULL,'2022-07-01','2022-12-01',52.68,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('oQQmPjqm7DR+exPmp6xDhg==','game 3','uk',30,false,'2022-11-01',13.53,'2022-08-01','2022-12-01','2022-12-01',13.2,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,13.53,1,'2022-07-01','2022-12-01',52.68,6),
	 ('oQQmPjqm7DR+exPmp6xDhg==','game 3','uk',30,false,'2022-12-01',13.53,'2022-11-01','2023-01-01',NULL,13.53,'2022-11-01',13.53,1,NULL,NULL,'2023-01-01',NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',52.68,6),
	 ('orbgZNBGuhZZx63HTAbyIw==','game 3','uk',25,false,'2022-04-01',62.13,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,62.13,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-10-01',636.42,7),
	 ('orbgZNBGuhZZx63HTAbyIw==','game 3','uk',25,false,'2022-05-01',155.97,'2022-04-01','2022-06-01','2022-06-01',62.13,'2022-04-01',NULL,NULL,NULL,NULL,NULL,93.84,NULL,NULL,NULL,'2022-04-01','2022-10-01',636.42,7),
	 ('orbgZNBGuhZZx63HTAbyIw==','game 3','uk',25,false,'2022-06-01',117.48,'2022-05-01','2022-07-01','2022-07-01',155.97,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-38.49,NULL,NULL,'2022-04-01','2022-10-01',636.42,7),
	 ('orbgZNBGuhZZx63HTAbyIw==','game 3','uk',25,false,'2022-07-01',69.15,'2022-06-01','2022-08-01','2022-08-01',117.48,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-48.33,NULL,NULL,'2022-04-01','2022-10-01',636.42,7),
	 ('orbgZNBGuhZZx63HTAbyIw==','game 3','uk',25,false,'2022-08-01',141.48,'2022-07-01','2022-09-01','2022-09-01',69.15,'2022-07-01',NULL,NULL,NULL,NULL,NULL,72.33,NULL,NULL,NULL,'2022-04-01','2022-10-01',636.42,7),
	 ('orbgZNBGuhZZx63HTAbyIw==','game 3','uk',25,false,'2022-09-01',54.45,'2022-08-01','2022-10-01','2022-10-01',141.48,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-87.03,NULL,NULL,'2022-04-01','2022-10-01',636.42,7),
	 ('orbgZNBGuhZZx63HTAbyIw==','game 3','uk',25,false,'2022-10-01',35.76,'2022-09-01','2022-11-01',NULL,54.45,'2022-09-01',35.76,1,NULL,NULL,'2022-11-01',NULL,-18.69,NULL,NULL,'2022-04-01','2022-10-01',636.42,7),
	 ('ORSvkhCut21rsk0cVtJfJA==','game 3','uk',21,false,'2022-09-01',146.25,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,146.25,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',285.39,4);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('ORSvkhCut21rsk0cVtJfJA==','game 3','uk',21,false,'2022-10-01',47.61,'2022-09-01','2022-11-01','2022-11-01',146.25,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-98.64,NULL,NULL,'2022-09-01','2022-12-01',285.39,4),
	 ('ORSvkhCut21rsk0cVtJfJA==','game 3','uk',21,false,'2022-11-01',35.31,'2022-10-01','2022-12-01','2022-12-01',47.61,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-12.30,NULL,NULL,'2022-09-01','2022-12-01',285.39,4),
	 ('ORSvkhCut21rsk0cVtJfJA==','game 3','uk',21,false,'2022-12-01',56.22,'2022-11-01','2023-01-01',NULL,35.31,'2022-11-01',56.22,1,NULL,NULL,'2023-01-01',20.91,NULL,NULL,NULL,'2022-09-01','2022-12-01',285.39,4),
	 ('+osJakLn8jv4bzFmPieelw==','game 3','uk',30,false,'2022-08-01',13.29,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,13.29,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',122.04,5),
	 ('+osJakLn8jv4bzFmPieelw==','game 3','uk',30,false,'2022-09-01',43.92,'2022-08-01','2022-10-01','2022-10-01',13.29,'2022-08-01',NULL,NULL,NULL,NULL,NULL,30.63,NULL,NULL,NULL,'2022-08-01','2022-12-01',122.04,5),
	 ('+osJakLn8jv4bzFmPieelw==','game 3','uk',30,false,'2022-10-01',21.06,'2022-09-01','2022-11-01','2022-11-01',43.92,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-22.86,NULL,NULL,'2022-08-01','2022-12-01',122.04,5),
	 ('+osJakLn8jv4bzFmPieelw==','game 3','uk',30,false,'2022-11-01',12.45,'2022-10-01','2022-12-01','2022-12-01',21.06,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-8.61,NULL,NULL,'2022-08-01','2022-12-01',122.04,5),
	 ('+osJakLn8jv4bzFmPieelw==','game 3','uk',30,false,'2022-12-01',31.32,'2022-11-01','2023-01-01',NULL,12.45,'2022-11-01',31.32,1,NULL,NULL,'2023-01-01',18.87,NULL,NULL,NULL,'2022-08-01','2022-12-01',122.04,5),
	 ('OtAfKAtIU2D/ISKleQ64ug==','game 3','uk',38,false,'2022-07-01',14.55,NULL,'2022-08-01',NULL,NULL,'2022-06-01',14.55,1,14.55,1,'2022-08-01',NULL,NULL,NULL,NULL,'2022-07-01','2022-07-01',14.55,1),
	 ('OU1FxSli7e6szUGr2+7M9A==','game 3','uk',25,false,'2022-12-01',75.39,NULL,'2023-01-01',NULL,NULL,'2022-11-01',75.39,1,75.39,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',75.39,1);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('OwODWxXcsV4bBnhONiLkwg==','game 3','uk',25,false,'2022-04-01',14.37,NULL,'2022-05-01',NULL,NULL,'2022-03-01',14.37,1,14.37,1,'2022-05-01',NULL,NULL,NULL,NULL,'2022-04-01','2022-04-01',14.37,1),
	 ('Ox0UcaMHdCuTLe5/JQrJMQ==','game 3','ru',18,false,'2022-06-01',17.76,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,17.76,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-10-01',125.55,5),
	 ('Ox0UcaMHdCuTLe5/JQrJMQ==','game 3','ru',18,false,'2022-07-01',28.35,'2022-06-01','2022-08-01','2022-08-01',17.76,'2022-06-01',NULL,NULL,NULL,NULL,NULL,10.59,NULL,NULL,NULL,'2022-06-01','2022-10-01',125.55,5),
	 ('Ox0UcaMHdCuTLe5/JQrJMQ==','game 3','ru',18,false,'2022-08-01',36.54,'2022-07-01','2022-09-01','2022-10-01',28.35,'2022-07-01',36.54,1,NULL,NULL,'2022-09-01',8.19,NULL,NULL,NULL,'2022-06-01','2022-10-01',125.55,5),
	 ('Ox0UcaMHdCuTLe5/JQrJMQ==','game 3','ru',18,false,'2022-10-01',42.90,'2022-08-01','2022-11-01',NULL,36.54,'2022-09-01',42.90,1,NULL,NULL,'2022-11-01',NULL,NULL,42.90,1,'2022-06-01','2022-10-01',125.55,5),
	 ('OYDRFRAiT1uYAqbWXOwRfw==','game 3','en',24,false,'2022-12-01',82.14,NULL,'2023-01-01',NULL,NULL,'2022-11-01',82.14,1,82.14,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',82.14,1),
	 ('p0Ysy5XSVvKlZbKqzjyJgQ==','game 3','uk',25,false,'2022-07-01',22.02,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,22.02,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',134.91,6),
	 ('p0Ysy5XSVvKlZbKqzjyJgQ==','game 3','uk',25,false,'2022-08-01',14.85,'2022-07-01','2022-09-01','2022-10-01',22.02,'2022-07-01',14.85,1,NULL,NULL,'2022-09-01',NULL,-7.17,NULL,NULL,'2022-07-01','2022-12-01',134.91,6),
	 ('p0Ysy5XSVvKlZbKqzjyJgQ==','game 3','uk',25,false,'2022-10-01',39.69,'2022-08-01','2022-11-01','2022-12-01',14.85,'2022-09-01',39.69,1,NULL,NULL,'2022-11-01',NULL,NULL,39.69,1,'2022-07-01','2022-12-01',134.91,6),
	 ('p0Ysy5XSVvKlZbKqzjyJgQ==','game 3','uk',25,false,'2022-12-01',58.35,'2022-10-01','2023-01-01',NULL,39.69,'2022-11-01',58.35,1,NULL,NULL,'2023-01-01',NULL,NULL,58.35,1,'2022-07-01','2022-12-01',134.91,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('pA81NE5UM892xwiOsE375g==','game 3','uk',19,false,'2022-12-01',27.84,NULL,'2023-01-01',NULL,NULL,'2022-11-01',27.84,1,27.84,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',27.84,1),
	 ('pLOCMIX+imLIzoDehgdOPA==','game 3','uk',22,false,'2022-05-01',68.16,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,68.16,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-12-01',665.34,8),
	 ('pLOCMIX+imLIzoDehgdOPA==','game 3','uk',22,false,'2022-06-01',55.53,'2022-05-01','2022-07-01','2022-07-01',68.16,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-12.63,NULL,NULL,'2022-05-01','2022-12-01',665.34,8),
	 ('pLOCMIX+imLIzoDehgdOPA==','game 3','uk',22,false,'2022-07-01',151.44,'2022-06-01','2022-08-01','2022-08-01',55.53,'2022-06-01',NULL,NULL,NULL,NULL,NULL,95.91,NULL,NULL,NULL,'2022-05-01','2022-12-01',665.34,8),
	 ('pLOCMIX+imLIzoDehgdOPA==','game 3','uk',22,false,'2022-08-01',129.75,'2022-07-01','2022-09-01','2022-09-01',151.44,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-21.69,NULL,NULL,'2022-05-01','2022-12-01',665.34,8),
	 ('pLOCMIX+imLIzoDehgdOPA==','game 3','uk',22,false,'2022-09-01',109.89,'2022-08-01','2022-10-01','2022-10-01',129.75,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-19.86,NULL,NULL,'2022-05-01','2022-12-01',665.34,8),
	 ('pLOCMIX+imLIzoDehgdOPA==','game 3','uk',22,false,'2022-10-01',46.80,'2022-09-01','2022-11-01','2022-11-01',109.89,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-63.09,NULL,NULL,'2022-05-01','2022-12-01',665.34,8),
	 ('pLOCMIX+imLIzoDehgdOPA==','game 3','uk',22,false,'2022-11-01',61.92,'2022-10-01','2022-12-01','2022-12-01',46.80,'2022-10-01',NULL,NULL,NULL,NULL,NULL,15.12,NULL,NULL,NULL,'2022-05-01','2022-12-01',665.34,8),
	 ('pLOCMIX+imLIzoDehgdOPA==','game 3','uk',22,false,'2022-12-01',41.85,'2022-11-01','2023-01-01',NULL,61.92,'2022-11-01',41.85,1,NULL,NULL,'2023-01-01',NULL,-20.07,NULL,NULL,'2022-05-01','2022-12-01',665.34,8),
	 ('prNQwR2IPPsvGpFgOpcGaQ==','game 3','uk',14,false,'2022-03-01',15.66,NULL,'2022-04-01','2022-05-01',NULL,'2022-02-01',15.66,1,15.66,1,'2022-04-01',NULL,NULL,NULL,NULL,'2022-03-01','2022-10-01',212.94,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('prNQwR2IPPsvGpFgOpcGaQ==','game 3','uk',14,false,'2022-05-01',95.52,'2022-03-01','2022-06-01','2022-07-01',15.66,'2022-04-01',95.52,1,NULL,NULL,'2022-06-01',NULL,NULL,95.52,1,'2022-03-01','2022-10-01',212.94,8),
	 ('prNQwR2IPPsvGpFgOpcGaQ==','game 3','uk',14,false,'2022-07-01',54.30,'2022-05-01','2022-08-01','2022-10-01',95.52,'2022-06-01',54.30,1,NULL,NULL,'2022-08-01',NULL,NULL,54.30,1,'2022-03-01','2022-10-01',212.94,8),
	 ('prNQwR2IPPsvGpFgOpcGaQ==','game 3','uk',14,false,'2022-10-01',47.46,'2022-07-01','2022-11-01',NULL,54.30,'2022-09-01',47.46,1,NULL,NULL,'2022-11-01',NULL,NULL,47.46,1,'2022-03-01','2022-10-01',212.94,8),
	 ('psERjQAamFwr88Zadc4wcQ==','game 3','ru',22,false,'2022-07-01',13.08,NULL,'2022-08-01',NULL,NULL,'2022-06-01',13.08,1,13.08,1,'2022-08-01',NULL,NULL,NULL,NULL,'2022-07-01','2022-07-01',13.08,1),
	 ('PWvj9YoQTtX9FGLgG1CWJQ==','game 3','uk',16,false,'2022-08-01',18.69,NULL,'2022-09-01',NULL,NULL,'2022-07-01',18.69,1,18.69,1,'2022-09-01',NULL,NULL,NULL,NULL,'2022-08-01','2022-08-01',18.69,1),
	 ('PydH3c1l9bUvwz7hsiaBOg==','game 3','uk',17,false,'2022-08-01',32.55,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,32.55,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-09-01',87.72,2),
	 ('PydH3c1l9bUvwz7hsiaBOg==','game 3','uk',17,false,'2022-09-01',55.17,'2022-08-01','2022-10-01',NULL,32.55,'2022-08-01',55.17,1,NULL,NULL,'2022-10-01',22.62,NULL,NULL,NULL,'2022-08-01','2022-09-01',87.72,2),
	 ('pz7LUOs9i7xgncmHVxQvOw==','game 3','ru',24,false,'2022-03-01',36.51,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,36.51,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-08-01',274.56,6),
	 ('pz7LUOs9i7xgncmHVxQvOw==','game 3','ru',24,false,'2022-04-01',19.5,'2022-03-01','2022-05-01','2022-05-01',36.51,'2022-03-01',NULL,NULL,NULL,NULL,NULL,NULL,-17.01,NULL,NULL,'2022-03-01','2022-08-01',274.56,6),
	 ('pz7LUOs9i7xgncmHVxQvOw==','game 3','ru',24,false,'2022-05-01',39.6,'2022-04-01','2022-06-01','2022-06-01',19.5,'2022-04-01',NULL,NULL,NULL,NULL,NULL,20.1,NULL,NULL,NULL,'2022-03-01','2022-08-01',274.56,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('pz7LUOs9i7xgncmHVxQvOw==','game 3','ru',24,false,'2022-06-01',89.61,'2022-05-01','2022-07-01','2022-07-01',39.6,'2022-05-01',NULL,NULL,NULL,NULL,NULL,50.01,NULL,NULL,NULL,'2022-03-01','2022-08-01',274.56,6),
	 ('pz7LUOs9i7xgncmHVxQvOw==','game 3','ru',24,false,'2022-07-01',52.77,'2022-06-01','2022-08-01','2022-08-01',89.61,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-36.84,NULL,NULL,'2022-03-01','2022-08-01',274.56,6),
	 ('pz7LUOs9i7xgncmHVxQvOw==','game 3','ru',24,false,'2022-08-01',36.57,'2022-07-01','2022-09-01',NULL,52.77,'2022-07-01',36.57,1,NULL,NULL,'2022-09-01',NULL,-16.20,NULL,NULL,'2022-03-01','2022-08-01',274.56,6),
	 ('PzG6g7FMYUPp0RMvXhfesQ==','game 3','uk',34,false,'2022-09-01',36.45,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,36.45,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',85.32,4),
	 ('PzG6g7FMYUPp0RMvXhfesQ==','game 3','uk',34,false,'2022-10-01',19.23,'2022-09-01','2022-11-01','2022-11-01',36.45,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-17.22,NULL,NULL,'2022-09-01','2022-12-01',85.32,4),
	 ('PzG6g7FMYUPp0RMvXhfesQ==','game 3','uk',34,false,'2022-11-01',13.74,'2022-10-01','2022-12-01','2022-12-01',19.23,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-5.49,NULL,NULL,'2022-09-01','2022-12-01',85.32,4),
	 ('PzG6g7FMYUPp0RMvXhfesQ==','game 3','uk',34,false,'2022-12-01',15.9,'2022-11-01','2023-01-01',NULL,13.74,'2022-11-01',15.9,1,NULL,NULL,'2023-01-01',2.16,NULL,NULL,NULL,'2022-09-01','2022-12-01',85.32,4),
	 ('Q0GNgLhqfwwVwtvQhJt58A==','game 3','ru',24,false,'2022-11-01',21.24,NULL,'2022-12-01','2022-12-01',NULL,'2022-10-01',NULL,NULL,21.24,1,NULL,NULL,NULL,NULL,NULL,'2022-11-01','2022-12-01',77.82,2),
	 ('Q0GNgLhqfwwVwtvQhJt58A==','game 3','ru',24,false,'2022-12-01',56.58,'2022-11-01','2023-01-01',NULL,21.24,'2022-11-01',56.58,1,NULL,NULL,'2023-01-01',35.34,NULL,NULL,NULL,'2022-11-01','2022-12-01',77.82,2),
	 ('Q6BQCpZ1b6I15evvHZ6xYA==','game 3','uk',17,false,'2022-10-01',27.18,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,27.18,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',117.81,3);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('Q6BQCpZ1b6I15evvHZ6xYA==','game 3','uk',17,false,'2022-11-01',15.78,'2022-10-01','2022-12-01','2022-12-01',27.18,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-11.40,NULL,NULL,'2022-10-01','2022-12-01',117.81,3),
	 ('Q6BQCpZ1b6I15evvHZ6xYA==','game 3','uk',17,false,'2022-12-01',74.85,'2022-11-01','2023-01-01',NULL,15.78,'2022-11-01',74.85,1,NULL,NULL,'2023-01-01',59.07,NULL,NULL,NULL,'2022-10-01','2022-12-01',117.81,3),
	 ('q8UcdT1sZCl07AqhDVz5ZA==','game 3','uk',15,false,'2022-08-01',115.14,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,115.14,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',275.58,5),
	 ('q8UcdT1sZCl07AqhDVz5ZA==','game 3','uk',15,false,'2022-09-01',61.98,'2022-08-01','2022-10-01','2022-10-01',115.14,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-53.16,NULL,NULL,'2022-08-01','2022-12-01',275.58,5),
	 ('q8UcdT1sZCl07AqhDVz5ZA==','game 3','uk',15,false,'2022-10-01',33.0,'2022-09-01','2022-11-01','2022-12-01',61.98,'2022-09-01',33.0,1,NULL,NULL,'2022-11-01',NULL,-28.98,NULL,NULL,'2022-08-01','2022-12-01',275.58,5),
	 ('q8UcdT1sZCl07AqhDVz5ZA==','game 3','uk',15,false,'2022-12-01',65.46,'2022-10-01','2023-01-01',NULL,33.0,'2022-11-01',65.46,1,NULL,NULL,'2023-01-01',NULL,NULL,65.46,1,'2022-08-01','2022-12-01',275.58,5),
	 ('qEF/fPDQLJPXIx6RiSIP1A==','game 3','uk',20,false,'2022-05-01',21.84,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,21.84,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-12-01',334.05,8),
	 ('qEF/fPDQLJPXIx6RiSIP1A==','game 3','uk',20,false,'2022-06-01',32.04,'2022-05-01','2022-07-01','2022-07-01',21.84,'2022-05-01',NULL,NULL,NULL,NULL,NULL,10.20,NULL,NULL,NULL,'2022-05-01','2022-12-01',334.05,8),
	 ('qEF/fPDQLJPXIx6RiSIP1A==','game 3','uk',20,false,'2022-07-01',78.78,'2022-06-01','2022-08-01','2022-08-01',32.04,'2022-06-01',NULL,NULL,NULL,NULL,NULL,46.74,NULL,NULL,NULL,'2022-05-01','2022-12-01',334.05,8),
	 ('qEF/fPDQLJPXIx6RiSIP1A==','game 3','uk',20,false,'2022-08-01',48.51,'2022-07-01','2022-09-01','2022-09-01',78.78,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-30.27,NULL,NULL,'2022-05-01','2022-12-01',334.05,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('qEF/fPDQLJPXIx6RiSIP1A==','game 3','uk',20,false,'2022-09-01',77.04,'2022-08-01','2022-10-01','2022-10-01',48.51,'2022-08-01',NULL,NULL,NULL,NULL,NULL,28.53,NULL,NULL,NULL,'2022-05-01','2022-12-01',334.05,8),
	 ('qEF/fPDQLJPXIx6RiSIP1A==','game 3','uk',20,false,'2022-10-01',17.67,'2022-09-01','2022-11-01','2022-11-01',77.04,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-59.37,NULL,NULL,'2022-05-01','2022-12-01',334.05,8),
	 ('qEF/fPDQLJPXIx6RiSIP1A==','game 3','uk',20,false,'2022-11-01',29.85,'2022-10-01','2022-12-01','2022-12-01',17.67,'2022-10-01',NULL,NULL,NULL,NULL,NULL,12.18,NULL,NULL,NULL,'2022-05-01','2022-12-01',334.05,8),
	 ('qEF/fPDQLJPXIx6RiSIP1A==','game 3','uk',20,false,'2022-12-01',28.32,'2022-11-01','2023-01-01',NULL,29.85,'2022-11-01',28.32,1,NULL,NULL,'2023-01-01',NULL,-1.53,NULL,NULL,'2022-05-01','2022-12-01',334.05,8),
	 ('qmZRB16NnnCdNHWUcSyVDQ==','game 3','ru',37,false,'2022-06-01',52.83,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,52.83,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-12-01',268.71,7),
	 ('qmZRB16NnnCdNHWUcSyVDQ==','game 3','ru',37,false,'2022-07-01',86.91,'2022-06-01','2022-08-01','2022-08-01',52.83,'2022-06-01',NULL,NULL,NULL,NULL,NULL,34.08,NULL,NULL,NULL,'2022-06-01','2022-12-01',268.71,7),
	 ('qmZRB16NnnCdNHWUcSyVDQ==','game 3','ru',37,false,'2022-08-01',42.87,'2022-07-01','2022-09-01','2022-09-01',86.91,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-44.04,NULL,NULL,'2022-06-01','2022-12-01',268.71,7),
	 ('qmZRB16NnnCdNHWUcSyVDQ==','game 3','ru',37,false,'2022-09-01',16.98,'2022-08-01','2022-10-01','2022-11-01',42.87,'2022-08-01',16.98,1,NULL,NULL,'2022-10-01',NULL,-25.89,NULL,NULL,'2022-06-01','2022-12-01',268.71,7),
	 ('qmZRB16NnnCdNHWUcSyVDQ==','game 3','ru',37,false,'2022-11-01',27.18,'2022-09-01','2022-12-01','2022-12-01',16.98,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,27.18,1,'2022-06-01','2022-12-01',268.71,7),
	 ('qmZRB16NnnCdNHWUcSyVDQ==','game 3','ru',37,false,'2022-12-01',41.94,'2022-11-01','2023-01-01',NULL,27.18,'2022-11-01',41.94,1,NULL,NULL,'2023-01-01',14.76,NULL,NULL,NULL,'2022-06-01','2022-12-01',268.71,7);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('qn61TOwEB0RbKsB+v0D9tw==','game 3','ru',16,false,'2022-12-01',17.07,NULL,'2023-01-01',NULL,NULL,'2022-11-01',17.07,1,17.07,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',17.07,1),
	 ('QoHEss2e+b385deeX2p39Q==','game 3','ru',22,false,'2022-06-01',41.04,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,41.04,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-10-01',284.49,5),
	 ('QoHEss2e+b385deeX2p39Q==','game 3','ru',22,false,'2022-07-01',99.48,'2022-06-01','2022-08-01','2022-08-01',41.04,'2022-06-01',NULL,NULL,NULL,NULL,NULL,58.44,NULL,NULL,NULL,'2022-06-01','2022-10-01',284.49,5),
	 ('QoHEss2e+b385deeX2p39Q==','game 3','ru',22,false,'2022-08-01',71.43,'2022-07-01','2022-09-01','2022-09-01',99.48,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-28.05,NULL,NULL,'2022-06-01','2022-10-01',284.49,5),
	 ('QoHEss2e+b385deeX2p39Q==','game 3','ru',22,false,'2022-09-01',59.07,'2022-08-01','2022-10-01','2022-10-01',71.43,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-12.36,NULL,NULL,'2022-06-01','2022-10-01',284.49,5),
	 ('QoHEss2e+b385deeX2p39Q==','game 3','ru',22,false,'2022-10-01',13.47,'2022-09-01','2022-11-01',NULL,59.07,'2022-09-01',13.47,1,NULL,NULL,'2022-11-01',NULL,-45.60,NULL,NULL,'2022-06-01','2022-10-01',284.49,5),
	 ('qqYyR2vRI+7pgiuyTnVM+A==','game 3','ru',19,false,'2022-05-01',40.17,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,40.17,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-09-01',196.26,5),
	 ('qqYyR2vRI+7pgiuyTnVM+A==','game 3','ru',19,false,'2022-06-01',36.84,'2022-05-01','2022-07-01','2022-07-01',40.17,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-3.33,NULL,NULL,'2022-05-01','2022-09-01',196.26,5),
	 ('qqYyR2vRI+7pgiuyTnVM+A==','game 3','ru',19,false,'2022-07-01',27.03,'2022-06-01','2022-08-01','2022-08-01',36.84,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-9.81,NULL,NULL,'2022-05-01','2022-09-01',196.26,5),
	 ('qqYyR2vRI+7pgiuyTnVM+A==','game 3','ru',19,false,'2022-08-01',41.31,'2022-07-01','2022-09-01','2022-09-01',27.03,'2022-07-01',NULL,NULL,NULL,NULL,NULL,14.28,NULL,NULL,NULL,'2022-05-01','2022-09-01',196.26,5);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('qqYyR2vRI+7pgiuyTnVM+A==','game 3','ru',19,false,'2022-09-01',50.91,'2022-08-01','2022-10-01',NULL,41.31,'2022-08-01',50.91,1,NULL,NULL,'2022-10-01',9.60,NULL,NULL,NULL,'2022-05-01','2022-09-01',196.26,5),
	 ('q/Tz1C31XWaBUDrRn2ezDw==','game 3','uk',21,false,'2022-05-01',17.64,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,17.64,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-07-01',137.01,3),
	 ('q/Tz1C31XWaBUDrRn2ezDw==','game 3','uk',21,false,'2022-06-01',72.48,'2022-05-01','2022-07-01','2022-07-01',17.64,'2022-05-01',NULL,NULL,NULL,NULL,NULL,54.84,NULL,NULL,NULL,'2022-05-01','2022-07-01',137.01,3),
	 ('q/Tz1C31XWaBUDrRn2ezDw==','game 3','uk',21,false,'2022-07-01',46.89,'2022-06-01','2022-08-01',NULL,72.48,'2022-06-01',46.89,1,NULL,NULL,'2022-08-01',NULL,-25.59,NULL,NULL,'2022-05-01','2022-07-01',137.01,3),
	 ('q+yzIb2a/avnS9k89SDQVw==','game 3','uk',19,true,'2022-08-01',25.83,NULL,'2022-09-01','2022-10-01',NULL,'2022-07-01',25.83,1,25.83,1,'2022-09-01',NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',105.81,5),
	 ('q+yzIb2a/avnS9k89SDQVw==','game 3','uk',19,true,'2022-10-01',19.65,'2022-08-01','2022-11-01','2022-11-01',25.83,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,19.65,1,'2022-08-01','2022-12-01',105.81,5),
	 ('q+yzIb2a/avnS9k89SDQVw==','game 3','uk',19,true,'2022-11-01',26.52,'2022-10-01','2022-12-01','2022-12-01',19.65,'2022-10-01',NULL,NULL,NULL,NULL,NULL,6.87,NULL,NULL,NULL,'2022-08-01','2022-12-01',105.81,5),
	 ('q+yzIb2a/avnS9k89SDQVw==','game 3','uk',19,true,'2022-12-01',33.81,'2022-11-01','2023-01-01',NULL,26.52,'2022-11-01',33.81,1,NULL,NULL,'2023-01-01',7.29,NULL,NULL,NULL,'2022-08-01','2022-12-01',105.81,5),
	 ('QZBiEFECZAgVl5IkN9/cFw==','game 3','en',16,false,'2022-05-01',91.17,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,91.17,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-10-01',888.06,6),
	 ('QZBiEFECZAgVl5IkN9/cFw==','game 3','en',16,false,'2022-06-01',41.88,'2022-05-01','2022-07-01','2022-07-01',91.17,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-49.29,NULL,NULL,'2022-05-01','2022-10-01',888.06,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('QZBiEFECZAgVl5IkN9/cFw==','game 3','en',16,false,'2022-07-01',166.38,'2022-06-01','2022-08-01','2022-08-01',41.88,'2022-06-01',NULL,NULL,NULL,NULL,NULL,124.50,NULL,NULL,NULL,'2022-05-01','2022-10-01',888.06,6),
	 ('QZBiEFECZAgVl5IkN9/cFw==','game 3','en',16,false,'2022-08-01',205.05,'2022-07-01','2022-09-01','2022-09-01',166.38,'2022-07-01',NULL,NULL,NULL,NULL,NULL,38.67,NULL,NULL,NULL,'2022-05-01','2022-10-01',888.06,6),
	 ('QZBiEFECZAgVl5IkN9/cFw==','game 3','en',16,false,'2022-09-01',252.66,'2022-08-01','2022-10-01','2022-10-01',205.05,'2022-08-01',NULL,NULL,NULL,NULL,NULL,47.61,NULL,NULL,NULL,'2022-05-01','2022-10-01',888.06,6),
	 ('QZBiEFECZAgVl5IkN9/cFw==','game 3','en',16,false,'2022-10-01',130.92,'2022-09-01','2022-11-01',NULL,252.66,'2022-09-01',130.92,1,NULL,NULL,'2022-11-01',NULL,-121.74,NULL,NULL,'2022-05-01','2022-10-01',888.06,6),
	 ('R6aBG9TzvghZNNmGufy5NQ==','game 3','ru',33,false,'2022-08-01',12.36,NULL,'2022-09-01',NULL,NULL,'2022-07-01',12.36,1,12.36,1,'2022-09-01',NULL,NULL,NULL,NULL,'2022-08-01','2022-08-01',12.36,1),
	 ('r9AjQVS2nstu5lpVmDlihA==','game 3','ru',22,false,'2022-06-01',53.28,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,53.28,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-12-01',306.81,7),
	 ('r9AjQVS2nstu5lpVmDlihA==','game 3','ru',22,false,'2022-07-01',24.84,'2022-06-01','2022-08-01','2022-08-01',53.28,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-28.44,NULL,NULL,'2022-06-01','2022-12-01',306.81,7),
	 ('r9AjQVS2nstu5lpVmDlihA==','game 3','ru',22,false,'2022-08-01',29.52,'2022-07-01','2022-09-01','2022-10-01',24.84,'2022-07-01',29.52,1,NULL,NULL,'2022-09-01',4.68,NULL,NULL,NULL,'2022-06-01','2022-12-01',306.81,7),
	 ('r9AjQVS2nstu5lpVmDlihA==','game 3','ru',22,false,'2022-10-01',94.71,'2022-08-01','2022-11-01','2022-12-01',29.52,'2022-09-01',94.71,1,NULL,NULL,'2022-11-01',NULL,NULL,94.71,1,'2022-06-01','2022-12-01',306.81,7),
	 ('r9AjQVS2nstu5lpVmDlihA==','game 3','ru',22,false,'2022-12-01',104.46,'2022-10-01','2023-01-01',NULL,94.71,'2022-11-01',104.46,1,NULL,NULL,'2023-01-01',NULL,NULL,104.46,1,'2022-06-01','2022-12-01',306.81,7);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('Re0WtVSaiuBn90MFtMRCww==','game 3','uk',14,false,'2022-12-01',74.13,NULL,'2023-01-01',NULL,NULL,'2022-11-01',74.13,1,74.13,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',74.13,1),
	 ('RiIlY436bXNX8MIW9vUaAQ==','game 3','uk',18,true,'2022-08-01',25.29,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,25.29,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',176.64,5),
	 ('RiIlY436bXNX8MIW9vUaAQ==','game 3','uk',18,true,'2022-09-01',79.08,'2022-08-01','2022-10-01','2022-10-01',25.29,'2022-08-01',NULL,NULL,NULL,NULL,NULL,53.79,NULL,NULL,NULL,'2022-08-01','2022-12-01',176.64,5),
	 ('RiIlY436bXNX8MIW9vUaAQ==','game 3','uk',18,true,'2022-10-01',23.52,'2022-09-01','2022-11-01','2022-12-01',79.08,'2022-09-01',23.52,1,NULL,NULL,'2022-11-01',NULL,-55.56,NULL,NULL,'2022-08-01','2022-12-01',176.64,5),
	 ('RiIlY436bXNX8MIW9vUaAQ==','game 3','uk',18,true,'2022-12-01',48.75,'2022-10-01','2023-01-01',NULL,23.52,'2022-11-01',48.75,1,NULL,NULL,'2023-01-01',NULL,NULL,48.75,1,'2022-08-01','2022-12-01',176.64,5),
	 ('rJEGPACDdmHAmCCp5+QRRw==','game 3','uk',20,true,'2022-11-01',17.13,NULL,'2022-12-01','2022-12-01',NULL,'2022-10-01',NULL,NULL,17.13,1,NULL,NULL,NULL,NULL,NULL,'2022-11-01','2022-12-01',84.12,2),
	 ('rJEGPACDdmHAmCCp5+QRRw==','game 3','uk',20,true,'2022-12-01',66.99,'2022-11-01','2023-01-01',NULL,17.13,'2022-11-01',66.99,1,NULL,NULL,'2023-01-01',49.86,NULL,NULL,NULL,'2022-11-01','2022-12-01',84.12,2),
	 ('RoTHCVmIeMQXudXxn3ykNw==','game 3','uk',21,false,'2022-08-01',43.62,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,43.62,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-10-01',112.02,3),
	 ('RoTHCVmIeMQXudXxn3ykNw==','game 3','uk',21,false,'2022-09-01',35.55,'2022-08-01','2022-10-01','2022-10-01',43.62,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-8.07,NULL,NULL,'2022-08-01','2022-10-01',112.02,3),
	 ('RoTHCVmIeMQXudXxn3ykNw==','game 3','uk',21,false,'2022-10-01',32.85,'2022-09-01','2022-11-01',NULL,35.55,'2022-09-01',32.85,1,NULL,NULL,'2022-11-01',NULL,-2.70,NULL,NULL,'2022-08-01','2022-10-01',112.02,3);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('RQBsCvxlogTNUidSygqgcQ==','game 3','uk',28,false,'2022-05-01',12.18,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,12.18,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-11-01',201.60,7),
	 ('RQBsCvxlogTNUidSygqgcQ==','game 3','uk',28,false,'2022-06-01',17.07,'2022-05-01','2022-07-01','2022-07-01',12.18,'2022-05-01',NULL,NULL,NULL,NULL,NULL,4.89,NULL,NULL,NULL,'2022-05-01','2022-11-01',201.60,7),
	 ('RQBsCvxlogTNUidSygqgcQ==','game 3','uk',28,false,'2022-07-01',29.34,'2022-06-01','2022-08-01','2022-08-01',17.07,'2022-06-01',NULL,NULL,NULL,NULL,NULL,12.27,NULL,NULL,NULL,'2022-05-01','2022-11-01',201.60,7),
	 ('RQBsCvxlogTNUidSygqgcQ==','game 3','uk',28,false,'2022-08-01',55.92,'2022-07-01','2022-09-01','2022-09-01',29.34,'2022-07-01',NULL,NULL,NULL,NULL,NULL,26.58,NULL,NULL,NULL,'2022-05-01','2022-11-01',201.60,7),
	 ('RQBsCvxlogTNUidSygqgcQ==','game 3','uk',28,false,'2022-09-01',45.39,'2022-08-01','2022-10-01','2022-11-01',55.92,'2022-08-01',45.39,1,NULL,NULL,'2022-10-01',NULL,-10.53,NULL,NULL,'2022-05-01','2022-11-01',201.60,7),
	 ('RQBsCvxlogTNUidSygqgcQ==','game 3','uk',28,false,'2022-11-01',41.70,'2022-09-01','2022-12-01',NULL,45.39,'2022-10-01',41.70,1,NULL,NULL,'2022-12-01',NULL,NULL,41.70,1,'2022-05-01','2022-11-01',201.60,7),
	 ('RsmjZqhi61Kd7U5ihaXhDw==','game 3','uk',30,false,'2022-06-01',68.58,NULL,'2022-07-01','2022-09-01',NULL,'2022-05-01',68.58,1,68.58,1,'2022-07-01',NULL,NULL,NULL,NULL,'2022-06-01','2022-12-01',119.19,7),
	 ('RsmjZqhi61Kd7U5ihaXhDw==','game 3','uk',30,false,'2022-09-01',20.07,'2022-06-01','2022-10-01','2022-11-01',68.58,'2022-08-01',20.07,1,NULL,NULL,'2022-10-01',NULL,NULL,20.07,1,'2022-06-01','2022-12-01',119.19,7),
	 ('RsmjZqhi61Kd7U5ihaXhDw==','game 3','uk',30,false,'2022-11-01',17.94,'2022-09-01','2022-12-01','2022-12-01',20.07,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,17.94,1,'2022-06-01','2022-12-01',119.19,7),
	 ('RsmjZqhi61Kd7U5ihaXhDw==','game 3','uk',30,false,'2022-12-01',12.6,'2022-11-01','2023-01-01',NULL,17.94,'2022-11-01',12.6,1,NULL,NULL,'2023-01-01',NULL,-5.34,NULL,NULL,'2022-06-01','2022-12-01',119.19,7);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('RUjQVs2C+H0ejG0h7x1f5A==','game 3','uk',22,false,'2022-08-01',59.88,NULL,'2022-09-01',NULL,NULL,'2022-07-01',59.88,1,59.88,1,'2022-09-01',NULL,NULL,NULL,NULL,'2022-08-01','2022-08-01',59.88,1),
	 ('rw8yxS9+t5PvgINa7EhMvQ==','game 3','uk',18,true,'2022-06-01',49.92,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,49.92,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-12-01',331.29,7),
	 ('rw8yxS9+t5PvgINa7EhMvQ==','game 3','uk',18,true,'2022-07-01',72.45,'2022-06-01','2022-08-01','2022-08-01',49.92,'2022-06-01',NULL,NULL,NULL,NULL,NULL,22.53,NULL,NULL,NULL,'2022-06-01','2022-12-01',331.29,7),
	 ('rw8yxS9+t5PvgINa7EhMvQ==','game 3','uk',18,true,'2022-08-01',42.51,'2022-07-01','2022-09-01','2022-09-01',72.45,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-29.94,NULL,NULL,'2022-06-01','2022-12-01',331.29,7),
	 ('rw8yxS9+t5PvgINa7EhMvQ==','game 3','uk',18,true,'2022-09-01',103.62,'2022-08-01','2022-10-01','2022-12-01',42.51,'2022-08-01',103.62,1,NULL,NULL,'2022-10-01',61.11,NULL,NULL,NULL,'2022-06-01','2022-12-01',331.29,7),
	 ('rw8yxS9+t5PvgINa7EhMvQ==','game 3','uk',18,true,'2022-12-01',62.79,'2022-09-01','2023-01-01',NULL,103.62,'2022-11-01',62.79,1,NULL,NULL,'2023-01-01',NULL,NULL,62.79,1,'2022-06-01','2022-12-01',331.29,7),
	 ('RwtKwrRSrVpyAMRaDyhr8g==','game 3','uk',44,false,'2022-05-01',24.06,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,24.06,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-12-01',159.63,8),
	 ('RwtKwrRSrVpyAMRaDyhr8g==','game 3','uk',44,false,'2022-06-01',63.78,'2022-05-01','2022-07-01','2022-09-01',24.06,'2022-05-01',63.78,1,NULL,NULL,'2022-07-01',39.72,NULL,NULL,NULL,'2022-05-01','2022-12-01',159.63,8),
	 ('RwtKwrRSrVpyAMRaDyhr8g==','game 3','uk',44,false,'2022-09-01',15.21,'2022-06-01','2022-10-01','2022-10-01',63.78,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,15.21,1,'2022-05-01','2022-12-01',159.63,8),
	 ('RwtKwrRSrVpyAMRaDyhr8g==','game 3','uk',44,false,'2022-10-01',34.44,'2022-09-01','2022-11-01','2022-12-01',15.21,'2022-09-01',34.44,1,NULL,NULL,'2022-11-01',19.23,NULL,NULL,NULL,'2022-05-01','2022-12-01',159.63,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('RwtKwrRSrVpyAMRaDyhr8g==','game 3','uk',44,false,'2022-12-01',22.14,'2022-10-01','2023-01-01',NULL,34.44,'2022-11-01',22.14,1,NULL,NULL,'2023-01-01',NULL,NULL,22.14,1,'2022-05-01','2022-12-01',159.63,8),
	 ('S0TSw0AJ4KdmgXzAzX0p5Q==','game 3','uk',23,false,'2022-10-01',19.29,NULL,'2022-11-01','2022-12-01',NULL,'2022-09-01',19.29,1,19.29,1,'2022-11-01',NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',53.70,3),
	 ('S0TSw0AJ4KdmgXzAzX0p5Q==','game 3','uk',23,false,'2022-12-01',34.41,'2022-10-01','2023-01-01',NULL,19.29,'2022-11-01',34.41,1,NULL,NULL,'2023-01-01',NULL,NULL,34.41,1,'2022-10-01','2022-12-01',53.70,3),
	 ('s27V1tbCAysovKSY1XcdWQ==','game 3','uk',34,false,'2022-03-01',22.95,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,22.95,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-07-01',88.14,5),
	 ('s27V1tbCAysovKSY1XcdWQ==','game 3','uk',34,false,'2022-04-01',39.48,'2022-03-01','2022-05-01','2022-05-01',22.95,'2022-03-01',NULL,NULL,NULL,NULL,NULL,16.53,NULL,NULL,NULL,'2022-03-01','2022-07-01',88.14,5),
	 ('s27V1tbCAysovKSY1XcdWQ==','game 3','uk',34,false,'2022-05-01',12.15,'2022-04-01','2022-06-01','2022-07-01',39.48,'2022-04-01',12.15,1,NULL,NULL,'2022-06-01',NULL,-27.33,NULL,NULL,'2022-03-01','2022-07-01',88.14,5),
	 ('s27V1tbCAysovKSY1XcdWQ==','game 3','uk',34,false,'2022-07-01',13.56,'2022-05-01','2022-08-01',NULL,12.15,'2022-06-01',13.56,1,NULL,NULL,'2022-08-01',NULL,NULL,13.56,1,'2022-03-01','2022-07-01',88.14,5),
	 ('S+4OKFlwA3L8VcjOt8TurA==','game 3','uk',29,false,'2022-05-01',15.24,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,15.24,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-07-01',64.38,3),
	 ('S+4OKFlwA3L8VcjOt8TurA==','game 3','uk',29,false,'2022-06-01',29.16,'2022-05-01','2022-07-01','2022-07-01',15.24,'2022-05-01',NULL,NULL,NULL,NULL,NULL,13.92,NULL,NULL,NULL,'2022-05-01','2022-07-01',64.38,3),
	 ('S+4OKFlwA3L8VcjOt8TurA==','game 3','uk',29,false,'2022-07-01',19.98,'2022-06-01','2022-08-01',NULL,29.16,'2022-06-01',19.98,1,NULL,NULL,'2022-08-01',NULL,-9.18,NULL,NULL,'2022-05-01','2022-07-01',64.38,3);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('sCKPcG1GIuOo593nRuu1Cw==','game 3','uk',25,false,'2022-06-01',61.11,NULL,'2022-07-01','2022-11-01',NULL,'2022-05-01',61.11,1,61.11,1,'2022-07-01',NULL,NULL,NULL,NULL,'2022-06-01','2022-12-01',257.28,7),
	 ('sCKPcG1GIuOo593nRuu1Cw==','game 3','uk',25,false,'2022-11-01',60.93,'2022-06-01','2022-12-01','2022-12-01',61.11,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,60.93,1,'2022-06-01','2022-12-01',257.28,7),
	 ('sCKPcG1GIuOo593nRuu1Cw==','game 3','uk',25,false,'2022-12-01',135.24,'2022-11-01','2023-01-01',NULL,60.93,'2022-11-01',135.24,1,NULL,NULL,'2023-01-01',74.31,NULL,NULL,NULL,'2022-06-01','2022-12-01',257.28,7),
	 ('ShEJVi+TtuQlvdw2uetd/Q==','game 3','uk',22,false,'2022-04-01',131.97,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,131.97,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-06-01',191.97,3),
	 ('ShEJVi+TtuQlvdw2uetd/Q==','game 3','uk',22,false,'2022-05-01',27.87,'2022-04-01','2022-06-01','2022-06-01',131.97,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-104.10,NULL,NULL,'2022-04-01','2022-06-01',191.97,3),
	 ('ShEJVi+TtuQlvdw2uetd/Q==','game 3','uk',22,false,'2022-06-01',32.13,'2022-05-01','2022-07-01',NULL,27.87,'2022-05-01',32.13,1,NULL,NULL,'2022-07-01',4.26,NULL,NULL,NULL,'2022-04-01','2022-06-01',191.97,3),
	 ('sQqTFx1o31w2foAIr2LKNw==','game 3','uk',32,false,'2022-08-01',35.79,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,35.79,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',116.01,5),
	 ('sQqTFx1o31w2foAIr2LKNw==','game 3','uk',32,false,'2022-09-01',49.74,'2022-08-01','2022-10-01','2022-10-01',35.79,'2022-08-01',NULL,NULL,NULL,NULL,NULL,13.95,NULL,NULL,NULL,'2022-08-01','2022-12-01',116.01,5),
	 ('sQqTFx1o31w2foAIr2LKNw==','game 3','uk',32,false,'2022-10-01',16.86,'2022-09-01','2022-11-01','2022-12-01',49.74,'2022-09-01',16.86,1,NULL,NULL,'2022-11-01',NULL,-32.88,NULL,NULL,'2022-08-01','2022-12-01',116.01,5),
	 ('sQqTFx1o31w2foAIr2LKNw==','game 3','uk',32,false,'2022-12-01',13.62,'2022-10-01','2023-01-01',NULL,16.86,'2022-11-01',13.62,1,NULL,NULL,'2023-01-01',NULL,NULL,13.62,1,'2022-08-01','2022-12-01',116.01,5);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('sthXYk64G/Zkc+7xA3xUbw==','game 2','uk',21,false,'2022-10-01',47.46,NULL,'2022-11-01',NULL,NULL,'2022-09-01',47.46,1,47.46,1,'2022-11-01',NULL,NULL,NULL,NULL,'2022-10-01','2022-10-01',47.46,1),
	 ('SwiAKdzn0b+A4XegM5x0Hw==','game 3','uk',16,false,'2022-08-01',12.09,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,12.09,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',215.01,5),
	 ('SwiAKdzn0b+A4XegM5x0Hw==','game 3','uk',16,false,'2022-09-01',42.27,'2022-08-01','2022-10-01','2022-10-01',12.09,'2022-08-01',NULL,NULL,NULL,NULL,NULL,30.18,NULL,NULL,NULL,'2022-08-01','2022-12-01',215.01,5),
	 ('SwiAKdzn0b+A4XegM5x0Hw==','game 3','uk',16,false,'2022-10-01',42.03,'2022-09-01','2022-11-01','2022-11-01',42.27,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-0.24,NULL,NULL,'2022-08-01','2022-12-01',215.01,5),
	 ('SwiAKdzn0b+A4XegM5x0Hw==','game 3','uk',16,false,'2022-11-01',17.16,'2022-10-01','2022-12-01','2022-12-01',42.03,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-24.87,NULL,NULL,'2022-08-01','2022-12-01',215.01,5),
	 ('SwiAKdzn0b+A4XegM5x0Hw==','game 3','uk',16,false,'2022-12-01',101.46,'2022-11-01','2023-01-01',NULL,17.16,'2022-11-01',101.46,1,NULL,NULL,'2023-01-01',84.30,NULL,NULL,NULL,'2022-08-01','2022-12-01',215.01,5),
	 ('Sx/MqN31Cxf6tOSLIiDtLg==','game 2','uk',19,true,'2022-07-01',26.79,NULL,'2022-08-01',NULL,NULL,'2022-06-01',26.79,1,26.79,1,'2022-08-01',NULL,NULL,NULL,NULL,'2022-07-01','2022-07-01',26.79,1),
	 ('SyWxmJ+Ha8K2C9UJt8blVA==','game 3','ru',25,false,'2022-03-01',55.62,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,55.62,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-11-01',232.74,9),
	 ('SyWxmJ+Ha8K2C9UJt8blVA==','game 3','ru',25,false,'2022-04-01',16.8,'2022-03-01','2022-05-01','2022-06-01',55.62,'2022-03-01',16.8,1,NULL,NULL,'2022-05-01',NULL,-38.82,NULL,NULL,'2022-03-01','2022-11-01',232.74,9),
	 ('SyWxmJ+Ha8K2C9UJt8blVA==','game 3','ru',25,false,'2022-06-01',63.45,'2022-04-01','2022-07-01','2022-09-01',16.8,'2022-05-01',63.45,1,NULL,NULL,'2022-07-01',NULL,NULL,63.45,1,'2022-03-01','2022-11-01',232.74,9);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('SyWxmJ+Ha8K2C9UJt8blVA==','game 3','ru',25,false,'2022-09-01',53.01,'2022-06-01','2022-10-01','2022-10-01',63.45,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,53.01,1,'2022-03-01','2022-11-01',232.74,9),
	 ('SyWxmJ+Ha8K2C9UJt8blVA==','game 3','ru',25,false,'2022-10-01',29.67,'2022-09-01','2022-11-01','2022-11-01',53.01,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-23.34,NULL,NULL,'2022-03-01','2022-11-01',232.74,9),
	 ('SyWxmJ+Ha8K2C9UJt8blVA==','game 3','ru',25,false,'2022-11-01',14.19,'2022-10-01','2022-12-01',NULL,29.67,'2022-10-01',14.19,1,NULL,NULL,'2022-12-01',NULL,-15.48,NULL,NULL,'2022-03-01','2022-11-01',232.74,9),
	 ('TamEW7rhOwxDSDgAWZHDnQ==','game 3','uk',23,false,'2022-10-01',12.0,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,12.0,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',77.28,3),
	 ('TamEW7rhOwxDSDgAWZHDnQ==','game 3','uk',23,false,'2022-11-01',43.68,'2022-10-01','2022-12-01','2022-12-01',12.0,'2022-10-01',NULL,NULL,NULL,NULL,NULL,31.68,NULL,NULL,NULL,'2022-10-01','2022-12-01',77.28,3),
	 ('TamEW7rhOwxDSDgAWZHDnQ==','game 3','uk',23,false,'2022-12-01',21.6,'2022-11-01','2023-01-01',NULL,43.68,'2022-11-01',21.6,1,NULL,NULL,'2023-01-01',NULL,-22.08,NULL,NULL,'2022-10-01','2022-12-01',77.28,3),
	 ('tBFTAZra3r5TkHhDubnYyg==','game 3','uk',19,false,'2022-10-01',91.86,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,91.86,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',148.68,3),
	 ('tBFTAZra3r5TkHhDubnYyg==','game 3','uk',19,false,'2022-11-01',39.99,'2022-10-01','2022-12-01','2022-12-01',91.86,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-51.87,NULL,NULL,'2022-10-01','2022-12-01',148.68,3),
	 ('tBFTAZra3r5TkHhDubnYyg==','game 3','uk',19,false,'2022-12-01',16.83,'2022-11-01','2023-01-01',NULL,39.99,'2022-11-01',16.83,1,NULL,NULL,'2023-01-01',NULL,-23.16,NULL,NULL,'2022-10-01','2022-12-01',148.68,3),
	 ('to3TWHIKMGoINAlfTdWn+w==','game 3','uk',28,false,'2022-06-01',35.34,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,35.34,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-08-01',71.13,3);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('to3TWHIKMGoINAlfTdWn+w==','game 3','uk',28,false,'2022-07-01',15.87,'2022-06-01','2022-08-01','2022-08-01',35.34,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-19.47,NULL,NULL,'2022-06-01','2022-08-01',71.13,3),
	 ('to3TWHIKMGoINAlfTdWn+w==','game 3','uk',28,false,'2022-08-01',19.92,'2022-07-01','2022-09-01',NULL,15.87,'2022-07-01',19.92,1,NULL,NULL,'2022-09-01',4.05,NULL,NULL,NULL,'2022-06-01','2022-08-01',71.13,3),
	 ('TQKB6Cvy+PDZswNNa6Y8Yw==','game 1','uk',20,false,'2022-12-01',13.14,NULL,'2023-01-01',NULL,NULL,'2022-11-01',13.14,1,13.14,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',13.14,1),
	 ('T+RA0/fgzbUBLF89D4AEDA==','game 3','ru',23,false,'2022-03-01',16.11,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,16.11,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-09-01',177.33,7),
	 ('T+RA0/fgzbUBLF89D4AEDA==','game 3','ru',23,false,'2022-04-01',45.48,'2022-03-01','2022-05-01','2022-06-01',16.11,'2022-03-01',45.48,1,NULL,NULL,'2022-05-01',29.37,NULL,NULL,NULL,'2022-03-01','2022-09-01',177.33,7),
	 ('T+RA0/fgzbUBLF89D4AEDA==','game 3','ru',23,false,'2022-06-01',31.44,'2022-04-01','2022-07-01','2022-07-01',45.48,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,31.44,1,'2022-03-01','2022-09-01',177.33,7),
	 ('T+RA0/fgzbUBLF89D4AEDA==','game 3','ru',23,false,'2022-07-01',65.79,'2022-06-01','2022-08-01','2022-09-01',31.44,'2022-06-01',65.79,1,NULL,NULL,'2022-08-01',34.35,NULL,NULL,NULL,'2022-03-01','2022-09-01',177.33,7),
	 ('T+RA0/fgzbUBLF89D4AEDA==','game 3','ru',23,false,'2022-09-01',18.51,'2022-07-01','2022-10-01',NULL,65.79,'2022-08-01',18.51,1,NULL,NULL,'2022-10-01',NULL,NULL,18.51,1,'2022-03-01','2022-09-01',177.33,7),
	 ('tUlbh1G7KYRxmBaQk4RPIw==','game 3','uk',34,false,'2022-08-01',12.18,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,12.18,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-09-01',47.61,2),
	 ('tUlbh1G7KYRxmBaQk4RPIw==','game 3','uk',34,false,'2022-09-01',35.43,'2022-08-01','2022-10-01',NULL,12.18,'2022-08-01',35.43,1,NULL,NULL,'2022-10-01',23.25,NULL,NULL,NULL,'2022-08-01','2022-09-01',47.61,2);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('TVMqvnxKnEuD9k1v8+cI1g==','game 3','uk',28,false,'2022-11-01',17.04,NULL,'2022-12-01',NULL,NULL,'2022-10-01',17.04,1,17.04,1,'2022-12-01',NULL,NULL,NULL,NULL,'2022-11-01','2022-11-01',17.04,1),
	 ('TWDA+aUZ8OPMHOtz5cPPXA==','game 3','ru',20,false,'2022-04-01',62.58,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,62.58,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-11-01',132.45,8),
	 ('TWDA+aUZ8OPMHOtz5cPPXA==','game 3','ru',20,false,'2022-05-01',27.42,'2022-04-01','2022-06-01','2022-06-01',62.58,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-35.16,NULL,NULL,'2022-04-01','2022-11-01',132.45,8),
	 ('TWDA+aUZ8OPMHOtz5cPPXA==','game 3','ru',20,false,'2022-06-01',14.07,'2022-05-01','2022-07-01','2022-10-01',27.42,'2022-05-01',14.07,1,NULL,NULL,'2022-07-01',NULL,-13.35,NULL,NULL,'2022-04-01','2022-11-01',132.45,8),
	 ('TWDA+aUZ8OPMHOtz5cPPXA==','game 3','ru',20,false,'2022-10-01',13.92,'2022-06-01','2022-11-01','2022-11-01',14.07,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,13.92,1,'2022-04-01','2022-11-01',132.45,8),
	 ('TWDA+aUZ8OPMHOtz5cPPXA==','game 3','ru',20,false,'2022-11-01',14.46,'2022-10-01','2022-12-01',NULL,13.92,'2022-10-01',14.46,1,NULL,NULL,'2022-12-01',0.54,NULL,NULL,NULL,'2022-04-01','2022-11-01',132.45,8),
	 ('UdsILd3VPsla6C2r+wytbA==','game 3','uk',31,false,'2022-11-01',58.17,NULL,'2022-12-01','2022-12-01',NULL,'2022-10-01',NULL,NULL,58.17,1,NULL,NULL,NULL,NULL,NULL,'2022-11-01','2022-12-01',89.31,2),
	 ('UdsILd3VPsla6C2r+wytbA==','game 3','uk',31,false,'2022-12-01',31.14,'2022-11-01','2023-01-01',NULL,58.17,'2022-11-01',31.14,1,NULL,NULL,'2023-01-01',NULL,-27.03,NULL,NULL,'2022-11-01','2022-12-01',89.31,2),
	 ('Uen3Ap0lnrgWVWJtFCSo7g==','game 3','ru',17,false,'2022-03-01',20.79,NULL,'2022-04-01','2022-05-01',NULL,'2022-02-01',20.79,1,20.79,1,'2022-04-01',NULL,NULL,NULL,NULL,'2022-03-01','2022-10-01',199.95,8),
	 ('Uen3Ap0lnrgWVWJtFCSo7g==','game 3','ru',17,false,'2022-05-01',47.88,'2022-03-01','2022-06-01','2022-06-01',20.79,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,47.88,1,'2022-03-01','2022-10-01',199.95,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('Uen3Ap0lnrgWVWJtFCSo7g==','game 3','ru',17,false,'2022-06-01',55.23,'2022-05-01','2022-07-01','2022-07-01',47.88,'2022-05-01',NULL,NULL,NULL,NULL,NULL,7.35,NULL,NULL,NULL,'2022-03-01','2022-10-01',199.95,8),
	 ('Uen3Ap0lnrgWVWJtFCSo7g==','game 3','ru',17,false,'2022-07-01',41.01,'2022-06-01','2022-08-01','2022-09-01',55.23,'2022-06-01',41.01,1,NULL,NULL,'2022-08-01',NULL,-14.22,NULL,NULL,'2022-03-01','2022-10-01',199.95,8),
	 ('Uen3Ap0lnrgWVWJtFCSo7g==','game 3','ru',17,false,'2022-09-01',20.19,'2022-07-01','2022-10-01','2022-10-01',41.01,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,20.19,1,'2022-03-01','2022-10-01',199.95,8),
	 ('Uen3Ap0lnrgWVWJtFCSo7g==','game 3','ru',17,false,'2022-10-01',14.85,'2022-09-01','2022-11-01',NULL,20.19,'2022-09-01',14.85,1,NULL,NULL,'2022-11-01',NULL,-5.34,NULL,NULL,'2022-03-01','2022-10-01',199.95,8),
	 ('UFVjte0RzYKTngAiVvjqPQ==','game 3','uk',17,false,'2022-08-01',13.14,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,13.14,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',110.70,5),
	 ('UFVjte0RzYKTngAiVvjqPQ==','game 3','uk',17,false,'2022-09-01',19.41,'2022-08-01','2022-10-01','2022-10-01',13.14,'2022-08-01',NULL,NULL,NULL,NULL,NULL,6.27,NULL,NULL,NULL,'2022-08-01','2022-12-01',110.70,5),
	 ('UFVjte0RzYKTngAiVvjqPQ==','game 3','uk',17,false,'2022-10-01',22.65,'2022-09-01','2022-11-01','2022-11-01',19.41,'2022-09-01',NULL,NULL,NULL,NULL,NULL,3.24,NULL,NULL,NULL,'2022-08-01','2022-12-01',110.70,5),
	 ('UFVjte0RzYKTngAiVvjqPQ==','game 3','uk',17,false,'2022-11-01',27.42,'2022-10-01','2022-12-01','2022-12-01',22.65,'2022-10-01',NULL,NULL,NULL,NULL,NULL,4.77,NULL,NULL,NULL,'2022-08-01','2022-12-01',110.70,5),
	 ('UFVjte0RzYKTngAiVvjqPQ==','game 3','uk',17,false,'2022-12-01',28.08,'2022-11-01','2023-01-01',NULL,27.42,'2022-11-01',28.08,1,NULL,NULL,'2023-01-01',0.66,NULL,NULL,NULL,'2022-08-01','2022-12-01',110.70,5),
	 ('UIYPIs8zzm4uX6+FZvTqNw==','game 3','ru',19,false,'2022-10-01',14.4,NULL,'2022-11-01',NULL,NULL,'2022-09-01',14.4,1,14.4,1,'2022-11-01',NULL,NULL,NULL,NULL,'2022-10-01','2022-10-01',14.4,1);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('UNcp1RmIObUiGNqLDHjNVw==','game 3','uk',16,false,'2022-05-01',28.35,NULL,'2022-06-01','2022-08-01',NULL,'2022-04-01',28.35,1,28.35,1,'2022-06-01',NULL,NULL,NULL,NULL,'2022-05-01','2022-12-01',231.54,8),
	 ('UNcp1RmIObUiGNqLDHjNVw==','game 3','uk',16,false,'2022-08-01',38.19,'2022-05-01','2022-09-01','2022-09-01',28.35,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,38.19,1,'2022-05-01','2022-12-01',231.54,8),
	 ('UNcp1RmIObUiGNqLDHjNVw==','game 3','uk',16,false,'2022-09-01',69.84,'2022-08-01','2022-10-01','2022-10-01',38.19,'2022-08-01',NULL,NULL,NULL,NULL,NULL,31.65,NULL,NULL,NULL,'2022-05-01','2022-12-01',231.54,8),
	 ('UNcp1RmIObUiGNqLDHjNVw==','game 3','uk',16,false,'2022-10-01',38.1,'2022-09-01','2022-11-01','2022-12-01',69.84,'2022-09-01',38.1,1,NULL,NULL,'2022-11-01',NULL,-31.74,NULL,NULL,'2022-05-01','2022-12-01',231.54,8),
	 ('UNcp1RmIObUiGNqLDHjNVw==','game 3','uk',16,false,'2022-12-01',57.06,'2022-10-01','2023-01-01',NULL,38.1,'2022-11-01',57.06,1,NULL,NULL,'2023-01-01',NULL,NULL,57.06,1,'2022-05-01','2022-12-01',231.54,8),
	 ('unoAVprNoepzjDQwQzWj6A==','game 3','uk',15,false,'2022-10-01',36.75,NULL,'2022-11-01','2022-12-01',NULL,'2022-09-01',36.75,1,36.75,1,'2022-11-01',NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',92.34,3),
	 ('unoAVprNoepzjDQwQzWj6A==','game 3','uk',15,false,'2022-12-01',55.59,'2022-10-01','2023-01-01',NULL,36.75,'2022-11-01',55.59,1,NULL,NULL,'2023-01-01',NULL,NULL,55.59,1,'2022-10-01','2022-12-01',92.34,3),
	 ('URpBYMANMt6h5bDmQtNfwg==','game 3','uk',17,false,'2022-11-01',50.82,NULL,'2022-12-01','2022-12-01',NULL,'2022-10-01',NULL,NULL,50.82,1,NULL,NULL,NULL,NULL,NULL,'2022-11-01','2022-12-01',224.49,2),
	 ('URpBYMANMt6h5bDmQtNfwg==','game 3','uk',17,false,'2022-12-01',173.67,'2022-11-01','2023-01-01',NULL,50.82,'2022-11-01',173.67,1,NULL,NULL,'2023-01-01',122.85,NULL,NULL,NULL,'2022-11-01','2022-12-01',224.49,2),
	 ('urYfKANRgMuaQO9lQnBgnQ==','game 3','uk',31,false,'2022-05-01',12.66,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,12.66,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-07-01',48.27,3);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('urYfKANRgMuaQO9lQnBgnQ==','game 3','uk',31,false,'2022-06-01',13.26,'2022-05-01','2022-07-01','2022-07-01',12.66,'2022-05-01',NULL,NULL,NULL,NULL,NULL,0.60,NULL,NULL,NULL,'2022-05-01','2022-07-01',48.27,3),
	 ('urYfKANRgMuaQO9lQnBgnQ==','game 3','uk',31,false,'2022-07-01',22.35,'2022-06-01','2022-08-01',NULL,13.26,'2022-06-01',22.35,1,NULL,NULL,'2022-08-01',9.09,NULL,NULL,NULL,'2022-05-01','2022-07-01',48.27,3),
	 ('+uszcWROLhovU7doCmFOiQ==','game 2','uk',18,false,'2022-08-01',22.65,NULL,'2022-09-01','2022-10-01',NULL,'2022-07-01',22.65,1,22.65,1,'2022-09-01',NULL,NULL,NULL,NULL,'2022-08-01','2022-10-01',59.22,3),
	 ('+uszcWROLhovU7doCmFOiQ==','game 2','uk',18,false,'2022-10-01',36.57,'2022-08-01','2022-11-01',NULL,22.65,'2022-09-01',36.57,1,NULL,NULL,'2022-11-01',NULL,NULL,36.57,1,'2022-08-01','2022-10-01',59.22,3),
	 ('UuQtA3rK0dpF7TttUoIAyg==','game 3','uk',19,false,'2022-10-01',21.81,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,21.81,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-11-01',80.97,2),
	 ('UuQtA3rK0dpF7TttUoIAyg==','game 3','uk',19,false,'2022-11-01',59.16,'2022-10-01','2022-12-01',NULL,21.81,'2022-10-01',59.16,1,NULL,NULL,'2022-12-01',37.35,NULL,NULL,NULL,'2022-10-01','2022-11-01',80.97,2),
	 ('ux4Q9iTbOyaU1c/0SKvF7w==','game 3','uk',26,false,'2022-10-01',12.03,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,12.03,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',137.43,3),
	 ('ux4Q9iTbOyaU1c/0SKvF7w==','game 3','uk',26,false,'2022-11-01',96.42,'2022-10-01','2022-12-01','2022-12-01',12.03,'2022-10-01',NULL,NULL,NULL,NULL,NULL,84.39,NULL,NULL,NULL,'2022-10-01','2022-12-01',137.43,3),
	 ('ux4Q9iTbOyaU1c/0SKvF7w==','game 3','uk',26,false,'2022-12-01',28.98,'2022-11-01','2023-01-01',NULL,96.42,'2022-11-01',28.98,1,NULL,NULL,'2023-01-01',NULL,-67.44,NULL,NULL,'2022-10-01','2022-12-01',137.43,3),
	 ('UYHkNfMIVuVaH82KijZH3Q==','game 3','uk',19,false,'2022-12-01',57.06,NULL,'2023-01-01',NULL,NULL,'2022-11-01',57.06,1,57.06,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',57.06,1);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('V1hFT6jms7MK4yi6EFdt6A==','game 3','uk',18,true,'2022-09-01',32.10,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,32.10,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',113.79,4),
	 ('V1hFT6jms7MK4yi6EFdt6A==','game 3','uk',18,true,'2022-10-01',33.09,'2022-09-01','2022-11-01','2022-11-01',32.10,'2022-09-01',NULL,NULL,NULL,NULL,NULL,0.99,NULL,NULL,NULL,'2022-09-01','2022-12-01',113.79,4),
	 ('V1hFT6jms7MK4yi6EFdt6A==','game 3','uk',18,true,'2022-11-01',29.70,'2022-10-01','2022-12-01','2022-12-01',33.09,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-3.39,NULL,NULL,'2022-09-01','2022-12-01',113.79,4),
	 ('V1hFT6jms7MK4yi6EFdt6A==','game 3','uk',18,true,'2022-12-01',18.9,'2022-11-01','2023-01-01',NULL,29.70,'2022-11-01',18.9,1,NULL,NULL,'2023-01-01',NULL,-10.80,NULL,NULL,'2022-09-01','2022-12-01',113.79,4),
	 ('V7J42heW8l19wiBJ8UpRyw==','game 3','ru',25,false,'2022-03-01',49.80,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,49.80,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-12-01',545.46,10),
	 ('V7J42heW8l19wiBJ8UpRyw==','game 3','ru',25,false,'2022-04-01',36.84,'2022-03-01','2022-05-01','2022-05-01',49.80,'2022-03-01',NULL,NULL,NULL,NULL,NULL,NULL,-12.96,NULL,NULL,'2022-03-01','2022-12-01',545.46,10),
	 ('V7J42heW8l19wiBJ8UpRyw==','game 3','ru',25,false,'2022-05-01',42.72,'2022-04-01','2022-06-01','2022-06-01',36.84,'2022-04-01',NULL,NULL,NULL,NULL,NULL,5.88,NULL,NULL,NULL,'2022-03-01','2022-12-01',545.46,10),
	 ('V7J42heW8l19wiBJ8UpRyw==','game 3','ru',25,false,'2022-06-01',31.95,'2022-05-01','2022-07-01','2022-07-01',42.72,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-10.77,NULL,NULL,'2022-03-01','2022-12-01',545.46,10),
	 ('V7J42heW8l19wiBJ8UpRyw==','game 3','ru',25,false,'2022-07-01',67.56,'2022-06-01','2022-08-01','2022-08-01',31.95,'2022-06-01',NULL,NULL,NULL,NULL,NULL,35.61,NULL,NULL,NULL,'2022-03-01','2022-12-01',545.46,10),
	 ('V7J42heW8l19wiBJ8UpRyw==','game 3','ru',25,false,'2022-08-01',73.41,'2022-07-01','2022-09-01','2022-09-01',67.56,'2022-07-01',NULL,NULL,NULL,NULL,NULL,5.85,NULL,NULL,NULL,'2022-03-01','2022-12-01',545.46,10);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('V7J42heW8l19wiBJ8UpRyw==','game 3','ru',25,false,'2022-09-01',54.24,'2022-08-01','2022-10-01','2022-10-01',73.41,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-19.17,NULL,NULL,'2022-03-01','2022-12-01',545.46,10),
	 ('V7J42heW8l19wiBJ8UpRyw==','game 3','ru',25,false,'2022-10-01',56.64,'2022-09-01','2022-11-01','2022-11-01',54.24,'2022-09-01',NULL,NULL,NULL,NULL,NULL,2.40,NULL,NULL,NULL,'2022-03-01','2022-12-01',545.46,10),
	 ('V7J42heW8l19wiBJ8UpRyw==','game 3','ru',25,false,'2022-11-01',22.29,'2022-10-01','2022-12-01','2022-12-01',56.64,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-34.35,NULL,NULL,'2022-03-01','2022-12-01',545.46,10),
	 ('V7J42heW8l19wiBJ8UpRyw==','game 3','ru',25,false,'2022-12-01',110.01,'2022-11-01','2023-01-01',NULL,22.29,'2022-11-01',110.01,1,NULL,NULL,'2023-01-01',87.72,NULL,NULL,NULL,'2022-03-01','2022-12-01',545.46,10),
	 ('v9uJC6CIm0KR00+LpWQUBg==','game 3','uk',18,false,'2022-06-01',30.87,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,30.87,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-12-01',337.71,7),
	 ('v9uJC6CIm0KR00+LpWQUBg==','game 3','uk',18,false,'2022-07-01',94.50,'2022-06-01','2022-08-01','2022-09-01',30.87,'2022-06-01',94.50,1,NULL,NULL,'2022-08-01',63.63,NULL,NULL,NULL,'2022-06-01','2022-12-01',337.71,7),
	 ('v9uJC6CIm0KR00+LpWQUBg==','game 3','uk',18,false,'2022-09-01',18.21,'2022-07-01','2022-10-01','2022-10-01',94.50,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,18.21,1,'2022-06-01','2022-12-01',337.71,7),
	 ('v9uJC6CIm0KR00+LpWQUBg==','game 3','uk',18,false,'2022-10-01',34.62,'2022-09-01','2022-11-01','2022-11-01',18.21,'2022-09-01',NULL,NULL,NULL,NULL,NULL,16.41,NULL,NULL,NULL,'2022-06-01','2022-12-01',337.71,7),
	 ('v9uJC6CIm0KR00+LpWQUBg==','game 3','uk',18,false,'2022-11-01',72.27,'2022-10-01','2022-12-01','2022-12-01',34.62,'2022-10-01',NULL,NULL,NULL,NULL,NULL,37.65,NULL,NULL,NULL,'2022-06-01','2022-12-01',337.71,7),
	 ('v9uJC6CIm0KR00+LpWQUBg==','game 3','uk',18,false,'2022-12-01',87.24,'2022-11-01','2023-01-01',NULL,72.27,'2022-11-01',87.24,1,NULL,NULL,'2023-01-01',14.97,NULL,NULL,NULL,'2022-06-01','2022-12-01',337.71,7);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('va4krMfpHwzELV/AUI7WHQ==','game 3','uk',20,false,'2022-08-01',21.12,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,21.12,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',145.44,5),
	 ('va4krMfpHwzELV/AUI7WHQ==','game 3','uk',20,false,'2022-09-01',44.25,'2022-08-01','2022-10-01','2022-10-01',21.12,'2022-08-01',NULL,NULL,NULL,NULL,NULL,23.13,NULL,NULL,NULL,'2022-08-01','2022-12-01',145.44,5),
	 ('va4krMfpHwzELV/AUI7WHQ==','game 3','uk',20,false,'2022-10-01',58.20,'2022-09-01','2022-11-01','2022-12-01',44.25,'2022-09-01',58.20,1,NULL,NULL,'2022-11-01',13.95,NULL,NULL,NULL,'2022-08-01','2022-12-01',145.44,5),
	 ('va4krMfpHwzELV/AUI7WHQ==','game 3','uk',20,false,'2022-12-01',21.87,'2022-10-01','2023-01-01',NULL,58.20,'2022-11-01',21.87,1,NULL,NULL,'2023-01-01',NULL,NULL,21.87,1,'2022-08-01','2022-12-01',145.44,5),
	 ('VAduzk1Og0uicXfMLD3VbQ==','game 3','uk',25,false,'2022-08-01',42.72,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,42.72,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',266.07,5),
	 ('VAduzk1Og0uicXfMLD3VbQ==','game 3','uk',25,false,'2022-09-01',122.01,'2022-08-01','2022-10-01','2022-10-01',42.72,'2022-08-01',NULL,NULL,NULL,NULL,NULL,79.29,NULL,NULL,NULL,'2022-08-01','2022-12-01',266.07,5),
	 ('VAduzk1Og0uicXfMLD3VbQ==','game 3','uk',25,false,'2022-10-01',80.04,'2022-09-01','2022-11-01','2022-12-01',122.01,'2022-09-01',80.04,1,NULL,NULL,'2022-11-01',NULL,-41.97,NULL,NULL,'2022-08-01','2022-12-01',266.07,5),
	 ('VAduzk1Og0uicXfMLD3VbQ==','game 3','uk',25,false,'2022-12-01',21.3,'2022-10-01','2023-01-01',NULL,80.04,'2022-11-01',21.3,1,NULL,NULL,'2023-01-01',NULL,NULL,21.3,1,'2022-08-01','2022-12-01',266.07,5),
	 ('Veep00i4vvZbTAVD6GMoiA==','game 3','uk',38,false,'2022-03-01',12.72,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,12.72,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-11-01',389.67,9),
	 ('Veep00i4vvZbTAVD6GMoiA==','game 3','uk',38,false,'2022-04-01',48.33,'2022-03-01','2022-05-01','2022-06-01',12.72,'2022-03-01',48.33,1,NULL,NULL,'2022-05-01',35.61,NULL,NULL,NULL,'2022-03-01','2022-11-01',389.67,9);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('Veep00i4vvZbTAVD6GMoiA==','game 3','uk',38,false,'2022-06-01',36.78,'2022-04-01','2022-07-01','2022-07-01',48.33,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,36.78,1,'2022-03-01','2022-11-01',389.67,9),
	 ('Veep00i4vvZbTAVD6GMoiA==','game 3','uk',38,false,'2022-07-01',31.26,'2022-06-01','2022-08-01','2022-08-01',36.78,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-5.52,NULL,NULL,'2022-03-01','2022-11-01',389.67,9),
	 ('Veep00i4vvZbTAVD6GMoiA==','game 3','uk',38,false,'2022-08-01',69.36,'2022-07-01','2022-09-01','2022-09-01',31.26,'2022-07-01',NULL,NULL,NULL,NULL,NULL,38.10,NULL,NULL,NULL,'2022-03-01','2022-11-01',389.67,9),
	 ('Veep00i4vvZbTAVD6GMoiA==','game 3','uk',38,false,'2022-09-01',49.53,'2022-08-01','2022-10-01','2022-10-01',69.36,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-19.83,NULL,NULL,'2022-03-01','2022-11-01',389.67,9),
	 ('Veep00i4vvZbTAVD6GMoiA==','game 3','uk',38,false,'2022-10-01',126.84,'2022-09-01','2022-11-01','2022-11-01',49.53,'2022-09-01',NULL,NULL,NULL,NULL,NULL,77.31,NULL,NULL,NULL,'2022-03-01','2022-11-01',389.67,9),
	 ('Veep00i4vvZbTAVD6GMoiA==','game 3','uk',38,false,'2022-11-01',14.85,'2022-10-01','2022-12-01',NULL,126.84,'2022-10-01',14.85,1,NULL,NULL,'2022-12-01',NULL,-111.99,NULL,NULL,'2022-03-01','2022-11-01',389.67,9),
	 ('VGEh7S+cxW9PT7H8KNgEGQ==','game 3','uk',24,false,'2022-08-01',324.15,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,324.15,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',948.75,5),
	 ('VGEh7S+cxW9PT7H8KNgEGQ==','game 3','uk',24,false,'2022-09-01',220.08,'2022-08-01','2022-10-01','2022-10-01',324.15,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-104.07,NULL,NULL,'2022-08-01','2022-12-01',948.75,5),
	 ('VGEh7S+cxW9PT7H8KNgEGQ==','game 3','uk',24,false,'2022-10-01',158.67,'2022-09-01','2022-11-01','2022-11-01',220.08,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-61.41,NULL,NULL,'2022-08-01','2022-12-01',948.75,5),
	 ('VGEh7S+cxW9PT7H8KNgEGQ==','game 3','uk',24,false,'2022-11-01',161.10,'2022-10-01','2022-12-01','2022-12-01',158.67,'2022-10-01',NULL,NULL,NULL,NULL,NULL,2.43,NULL,NULL,NULL,'2022-08-01','2022-12-01',948.75,5);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('VGEh7S+cxW9PT7H8KNgEGQ==','game 3','uk',24,false,'2022-12-01',84.75,'2022-11-01','2023-01-01',NULL,161.10,'2022-11-01',84.75,1,NULL,NULL,'2023-01-01',NULL,-76.35,NULL,NULL,'2022-08-01','2022-12-01',948.75,5),
	 ('Vn7Z6/B2x4f/w8R6xVfw5w==','game 3','uk',18,false,'2022-07-01',21.81,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,21.81,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',274.02,6),
	 ('Vn7Z6/B2x4f/w8R6xVfw5w==','game 3','uk',18,false,'2022-08-01',73.20,'2022-07-01','2022-09-01','2022-09-01',21.81,'2022-07-01',NULL,NULL,NULL,NULL,NULL,51.39,NULL,NULL,NULL,'2022-07-01','2022-12-01',274.02,6),
	 ('Vn7Z6/B2x4f/w8R6xVfw5w==','game 3','uk',18,false,'2022-09-01',72.54,'2022-08-01','2022-10-01','2022-10-01',73.20,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-0.66,NULL,NULL,'2022-07-01','2022-12-01',274.02,6),
	 ('Vn7Z6/B2x4f/w8R6xVfw5w==','game 3','uk',18,false,'2022-10-01',67.08,'2022-09-01','2022-11-01','2022-12-01',72.54,'2022-09-01',67.08,1,NULL,NULL,'2022-11-01',NULL,-5.46,NULL,NULL,'2022-07-01','2022-12-01',274.02,6),
	 ('Vn7Z6/B2x4f/w8R6xVfw5w==','game 3','uk',18,false,'2022-12-01',39.39,'2022-10-01','2023-01-01',NULL,67.08,'2022-11-01',39.39,1,NULL,NULL,'2023-01-01',NULL,NULL,39.39,1,'2022-07-01','2022-12-01',274.02,6),
	 ('VsqfOK9/JhBXzScG5Ybudg==','game 3','uk',35,false,'2022-11-01',15.66,NULL,'2022-12-01',NULL,NULL,'2022-10-01',15.66,1,15.66,1,'2022-12-01',NULL,NULL,NULL,NULL,'2022-11-01','2022-11-01',15.66,1),
	 ('VTaIkhD9hJKcnvA6Kw5p9g==','game 3','ru',25,false,'2022-09-01',28.32,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,28.32,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',307.80,4),
	 ('VTaIkhD9hJKcnvA6Kw5p9g==','game 3','ru',25,false,'2022-10-01',40.74,'2022-09-01','2022-11-01','2022-11-01',28.32,'2022-09-01',NULL,NULL,NULL,NULL,NULL,12.42,NULL,NULL,NULL,'2022-09-01','2022-12-01',307.80,4),
	 ('VTaIkhD9hJKcnvA6Kw5p9g==','game 3','ru',25,false,'2022-11-01',161.94,'2022-10-01','2022-12-01','2022-12-01',40.74,'2022-10-01',NULL,NULL,NULL,NULL,NULL,121.20,NULL,NULL,NULL,'2022-09-01','2022-12-01',307.80,4);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('VTaIkhD9hJKcnvA6Kw5p9g==','game 3','ru',25,false,'2022-12-01',76.80,'2022-11-01','2023-01-01',NULL,161.94,'2022-11-01',76.80,1,NULL,NULL,'2023-01-01',NULL,-85.14,NULL,NULL,'2022-09-01','2022-12-01',307.80,4),
	 ('Vtl1tAkN8ajIRaOwKulKyQ==','game 3','uk',25,false,'2022-10-01',42.0,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,42.0,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',120.48,3),
	 ('Vtl1tAkN8ajIRaOwKulKyQ==','game 3','uk',25,false,'2022-11-01',21.9,'2022-10-01','2022-12-01','2022-12-01',42.0,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-20.1,NULL,NULL,'2022-10-01','2022-12-01',120.48,3),
	 ('Vtl1tAkN8ajIRaOwKulKyQ==','game 3','uk',25,false,'2022-12-01',56.58,'2022-11-01','2023-01-01',NULL,21.9,'2022-11-01',56.58,1,NULL,NULL,'2023-01-01',34.68,NULL,NULL,NULL,'2022-10-01','2022-12-01',120.48,3),
	 ('VzxrkGURuahRUx/43mjAFQ==','game 3','uk',37,false,'2022-07-01',17.16,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,17.16,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-10-01',68.97,4),
	 ('VzxrkGURuahRUx/43mjAFQ==','game 3','uk',37,false,'2022-08-01',39.48,'2022-07-01','2022-09-01','2022-10-01',17.16,'2022-07-01',39.48,1,NULL,NULL,'2022-09-01',22.32,NULL,NULL,NULL,'2022-07-01','2022-10-01',68.97,4),
	 ('VzxrkGURuahRUx/43mjAFQ==','game 3','uk',37,false,'2022-10-01',12.33,'2022-08-01','2022-11-01',NULL,39.48,'2022-09-01',12.33,1,NULL,NULL,'2022-11-01',NULL,NULL,12.33,1,'2022-07-01','2022-10-01',68.97,4),
	 ('W6fRYNhsTNHQkvkoFEUaVQ==','game 3','uk',16,false,'2022-03-01',48.33,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,48.33,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-12-01',472.20,10),
	 ('W6fRYNhsTNHQkvkoFEUaVQ==','game 3','uk',16,false,'2022-04-01',57.72,'2022-03-01','2022-05-01','2022-05-01',48.33,'2022-03-01',NULL,NULL,NULL,NULL,NULL,9.39,NULL,NULL,NULL,'2022-03-01','2022-12-01',472.20,10),
	 ('W6fRYNhsTNHQkvkoFEUaVQ==','game 3','uk',16,false,'2022-05-01',95.91,'2022-04-01','2022-06-01','2022-06-01',57.72,'2022-04-01',NULL,NULL,NULL,NULL,NULL,38.19,NULL,NULL,NULL,'2022-03-01','2022-12-01',472.20,10);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('W6fRYNhsTNHQkvkoFEUaVQ==','game 3','uk',16,false,'2022-06-01',55.02,'2022-05-01','2022-07-01','2022-07-01',95.91,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-40.89,NULL,NULL,'2022-03-01','2022-12-01',472.20,10),
	 ('W6fRYNhsTNHQkvkoFEUaVQ==','game 3','uk',16,false,'2022-07-01',96.51,'2022-06-01','2022-08-01','2022-09-01',55.02,'2022-06-01',96.51,1,NULL,NULL,'2022-08-01',41.49,NULL,NULL,NULL,'2022-03-01','2022-12-01',472.20,10),
	 ('W6fRYNhsTNHQkvkoFEUaVQ==','game 3','uk',16,false,'2022-09-01',43.5,'2022-07-01','2022-10-01','2022-10-01',96.51,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,43.5,1,'2022-03-01','2022-12-01',472.20,10),
	 ('W6fRYNhsTNHQkvkoFEUaVQ==','game 3','uk',16,false,'2022-10-01',36.03,'2022-09-01','2022-11-01','2022-12-01',43.5,'2022-09-01',36.03,1,NULL,NULL,'2022-11-01',NULL,-7.47,NULL,NULL,'2022-03-01','2022-12-01',472.20,10),
	 ('W6fRYNhsTNHQkvkoFEUaVQ==','game 3','uk',16,false,'2022-12-01',39.18,'2022-10-01','2023-01-01',NULL,36.03,'2022-11-01',39.18,1,NULL,NULL,'2023-01-01',NULL,NULL,39.18,1,'2022-03-01','2022-12-01',472.20,10),
	 ('WAdVK2sJHdBL0bCFyVa0ww==','game 3','uk',14,false,'2022-04-01',24.09,NULL,'2022-05-01',NULL,NULL,'2022-03-01',24.09,1,24.09,1,'2022-05-01',NULL,NULL,NULL,NULL,'2022-04-01','2022-04-01',24.09,1),
	 ('wA+Rd++M6EKUppqQeb+pTw==','game 3','uk',20,false,'2022-08-01',15.6,NULL,'2022-09-01','2022-09-01',NULL,'2022-07-01',NULL,NULL,15.6,1,NULL,NULL,NULL,NULL,NULL,'2022-08-01','2022-12-01',101.31,5),
	 ('wA+Rd++M6EKUppqQeb+pTw==','game 3','uk',20,false,'2022-09-01',12.15,'2022-08-01','2022-10-01','2022-10-01',15.6,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-3.45,NULL,NULL,'2022-08-01','2022-12-01',101.31,5),
	 ('wA+Rd++M6EKUppqQeb+pTw==','game 3','uk',20,false,'2022-10-01',31.92,'2022-09-01','2022-11-01','2022-11-01',12.15,'2022-09-01',NULL,NULL,NULL,NULL,NULL,19.77,NULL,NULL,NULL,'2022-08-01','2022-12-01',101.31,5),
	 ('wA+Rd++M6EKUppqQeb+pTw==','game 3','uk',20,false,'2022-11-01',18.93,'2022-10-01','2022-12-01','2022-12-01',31.92,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-12.99,NULL,NULL,'2022-08-01','2022-12-01',101.31,5);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('wA+Rd++M6EKUppqQeb+pTw==','game 3','uk',20,false,'2022-12-01',22.71,'2022-11-01','2023-01-01',NULL,18.93,'2022-11-01',22.71,1,NULL,NULL,'2023-01-01',3.78,NULL,NULL,NULL,'2022-08-01','2022-12-01',101.31,5),
	 ('WDsSR+yQGqoMMBfCxqkZlw==','game 3','uk',24,false,'2022-05-01',49.05,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,49.05,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-11-01',360.51,7),
	 ('WDsSR+yQGqoMMBfCxqkZlw==','game 3','uk',24,false,'2022-06-01',91.05,'2022-05-01','2022-07-01','2022-07-01',49.05,'2022-05-01',NULL,NULL,NULL,NULL,NULL,42.00,NULL,NULL,NULL,'2022-05-01','2022-11-01',360.51,7),
	 ('WDsSR+yQGqoMMBfCxqkZlw==','game 3','uk',24,false,'2022-07-01',109.26,'2022-06-01','2022-08-01','2022-10-01',91.05,'2022-06-01',109.26,1,NULL,NULL,'2022-08-01',18.21,NULL,NULL,NULL,'2022-05-01','2022-11-01',360.51,7),
	 ('WDsSR+yQGqoMMBfCxqkZlw==','game 3','uk',24,false,'2022-10-01',71.91,'2022-07-01','2022-11-01','2022-11-01',109.26,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,71.91,1,'2022-05-01','2022-11-01',360.51,7),
	 ('WDsSR+yQGqoMMBfCxqkZlw==','game 3','uk',24,false,'2022-11-01',39.24,'2022-10-01','2022-12-01',NULL,71.91,'2022-10-01',39.24,1,NULL,NULL,'2022-12-01',NULL,-32.67,NULL,NULL,'2022-05-01','2022-11-01',360.51,7),
	 ('wDXJbTe2RLmAMKsPm5zZDg==','game 3','ru',17,false,'2022-05-01',74.01,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,74.01,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-10-01',582.00,6),
	 ('wDXJbTe2RLmAMKsPm5zZDg==','game 3','ru',17,false,'2022-06-01',204.48,'2022-05-01','2022-07-01','2022-07-01',74.01,'2022-05-01',NULL,NULL,NULL,NULL,NULL,130.47,NULL,NULL,NULL,'2022-05-01','2022-10-01',582.00,6),
	 ('wDXJbTe2RLmAMKsPm5zZDg==','game 3','ru',17,false,'2022-07-01',76.92,'2022-06-01','2022-08-01','2022-08-01',204.48,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-127.56,NULL,NULL,'2022-05-01','2022-10-01',582.00,6),
	 ('wDXJbTe2RLmAMKsPm5zZDg==','game 3','ru',17,false,'2022-08-01',103.71,'2022-07-01','2022-09-01','2022-09-01',76.92,'2022-07-01',NULL,NULL,NULL,NULL,NULL,26.79,NULL,NULL,NULL,'2022-05-01','2022-10-01',582.00,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('wDXJbTe2RLmAMKsPm5zZDg==','game 3','ru',17,false,'2022-09-01',24.33,'2022-08-01','2022-10-01','2022-10-01',103.71,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-79.38,NULL,NULL,'2022-05-01','2022-10-01',582.00,6),
	 ('wDXJbTe2RLmAMKsPm5zZDg==','game 3','ru',17,false,'2022-10-01',98.55,'2022-09-01','2022-11-01',NULL,24.33,'2022-09-01',98.55,1,NULL,NULL,'2022-11-01',74.22,NULL,NULL,NULL,'2022-05-01','2022-10-01',582.00,6),
	 ('WHwqHTWZHdOrSBFh/vackQ==','game 3','uk',18,false,'2022-09-01',13.2,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,13.2,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-10-01',80.04,2),
	 ('WHwqHTWZHdOrSBFh/vackQ==','game 3','uk',18,false,'2022-10-01',66.84,'2022-09-01','2022-11-01',NULL,13.2,'2022-09-01',66.84,1,NULL,NULL,'2022-11-01',53.64,NULL,NULL,NULL,'2022-09-01','2022-10-01',80.04,2),
	 ('Wi8qtp9drPDZD0laCPi2Ng==','game 3','uk',26,false,'2022-05-01',12.99,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,12.99,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-12-01',66.81,8),
	 ('Wi8qtp9drPDZD0laCPi2Ng==','game 3','uk',26,false,'2022-06-01',14.04,'2022-05-01','2022-07-01','2022-09-01',12.99,'2022-05-01',14.04,1,NULL,NULL,'2022-07-01',1.05,NULL,NULL,NULL,'2022-05-01','2022-12-01',66.81,8),
	 ('Wi8qtp9drPDZD0laCPi2Ng==','game 3','uk',26,false,'2022-09-01',26.64,'2022-06-01','2022-10-01','2022-12-01',14.04,'2022-08-01',26.64,1,NULL,NULL,'2022-10-01',NULL,NULL,26.64,1,'2022-05-01','2022-12-01',66.81,8),
	 ('Wi8qtp9drPDZD0laCPi2Ng==','game 3','uk',26,false,'2022-12-01',13.14,'2022-09-01','2023-01-01',NULL,26.64,'2022-11-01',13.14,1,NULL,NULL,'2023-01-01',NULL,NULL,13.14,1,'2022-05-01','2022-12-01',66.81,8),
	 ('wjWDL/+l9D+LVt/9gNMH5Q==','game 3','ru',20,false,'2022-05-01',12.12,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,12.12,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-11-01',258.27,7),
	 ('wjWDL/+l9D+LVt/9gNMH5Q==','game 3','ru',20,false,'2022-06-01',13.08,'2022-05-01','2022-07-01','2022-07-01',12.12,'2022-05-01',NULL,NULL,NULL,NULL,NULL,0.96,NULL,NULL,NULL,'2022-05-01','2022-11-01',258.27,7);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('wjWDL/+l9D+LVt/9gNMH5Q==','game 3','ru',20,false,'2022-07-01',35.22,'2022-06-01','2022-08-01','2022-09-01',13.08,'2022-06-01',35.22,1,NULL,NULL,'2022-08-01',22.14,NULL,NULL,NULL,'2022-05-01','2022-11-01',258.27,7),
	 ('wjWDL/+l9D+LVt/9gNMH5Q==','game 3','ru',20,false,'2022-09-01',43.53,'2022-07-01','2022-10-01','2022-10-01',35.22,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,43.53,1,'2022-05-01','2022-11-01',258.27,7),
	 ('wjWDL/+l9D+LVt/9gNMH5Q==','game 3','ru',20,false,'2022-10-01',118.62,'2022-09-01','2022-11-01','2022-11-01',43.53,'2022-09-01',NULL,NULL,NULL,NULL,NULL,75.09,NULL,NULL,NULL,'2022-05-01','2022-11-01',258.27,7),
	 ('wjWDL/+l9D+LVt/9gNMH5Q==','game 3','ru',20,false,'2022-11-01',35.70,'2022-10-01','2022-12-01',NULL,118.62,'2022-10-01',35.70,1,NULL,NULL,'2022-12-01',NULL,-82.92,NULL,NULL,'2022-05-01','2022-11-01',258.27,7),
	 ('WMcncRFNp4e91e/Y3CwEvQ==','game 3','uk',23,false,'2022-07-01',14.04,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,14.04,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',205.50,6),
	 ('WMcncRFNp4e91e/Y3CwEvQ==','game 3','uk',23,false,'2022-08-01',41.16,'2022-07-01','2022-09-01','2022-09-01',14.04,'2022-07-01',NULL,NULL,NULL,NULL,NULL,27.12,NULL,NULL,NULL,'2022-07-01','2022-12-01',205.50,6),
	 ('WMcncRFNp4e91e/Y3CwEvQ==','game 3','uk',23,false,'2022-09-01',57.06,'2022-08-01','2022-10-01','2022-10-01',41.16,'2022-08-01',NULL,NULL,NULL,NULL,NULL,15.90,NULL,NULL,NULL,'2022-07-01','2022-12-01',205.50,6),
	 ('WMcncRFNp4e91e/Y3CwEvQ==','game 3','uk',23,false,'2022-10-01',19.74,'2022-09-01','2022-11-01','2022-11-01',57.06,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-37.32,NULL,NULL,'2022-07-01','2022-12-01',205.50,6),
	 ('WMcncRFNp4e91e/Y3CwEvQ==','game 3','uk',23,false,'2022-11-01',42.60,'2022-10-01','2022-12-01','2022-12-01',19.74,'2022-10-01',NULL,NULL,NULL,NULL,NULL,22.86,NULL,NULL,NULL,'2022-07-01','2022-12-01',205.50,6),
	 ('WMcncRFNp4e91e/Y3CwEvQ==','game 3','uk',23,false,'2022-12-01',30.90,'2022-11-01','2023-01-01',NULL,42.60,'2022-11-01',30.90,1,NULL,NULL,'2023-01-01',NULL,-11.70,NULL,NULL,'2022-07-01','2022-12-01',205.50,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('wRHnn4opzbqIBjFFNpBJtw==','game 3','uk',29,false,'2022-07-01',12.99,NULL,'2022-08-01','2022-10-01',NULL,'2022-06-01',12.99,1,12.99,1,'2022-08-01',NULL,NULL,NULL,NULL,'2022-07-01','2022-11-01',57.06,5),
	 ('wRHnn4opzbqIBjFFNpBJtw==','game 3','uk',29,false,'2022-10-01',13.59,'2022-07-01','2022-11-01','2022-11-01',12.99,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,13.59,1,'2022-07-01','2022-11-01',57.06,5),
	 ('wRHnn4opzbqIBjFFNpBJtw==','game 3','uk',29,false,'2022-11-01',30.48,'2022-10-01','2022-12-01',NULL,13.59,'2022-10-01',30.48,1,NULL,NULL,'2022-12-01',16.89,NULL,NULL,NULL,'2022-07-01','2022-11-01',57.06,5),
	 ('WRx4ye0bvLc4925ketwxzQ==','game 3','uk',14,false,'2022-10-01',19.8,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,19.8,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',146.85,3),
	 ('WRx4ye0bvLc4925ketwxzQ==','game 3','uk',14,false,'2022-11-01',50.82,'2022-10-01','2022-12-01','2022-12-01',19.8,'2022-10-01',NULL,NULL,NULL,NULL,NULL,31.02,NULL,NULL,NULL,'2022-10-01','2022-12-01',146.85,3),
	 ('WRx4ye0bvLc4925ketwxzQ==','game 3','uk',14,false,'2022-12-01',76.23,'2022-11-01','2023-01-01',NULL,50.82,'2022-11-01',76.23,1,NULL,NULL,'2023-01-01',25.41,NULL,NULL,NULL,'2022-10-01','2022-12-01',146.85,3),
	 ('WSQTlRZJRg4Rb+rqe56nJg==','game 3','uk',26,false,'2022-06-01',14.7,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,14.7,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-12-01',169.05,7),
	 ('WSQTlRZJRg4Rb+rqe56nJg==','game 3','uk',26,false,'2022-07-01',33.75,'2022-06-01','2022-08-01','2022-08-01',14.7,'2022-06-01',NULL,NULL,NULL,NULL,NULL,19.05,NULL,NULL,NULL,'2022-06-01','2022-12-01',169.05,7),
	 ('WSQTlRZJRg4Rb+rqe56nJg==','game 3','uk',26,false,'2022-08-01',26.31,'2022-07-01','2022-09-01','2022-09-01',33.75,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-7.44,NULL,NULL,'2022-06-01','2022-12-01',169.05,7),
	 ('WSQTlRZJRg4Rb+rqe56nJg==','game 3','uk',26,false,'2022-09-01',30.51,'2022-08-01','2022-10-01','2022-10-01',26.31,'2022-08-01',NULL,NULL,NULL,NULL,NULL,4.20,NULL,NULL,NULL,'2022-06-01','2022-12-01',169.05,7);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('WSQTlRZJRg4Rb+rqe56nJg==','game 3','uk',26,false,'2022-10-01',32.13,'2022-09-01','2022-11-01','2022-11-01',30.51,'2022-09-01',NULL,NULL,NULL,NULL,NULL,1.62,NULL,NULL,NULL,'2022-06-01','2022-12-01',169.05,7),
	 ('WSQTlRZJRg4Rb+rqe56nJg==','game 3','uk',26,false,'2022-11-01',17.67,'2022-10-01','2022-12-01','2022-12-01',32.13,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-14.46,NULL,NULL,'2022-06-01','2022-12-01',169.05,7),
	 ('WSQTlRZJRg4Rb+rqe56nJg==','game 3','uk',26,false,'2022-12-01',13.98,'2022-11-01','2023-01-01',NULL,17.67,'2022-11-01',13.98,1,NULL,NULL,'2023-01-01',NULL,-3.69,NULL,NULL,'2022-06-01','2022-12-01',169.05,7),
	 ('Wua5DlzLb2yNeSrcG9Xi3g==','game 3','uk',23,false,'2022-04-01',59.85,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,59.85,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-10-01',172.53,7),
	 ('Wua5DlzLb2yNeSrcG9Xi3g==','game 3','uk',23,false,'2022-05-01',68.73,'2022-04-01','2022-06-01','2022-09-01',59.85,'2022-04-01',68.73,1,NULL,NULL,'2022-06-01',8.88,NULL,NULL,NULL,'2022-04-01','2022-10-01',172.53,7),
	 ('Wua5DlzLb2yNeSrcG9Xi3g==','game 3','uk',23,false,'2022-09-01',17.67,'2022-05-01','2022-10-01','2022-10-01',68.73,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,17.67,1,'2022-04-01','2022-10-01',172.53,7),
	 ('Wua5DlzLb2yNeSrcG9Xi3g==','game 3','uk',23,false,'2022-10-01',26.28,'2022-09-01','2022-11-01',NULL,17.67,'2022-09-01',26.28,1,NULL,NULL,'2022-11-01',8.61,NULL,NULL,NULL,'2022-04-01','2022-10-01',172.53,7),
	 ('XD0CalOV926o6zGoOAKfVA==','game 3','uk',14,true,'2022-10-01',12.75,NULL,'2022-11-01',NULL,NULL,'2022-09-01',12.75,1,12.75,1,'2022-11-01',NULL,NULL,NULL,NULL,'2022-10-01','2022-10-01',12.75,1),
	 ('XE2e8BsmBo72HxABlJmsRw==','game 3','uk',20,false,'2022-03-01',38.16,NULL,'2022-04-01',NULL,NULL,'2022-02-01',38.16,1,38.16,1,'2022-04-01',NULL,NULL,NULL,NULL,'2022-03-01','2022-03-01',38.16,1),
	 ('xiXTXOEbWU+HnGOUmgc9/w==','game 3','uk',20,false,'2022-03-01',24.18,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,24.18,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-08-01',271.59,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('xiXTXOEbWU+HnGOUmgc9/w==','game 3','uk',20,false,'2022-04-01',99.84,'2022-03-01','2022-05-01','2022-05-01',24.18,'2022-03-01',NULL,NULL,NULL,NULL,NULL,75.66,NULL,NULL,NULL,'2022-03-01','2022-08-01',271.59,6),
	 ('xiXTXOEbWU+HnGOUmgc9/w==','game 3','uk',20,false,'2022-05-01',73.29,'2022-04-01','2022-06-01','2022-06-01',99.84,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-26.55,NULL,NULL,'2022-03-01','2022-08-01',271.59,6),
	 ('xiXTXOEbWU+HnGOUmgc9/w==','game 3','uk',20,false,'2022-06-01',15.06,'2022-05-01','2022-07-01','2022-07-01',73.29,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-58.23,NULL,NULL,'2022-03-01','2022-08-01',271.59,6),
	 ('xiXTXOEbWU+HnGOUmgc9/w==','game 3','uk',20,false,'2022-07-01',45.75,'2022-06-01','2022-08-01','2022-08-01',15.06,'2022-06-01',NULL,NULL,NULL,NULL,NULL,30.69,NULL,NULL,NULL,'2022-03-01','2022-08-01',271.59,6),
	 ('xiXTXOEbWU+HnGOUmgc9/w==','game 3','uk',20,false,'2022-08-01',13.47,'2022-07-01','2022-09-01',NULL,45.75,'2022-07-01',13.47,1,NULL,NULL,'2022-09-01',NULL,-32.28,NULL,NULL,'2022-03-01','2022-08-01',271.59,6),
	 ('xnLJlU804PSS9tXKmm7gZQ==','game 3','ru',21,true,'2022-04-01',26.61,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,26.61,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-12-01',353.61,9),
	 ('xnLJlU804PSS9tXKmm7gZQ==','game 3','ru',21,true,'2022-05-01',96.06,'2022-04-01','2022-06-01','2022-06-01',26.61,'2022-04-01',NULL,NULL,NULL,NULL,NULL,69.45,NULL,NULL,NULL,'2022-04-01','2022-12-01',353.61,9),
	 ('xnLJlU804PSS9tXKmm7gZQ==','game 3','ru',21,true,'2022-06-01',35.88,'2022-05-01','2022-07-01','2022-07-01',96.06,'2022-05-01',NULL,NULL,NULL,NULL,NULL,NULL,-60.18,NULL,NULL,'2022-04-01','2022-12-01',353.61,9),
	 ('xnLJlU804PSS9tXKmm7gZQ==','game 3','ru',21,true,'2022-07-01',56.34,'2022-06-01','2022-08-01','2022-08-01',35.88,'2022-06-01',NULL,NULL,NULL,NULL,NULL,20.46,NULL,NULL,NULL,'2022-04-01','2022-12-01',353.61,9),
	 ('xnLJlU804PSS9tXKmm7gZQ==','game 3','ru',21,true,'2022-08-01',12.6,'2022-07-01','2022-09-01','2022-09-01',56.34,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-43.74,NULL,NULL,'2022-04-01','2022-12-01',353.61,9);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('xnLJlU804PSS9tXKmm7gZQ==','game 3','ru',21,true,'2022-09-01',32.70,'2022-08-01','2022-10-01','2022-10-01',12.6,'2022-08-01',NULL,NULL,NULL,NULL,NULL,20.10,NULL,NULL,NULL,'2022-04-01','2022-12-01',353.61,9),
	 ('xnLJlU804PSS9tXKmm7gZQ==','game 3','ru',21,true,'2022-10-01',27.30,'2022-09-01','2022-11-01','2022-11-01',32.70,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-5.40,NULL,NULL,'2022-04-01','2022-12-01',353.61,9),
	 ('xnLJlU804PSS9tXKmm7gZQ==','game 3','ru',21,true,'2022-11-01',45.24,'2022-10-01','2022-12-01','2022-12-01',27.30,'2022-10-01',NULL,NULL,NULL,NULL,NULL,17.94,NULL,NULL,NULL,'2022-04-01','2022-12-01',353.61,9),
	 ('xnLJlU804PSS9tXKmm7gZQ==','game 3','ru',21,true,'2022-12-01',20.88,'2022-11-01','2023-01-01',NULL,45.24,'2022-11-01',20.88,1,NULL,NULL,'2023-01-01',NULL,-24.36,NULL,NULL,'2022-04-01','2022-12-01',353.61,9),
	 ('+XPKfmhBmI2NdGQ96Iaysg==','game 3','uk',38,false,'2022-07-01',31.14,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,31.14,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',134.22,6),
	 ('+XPKfmhBmI2NdGQ96Iaysg==','game 3','uk',38,false,'2022-08-01',18.48,'2022-07-01','2022-09-01','2022-09-01',31.14,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-12.66,NULL,NULL,'2022-07-01','2022-12-01',134.22,6),
	 ('+XPKfmhBmI2NdGQ96Iaysg==','game 3','uk',38,false,'2022-09-01',21.87,'2022-08-01','2022-10-01','2022-10-01',18.48,'2022-08-01',NULL,NULL,NULL,NULL,NULL,3.39,NULL,NULL,NULL,'2022-07-01','2022-12-01',134.22,6),
	 ('+XPKfmhBmI2NdGQ96Iaysg==','game 3','uk',38,false,'2022-10-01',16.35,'2022-09-01','2022-11-01','2022-12-01',21.87,'2022-09-01',16.35,1,NULL,NULL,'2022-11-01',NULL,-5.52,NULL,NULL,'2022-07-01','2022-12-01',134.22,6),
	 ('+XPKfmhBmI2NdGQ96Iaysg==','game 3','uk',38,false,'2022-12-01',46.38,'2022-10-01','2023-01-01',NULL,16.35,'2022-11-01',46.38,1,NULL,NULL,'2023-01-01',NULL,NULL,46.38,1,'2022-07-01','2022-12-01',134.22,6),
	 ('XqdSNtx2TLDI6FMex45KTw==','game 3','uk',33,false,'2022-09-01',18.54,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,18.54,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-10-01',35.67,2);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('XqdSNtx2TLDI6FMex45KTw==','game 3','uk',33,false,'2022-10-01',17.13,'2022-09-01','2022-11-01',NULL,18.54,'2022-09-01',17.13,1,NULL,NULL,'2022-11-01',NULL,-1.41,NULL,NULL,'2022-09-01','2022-10-01',35.67,2),
	 ('xSi5UajdkNHXppWOTm6g8w==','game 3','uk',20,false,'2022-07-01',39.21,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,39.21,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',522.09,6),
	 ('xSi5UajdkNHXppWOTm6g8w==','game 3','uk',20,false,'2022-08-01',91.56,'2022-07-01','2022-09-01','2022-09-01',39.21,'2022-07-01',NULL,NULL,NULL,NULL,NULL,52.35,NULL,NULL,NULL,'2022-07-01','2022-12-01',522.09,6),
	 ('xSi5UajdkNHXppWOTm6g8w==','game 3','uk',20,false,'2022-09-01',67.56,'2022-08-01','2022-10-01','2022-10-01',91.56,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-24.00,NULL,NULL,'2022-07-01','2022-12-01',522.09,6),
	 ('xSi5UajdkNHXppWOTm6g8w==','game 3','uk',20,false,'2022-10-01',155.16,'2022-09-01','2022-11-01','2022-11-01',67.56,'2022-09-01',NULL,NULL,NULL,NULL,NULL,87.60,NULL,NULL,NULL,'2022-07-01','2022-12-01',522.09,6),
	 ('xSi5UajdkNHXppWOTm6g8w==','game 3','uk',20,false,'2022-11-01',78.48,'2022-10-01','2022-12-01','2022-12-01',155.16,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-76.68,NULL,NULL,'2022-07-01','2022-12-01',522.09,6),
	 ('xSi5UajdkNHXppWOTm6g8w==','game 3','uk',20,false,'2022-12-01',90.12,'2022-11-01','2023-01-01',NULL,78.48,'2022-11-01',90.12,1,NULL,NULL,'2023-01-01',11.64,NULL,NULL,NULL,'2022-07-01','2022-12-01',522.09,6),
	 ('xt/PY4N2zkZQgtlZ9Cg82w==','game 3','ru',24,false,'2022-06-01',67.71,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,67.71,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-12-01',382.65,7),
	 ('xt/PY4N2zkZQgtlZ9Cg82w==','game 3','ru',24,false,'2022-07-01',107.31,'2022-06-01','2022-08-01','2022-08-01',67.71,'2022-06-01',NULL,NULL,NULL,NULL,NULL,39.60,NULL,NULL,NULL,'2022-06-01','2022-12-01',382.65,7),
	 ('xt/PY4N2zkZQgtlZ9Cg82w==','game 3','ru',24,false,'2022-08-01',17.46,'2022-07-01','2022-09-01','2022-09-01',107.31,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-89.85,NULL,NULL,'2022-06-01','2022-12-01',382.65,7);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('xt/PY4N2zkZQgtlZ9Cg82w==','game 3','ru',24,false,'2022-09-01',44.04,'2022-08-01','2022-10-01','2022-11-01',17.46,'2022-08-01',44.04,1,NULL,NULL,'2022-10-01',26.58,NULL,NULL,NULL,'2022-06-01','2022-12-01',382.65,7),
	 ('xt/PY4N2zkZQgtlZ9Cg82w==','game 3','ru',24,false,'2022-11-01',90.45,'2022-09-01','2022-12-01','2022-12-01',44.04,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,90.45,1,'2022-06-01','2022-12-01',382.65,7),
	 ('xt/PY4N2zkZQgtlZ9Cg82w==','game 3','ru',24,false,'2022-12-01',55.68,'2022-11-01','2023-01-01',NULL,90.45,'2022-11-01',55.68,1,NULL,NULL,'2023-01-01',NULL,-34.77,NULL,NULL,'2022-06-01','2022-12-01',382.65,7),
	 ('xU11jJIA4UIYu7pmqJ4kvg==','game 3','uk',25,false,'2022-07-01',27.06,NULL,'2022-08-01','2022-10-01',NULL,'2022-06-01',27.06,1,27.06,1,'2022-08-01',NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',106.17,6),
	 ('xU11jJIA4UIYu7pmqJ4kvg==','game 3','uk',25,false,'2022-10-01',32.1,'2022-07-01','2022-11-01','2022-11-01',27.06,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,32.1,1,'2022-07-01','2022-12-01',106.17,6),
	 ('xU11jJIA4UIYu7pmqJ4kvg==','game 3','uk',25,false,'2022-11-01',28.71,'2022-10-01','2022-12-01','2022-12-01',32.1,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-3.39,NULL,NULL,'2022-07-01','2022-12-01',106.17,6),
	 ('xU11jJIA4UIYu7pmqJ4kvg==','game 3','uk',25,false,'2022-12-01',18.3,'2022-11-01','2023-01-01',NULL,28.71,'2022-11-01',18.3,1,NULL,NULL,'2023-01-01',NULL,-10.41,NULL,NULL,'2022-07-01','2022-12-01',106.17,6),
	 ('xVwGwMaEG1yZydv5VIfEQA==','game 3','uk',22,false,'2022-05-01',17.4,NULL,'2022-06-01','2022-07-01',NULL,'2022-04-01',17.4,1,17.4,1,'2022-06-01',NULL,NULL,NULL,NULL,'2022-05-01','2022-12-01',246.75,8),
	 ('xVwGwMaEG1yZydv5VIfEQA==','game 3','uk',22,false,'2022-07-01',15.87,'2022-05-01','2022-08-01','2022-08-01',17.4,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,15.87,1,'2022-05-01','2022-12-01',246.75,8),
	 ('xVwGwMaEG1yZydv5VIfEQA==','game 3','uk',22,false,'2022-08-01',17.94,'2022-07-01','2022-09-01','2022-09-01',15.87,'2022-07-01',NULL,NULL,NULL,NULL,NULL,2.07,NULL,NULL,NULL,'2022-05-01','2022-12-01',246.75,8);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('xVwGwMaEG1yZydv5VIfEQA==','game 3','uk',22,false,'2022-09-01',62.97,'2022-08-01','2022-10-01','2022-10-01',17.94,'2022-08-01',NULL,NULL,NULL,NULL,NULL,45.03,NULL,NULL,NULL,'2022-05-01','2022-12-01',246.75,8),
	 ('xVwGwMaEG1yZydv5VIfEQA==','game 3','uk',22,false,'2022-10-01',47.22,'2022-09-01','2022-11-01','2022-11-01',62.97,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-15.75,NULL,NULL,'2022-05-01','2022-12-01',246.75,8),
	 ('xVwGwMaEG1yZydv5VIfEQA==','game 3','uk',22,false,'2022-11-01',33.9,'2022-10-01','2022-12-01','2022-12-01',47.22,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-13.32,NULL,NULL,'2022-05-01','2022-12-01',246.75,8),
	 ('xVwGwMaEG1yZydv5VIfEQA==','game 3','uk',22,false,'2022-12-01',51.45,'2022-11-01','2023-01-01',NULL,33.9,'2022-11-01',51.45,1,NULL,NULL,'2023-01-01',17.55,NULL,NULL,NULL,'2022-05-01','2022-12-01',246.75,8),
	 ('xxq2c4woAI3bLul1xOzwtQ==','game 3','uk',23,false,'2022-12-01',17.49,NULL,'2023-01-01',NULL,NULL,'2022-11-01',17.49,1,17.49,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',17.49,1),
	 ('xZMY1f3dijkAd2lWkkI4Ow==','game 3','uk',21,true,'2022-12-01',24.69,NULL,'2023-01-01',NULL,NULL,'2022-11-01',24.69,1,24.69,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',24.69,1),
	 ('YC2fZQTQXV2UR1/WHDrVqw==','game 3','uk',14,false,'2022-10-01',33.54,NULL,'2022-11-01','2022-11-01',NULL,'2022-09-01',NULL,NULL,33.54,1,NULL,NULL,NULL,NULL,NULL,'2022-10-01','2022-12-01',219.18,3),
	 ('YC2fZQTQXV2UR1/WHDrVqw==','game 3','uk',14,false,'2022-11-01',113.22,'2022-10-01','2022-12-01','2022-12-01',33.54,'2022-10-01',NULL,NULL,NULL,NULL,NULL,79.68,NULL,NULL,NULL,'2022-10-01','2022-12-01',219.18,3),
	 ('YC2fZQTQXV2UR1/WHDrVqw==','game 3','uk',14,false,'2022-12-01',72.42,'2022-11-01','2023-01-01',NULL,113.22,'2022-11-01',72.42,1,NULL,NULL,'2023-01-01',NULL,-40.80,NULL,NULL,'2022-10-01','2022-12-01',219.18,3),
	 ('yFNWN0sYyxkSJ+yLRq1WqA==','game 3','uk',16,false,'2022-09-01',114.27,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,114.27,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',376.26,4);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('yFNWN0sYyxkSJ+yLRq1WqA==','game 3','uk',16,false,'2022-10-01',34.35,'2022-09-01','2022-11-01','2022-11-01',114.27,'2022-09-01',NULL,NULL,NULL,NULL,NULL,NULL,-79.92,NULL,NULL,'2022-09-01','2022-12-01',376.26,4),
	 ('yFNWN0sYyxkSJ+yLRq1WqA==','game 3','uk',16,false,'2022-11-01',133.80,'2022-10-01','2022-12-01','2022-12-01',34.35,'2022-10-01',NULL,NULL,NULL,NULL,NULL,99.45,NULL,NULL,NULL,'2022-09-01','2022-12-01',376.26,4),
	 ('yFNWN0sYyxkSJ+yLRq1WqA==','game 3','uk',16,false,'2022-12-01',93.84,'2022-11-01','2023-01-01',NULL,133.80,'2022-11-01',93.84,1,NULL,NULL,'2023-01-01',NULL,-39.96,NULL,NULL,'2022-09-01','2022-12-01',376.26,4),
	 ('yH7KH2AG/PGgQiNV7uTTGg==','game 3','ru',19,false,'2022-08-01',14.88,NULL,'2022-09-01','2022-10-01',NULL,'2022-07-01',14.88,1,14.88,1,'2022-09-01',NULL,NULL,NULL,NULL,'2022-08-01','2022-10-01',69.57,3),
	 ('yH7KH2AG/PGgQiNV7uTTGg==','game 3','ru',19,false,'2022-10-01',54.69,'2022-08-01','2022-11-01',NULL,14.88,'2022-09-01',54.69,1,NULL,NULL,'2022-11-01',NULL,NULL,54.69,1,'2022-08-01','2022-10-01',69.57,3),
	 ('Yh9mYycPmc8CH9Rbjhu3ZQ==','game 3','uk',28,false,'2022-07-01',14.64,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,14.64,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-09-01',90.15,3),
	 ('Yh9mYycPmc8CH9Rbjhu3ZQ==','game 3','uk',28,false,'2022-08-01',30.39,'2022-07-01','2022-09-01','2022-09-01',14.64,'2022-07-01',NULL,NULL,NULL,NULL,NULL,15.75,NULL,NULL,NULL,'2022-07-01','2022-09-01',90.15,3),
	 ('Yh9mYycPmc8CH9Rbjhu3ZQ==','game 3','uk',28,false,'2022-09-01',45.12,'2022-08-01','2022-10-01',NULL,30.39,'2022-08-01',45.12,1,NULL,NULL,'2022-10-01',14.73,NULL,NULL,NULL,'2022-07-01','2022-09-01',90.15,3),
	 ('ymEApWLjh3I9oLJnWIBHFA==','game 3','uk',19,false,'2022-09-01',33.27,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,33.27,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-12-01',75.06,4),
	 ('ymEApWLjh3I9oLJnWIBHFA==','game 3','uk',19,false,'2022-10-01',17.7,'2022-09-01','2022-11-01','2022-12-01',33.27,'2022-09-01',17.7,1,NULL,NULL,'2022-11-01',NULL,-15.57,NULL,NULL,'2022-09-01','2022-12-01',75.06,4);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('ymEApWLjh3I9oLJnWIBHFA==','game 3','uk',19,false,'2022-12-01',24.09,'2022-10-01','2023-01-01',NULL,17.7,'2022-11-01',24.09,1,NULL,NULL,'2023-01-01',NULL,NULL,24.09,1,'2022-09-01','2022-12-01',75.06,4),
	 ('Y/nf8iBu/UCaNAuIRRjVwA==','game 3','uk',15,false,'2022-03-01',24.27,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,24.27,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-10-01',263.34,8),
	 ('Y/nf8iBu/UCaNAuIRRjVwA==','game 3','uk',15,false,'2022-04-01',20.43,'2022-03-01','2022-05-01','2022-05-01',24.27,'2022-03-01',NULL,NULL,NULL,NULL,NULL,NULL,-3.84,NULL,NULL,'2022-03-01','2022-10-01',263.34,8),
	 ('Y/nf8iBu/UCaNAuIRRjVwA==','game 3','uk',15,false,'2022-05-01',15.33,'2022-04-01','2022-06-01','2022-06-01',20.43,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-5.10,NULL,NULL,'2022-03-01','2022-10-01',263.34,8),
	 ('Y/nf8iBu/UCaNAuIRRjVwA==','game 3','uk',15,false,'2022-06-01',41.13,'2022-05-01','2022-07-01','2022-07-01',15.33,'2022-05-01',NULL,NULL,NULL,NULL,NULL,25.80,NULL,NULL,NULL,'2022-03-01','2022-10-01',263.34,8),
	 ('Y/nf8iBu/UCaNAuIRRjVwA==','game 3','uk',15,false,'2022-07-01',63.63,'2022-06-01','2022-08-01','2022-08-01',41.13,'2022-06-01',NULL,NULL,NULL,NULL,NULL,22.50,NULL,NULL,NULL,'2022-03-01','2022-10-01',263.34,8),
	 ('Y/nf8iBu/UCaNAuIRRjVwA==','game 3','uk',15,false,'2022-08-01',34.86,'2022-07-01','2022-09-01','2022-09-01',63.63,'2022-07-01',NULL,NULL,NULL,NULL,NULL,NULL,-28.77,NULL,NULL,'2022-03-01','2022-10-01',263.34,8),
	 ('Y/nf8iBu/UCaNAuIRRjVwA==','game 3','uk',15,false,'2022-09-01',20.16,'2022-08-01','2022-10-01','2022-10-01',34.86,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-14.70,NULL,NULL,'2022-03-01','2022-10-01',263.34,8),
	 ('Y/nf8iBu/UCaNAuIRRjVwA==','game 3','uk',15,false,'2022-10-01',43.53,'2022-09-01','2022-11-01',NULL,20.16,'2022-09-01',43.53,1,NULL,NULL,'2022-11-01',23.37,NULL,NULL,NULL,'2022-03-01','2022-10-01',263.34,8),
	 ('ytNOQh7e6qNGQNC0T3RBxw==','game 3','ru',26,true,'2022-07-01',14.13,NULL,'2022-08-01','2022-08-01',NULL,'2022-06-01',NULL,NULL,14.13,1,NULL,NULL,NULL,NULL,NULL,'2022-07-01','2022-12-01',179.34,6);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('ytNOQh7e6qNGQNC0T3RBxw==','game 3','ru',26,true,'2022-08-01',40.83,'2022-07-01','2022-09-01','2022-09-01',14.13,'2022-07-01',NULL,NULL,NULL,NULL,NULL,26.70,NULL,NULL,NULL,'2022-07-01','2022-12-01',179.34,6),
	 ('ytNOQh7e6qNGQNC0T3RBxw==','game 3','ru',26,true,'2022-09-01',90.09,'2022-08-01','2022-10-01','2022-10-01',40.83,'2022-08-01',NULL,NULL,NULL,NULL,NULL,49.26,NULL,NULL,NULL,'2022-07-01','2022-12-01',179.34,6),
	 ('ytNOQh7e6qNGQNC0T3RBxw==','game 3','ru',26,true,'2022-10-01',17.82,'2022-09-01','2022-11-01','2022-12-01',90.09,'2022-09-01',17.82,1,NULL,NULL,'2022-11-01',NULL,-72.27,NULL,NULL,'2022-07-01','2022-12-01',179.34,6),
	 ('ytNOQh7e6qNGQNC0T3RBxw==','game 3','ru',26,true,'2022-12-01',16.47,'2022-10-01','2023-01-01',NULL,17.82,'2022-11-01',16.47,1,NULL,NULL,'2023-01-01',NULL,NULL,16.47,1,'2022-07-01','2022-12-01',179.34,6),
	 ('yZ1P1v1eYIbyD5wRy0chGw==','game 3','uk',33,false,'2022-09-01',14.91,NULL,'2022-10-01','2022-10-01',NULL,'2022-08-01',NULL,NULL,14.91,1,NULL,NULL,NULL,NULL,NULL,'2022-09-01','2022-11-01',63.33,3),
	 ('yZ1P1v1eYIbyD5wRy0chGw==','game 3','uk',33,false,'2022-10-01',17.64,'2022-09-01','2022-11-01','2022-11-01',14.91,'2022-09-01',NULL,NULL,NULL,NULL,NULL,2.73,NULL,NULL,NULL,'2022-09-01','2022-11-01',63.33,3),
	 ('yZ1P1v1eYIbyD5wRy0chGw==','game 3','uk',33,false,'2022-11-01',30.78,'2022-10-01','2022-12-01',NULL,17.64,'2022-10-01',30.78,1,NULL,NULL,'2022-12-01',13.14,NULL,NULL,NULL,'2022-09-01','2022-11-01',63.33,3),
	 ('Z7/6qvk8WKH3uR6IMYlCxw==','game 3','uk',30,false,'2022-05-01',12.09,NULL,'2022-06-01','2022-06-01',NULL,'2022-04-01',NULL,NULL,12.09,1,NULL,NULL,NULL,NULL,NULL,'2022-05-01','2022-11-01',100.44,7),
	 ('Z7/6qvk8WKH3uR6IMYlCxw==','game 3','uk',30,false,'2022-06-01',14.43,'2022-05-01','2022-07-01','2022-07-01',12.09,'2022-05-01',NULL,NULL,NULL,NULL,NULL,2.34,NULL,NULL,NULL,'2022-05-01','2022-11-01',100.44,7),
	 ('Z7/6qvk8WKH3uR6IMYlCxw==','game 3','uk',30,false,'2022-07-01',25.20,'2022-06-01','2022-08-01','2022-09-01',14.43,'2022-06-01',25.20,1,NULL,NULL,'2022-08-01',10.77,NULL,NULL,NULL,'2022-05-01','2022-11-01',100.44,7);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('Z7/6qvk8WKH3uR6IMYlCxw==','game 3','uk',30,false,'2022-09-01',29.67,'2022-07-01','2022-10-01','2022-11-01',25.20,'2022-08-01',29.67,1,NULL,NULL,'2022-10-01',NULL,NULL,29.67,1,'2022-05-01','2022-11-01',100.44,7),
	 ('Z7/6qvk8WKH3uR6IMYlCxw==','game 3','uk',30,false,'2022-11-01',19.05,'2022-09-01','2022-12-01',NULL,29.67,'2022-10-01',19.05,1,NULL,NULL,'2022-12-01',NULL,NULL,19.05,1,'2022-05-01','2022-11-01',100.44,7),
	 ('ZeMBdi9hmR0vUv+lyZiypQ==','game 3','uk',22,false,'2022-03-01',25.41,NULL,'2022-04-01',NULL,NULL,'2022-02-01',25.41,1,25.41,1,'2022-04-01',NULL,NULL,NULL,NULL,'2022-03-01','2022-03-01',25.41,1),
	 ('zeu++qOqokuGcT0ghN97bQ==','game 3','ru',34,false,'2022-08-01',59.34,NULL,'2022-09-01','2022-10-01',NULL,'2022-07-01',59.34,1,59.34,1,'2022-09-01',NULL,NULL,NULL,NULL,'2022-08-01','2022-10-01',91.14,3),
	 ('zeu++qOqokuGcT0ghN97bQ==','game 3','ru',34,false,'2022-10-01',31.8,'2022-08-01','2022-11-01',NULL,59.34,'2022-09-01',31.8,1,NULL,NULL,'2022-11-01',NULL,NULL,31.8,1,'2022-08-01','2022-10-01',91.14,3),
	 ('ZgTMXDOYCQOiAw4VI8H7AA==','game 3','uk',25,false,'2022-06-01',14.55,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,14.55,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-12-01',237.99,7),
	 ('ZgTMXDOYCQOiAw4VI8H7AA==','game 3','uk',25,false,'2022-07-01',21.63,'2022-06-01','2022-08-01','2022-08-01',14.55,'2022-06-01',NULL,NULL,NULL,NULL,NULL,7.08,NULL,NULL,NULL,'2022-06-01','2022-12-01',237.99,7),
	 ('ZgTMXDOYCQOiAw4VI8H7AA==','game 3','uk',25,false,'2022-08-01',90.63,'2022-07-01','2022-09-01','2022-09-01',21.63,'2022-07-01',NULL,NULL,NULL,NULL,NULL,69.00,NULL,NULL,NULL,'2022-06-01','2022-12-01',237.99,7),
	 ('ZgTMXDOYCQOiAw4VI8H7AA==','game 3','uk',25,false,'2022-09-01',79.17,'2022-08-01','2022-10-01','2022-11-01',90.63,'2022-08-01',79.17,1,NULL,NULL,'2022-10-01',NULL,-11.46,NULL,NULL,'2022-06-01','2022-12-01',237.99,7),
	 ('ZgTMXDOYCQOiAw4VI8H7AA==','game 3','uk',25,false,'2022-11-01',19.8,'2022-09-01','2022-12-01','2022-12-01',79.17,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,19.8,1,'2022-06-01','2022-12-01',237.99,7);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('ZgTMXDOYCQOiAw4VI8H7AA==','game 3','uk',25,false,'2022-12-01',12.21,'2022-11-01','2023-01-01',NULL,19.8,'2022-11-01',12.21,1,NULL,NULL,'2023-01-01',NULL,-7.59,NULL,NULL,'2022-06-01','2022-12-01',237.99,7),
	 ('ZmjMhgyYl6o8iFq964FEWg==','game 3','ru',17,false,'2022-03-01',54.60,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,54.60,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-12-01',433.83,10),
	 ('ZmjMhgyYl6o8iFq964FEWg==','game 3','ru',17,false,'2022-04-01',56.70,'2022-03-01','2022-05-01','2022-05-01',54.60,'2022-03-01',NULL,NULL,NULL,NULL,NULL,2.10,NULL,NULL,NULL,'2022-03-01','2022-12-01',433.83,10),
	 ('ZmjMhgyYl6o8iFq964FEWg==','game 3','ru',17,false,'2022-05-01',27.0,'2022-04-01','2022-06-01','2022-06-01',56.70,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-29.70,NULL,NULL,'2022-03-01','2022-12-01',433.83,10),
	 ('ZmjMhgyYl6o8iFq964FEWg==','game 3','ru',17,false,'2022-06-01',68.58,'2022-05-01','2022-07-01','2022-07-01',27.0,'2022-05-01',NULL,NULL,NULL,NULL,NULL,41.58,NULL,NULL,NULL,'2022-03-01','2022-12-01',433.83,10),
	 ('ZmjMhgyYl6o8iFq964FEWg==','game 3','ru',17,false,'2022-07-01',18.75,'2022-06-01','2022-08-01','2022-08-01',68.58,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-49.83,NULL,NULL,'2022-03-01','2022-12-01',433.83,10),
	 ('ZmjMhgyYl6o8iFq964FEWg==','game 3','ru',17,false,'2022-08-01',81.84,'2022-07-01','2022-09-01','2022-09-01',18.75,'2022-07-01',NULL,NULL,NULL,NULL,NULL,63.09,NULL,NULL,NULL,'2022-03-01','2022-12-01',433.83,10),
	 ('ZmjMhgyYl6o8iFq964FEWg==','game 3','ru',17,false,'2022-09-01',67.65,'2022-08-01','2022-10-01','2022-10-01',81.84,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-14.19,NULL,NULL,'2022-03-01','2022-12-01',433.83,10),
	 ('ZmjMhgyYl6o8iFq964FEWg==','game 3','ru',17,false,'2022-10-01',41.76,'2022-09-01','2022-11-01','2022-12-01',67.65,'2022-09-01',41.76,1,NULL,NULL,'2022-11-01',NULL,-25.89,NULL,NULL,'2022-03-01','2022-12-01',433.83,10),
	 ('ZmjMhgyYl6o8iFq964FEWg==','game 3','ru',17,false,'2022-12-01',16.95,'2022-10-01','2023-01-01',NULL,41.76,'2022-11-01',16.95,1,NULL,NULL,'2023-01-01',NULL,NULL,16.95,1,'2022-03-01','2022-12-01',433.83,10);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('ZmnZeh2zth0OyQaAzd6eTA==','game 3','uk',41,false,'2022-08-01',13.74,NULL,'2022-09-01',NULL,NULL,'2022-07-01',13.74,1,13.74,1,'2022-09-01',NULL,NULL,NULL,NULL,'2022-08-01','2022-08-01',13.74,1),
	 ('zmZPan/KZoyrIR2r/SvLdA==','game 3','ru',15,false,'2022-05-01',133.14,NULL,'2022-06-01','2022-07-01',NULL,'2022-04-01',133.14,1,133.14,1,'2022-06-01',NULL,NULL,NULL,NULL,'2022-05-01','2022-12-01',590.07,8),
	 ('zmZPan/KZoyrIR2r/SvLdA==','game 3','ru',15,false,'2022-07-01',70.89,'2022-05-01','2022-08-01','2022-08-01',133.14,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,70.89,1,'2022-05-01','2022-12-01',590.07,8),
	 ('zmZPan/KZoyrIR2r/SvLdA==','game 3','ru',15,false,'2022-08-01',74.31,'2022-07-01','2022-09-01','2022-09-01',70.89,'2022-07-01',NULL,NULL,NULL,NULL,NULL,3.42,NULL,NULL,NULL,'2022-05-01','2022-12-01',590.07,8),
	 ('zmZPan/KZoyrIR2r/SvLdA==','game 3','ru',15,false,'2022-09-01',25.08,'2022-08-01','2022-10-01','2022-10-01',74.31,'2022-08-01',NULL,NULL,NULL,NULL,NULL,NULL,-49.23,NULL,NULL,'2022-05-01','2022-12-01',590.07,8),
	 ('zmZPan/KZoyrIR2r/SvLdA==','game 3','ru',15,false,'2022-10-01',56.58,'2022-09-01','2022-11-01','2022-11-01',25.08,'2022-09-01',NULL,NULL,NULL,NULL,NULL,31.50,NULL,NULL,NULL,'2022-05-01','2022-12-01',590.07,8),
	 ('zmZPan/KZoyrIR2r/SvLdA==','game 3','ru',15,false,'2022-11-01',130.02,'2022-10-01','2022-12-01','2022-12-01',56.58,'2022-10-01',NULL,NULL,NULL,NULL,NULL,73.44,NULL,NULL,NULL,'2022-05-01','2022-12-01',590.07,8),
	 ('zmZPan/KZoyrIR2r/SvLdA==','game 3','ru',15,false,'2022-12-01',100.05,'2022-11-01','2023-01-01',NULL,130.02,'2022-11-01',100.05,1,NULL,NULL,'2023-01-01',NULL,-29.97,NULL,NULL,'2022-05-01','2022-12-01',590.07,8),
	 ('zPcHw1fZkSGh7nJeVe2QYw==','game 3','ru',14,true,'2022-11-01',32.16,NULL,'2022-12-01','2022-12-01',NULL,'2022-10-01',NULL,NULL,32.16,1,NULL,NULL,NULL,NULL,NULL,'2022-11-01','2022-12-01',71.82,2),
	 ('zPcHw1fZkSGh7nJeVe2QYw==','game 3','ru',14,true,'2022-12-01',39.66,'2022-11-01','2023-01-01',NULL,32.16,'2022-11-01',39.66,1,NULL,NULL,'2023-01-01',7.50,NULL,NULL,NULL,'2022-11-01','2022-12-01',71.82,2);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('zSepnWFgLH0tQb1s4mxKZQ==','game 3','uk',24,false,'2022-03-01',23.01,NULL,'2022-04-01','2022-04-01',NULL,'2022-02-01',NULL,NULL,23.01,1,NULL,NULL,NULL,NULL,NULL,'2022-03-01','2022-12-01',335.01,10),
	 ('zSepnWFgLH0tQb1s4mxKZQ==','game 3','uk',24,false,'2022-04-01',71.52,'2022-03-01','2022-05-01','2022-05-01',23.01,'2022-03-01',NULL,NULL,NULL,NULL,NULL,48.51,NULL,NULL,NULL,'2022-03-01','2022-12-01',335.01,10),
	 ('zSepnWFgLH0tQb1s4mxKZQ==','game 3','uk',24,false,'2022-05-01',16.05,'2022-04-01','2022-06-01','2022-06-01',71.52,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-55.47,NULL,NULL,'2022-03-01','2022-12-01',335.01,10),
	 ('zSepnWFgLH0tQb1s4mxKZQ==','game 3','uk',24,false,'2022-06-01',25.56,'2022-05-01','2022-07-01','2022-07-01',16.05,'2022-05-01',NULL,NULL,NULL,NULL,NULL,9.51,NULL,NULL,NULL,'2022-03-01','2022-12-01',335.01,10),
	 ('zSepnWFgLH0tQb1s4mxKZQ==','game 3','uk',24,false,'2022-07-01',14.4,'2022-06-01','2022-08-01','2022-08-01',25.56,'2022-06-01',NULL,NULL,NULL,NULL,NULL,NULL,-11.16,NULL,NULL,'2022-03-01','2022-12-01',335.01,10),
	 ('zSepnWFgLH0tQb1s4mxKZQ==','game 3','uk',24,false,'2022-08-01',36.18,'2022-07-01','2022-09-01','2022-09-01',14.4,'2022-07-01',NULL,NULL,NULL,NULL,NULL,21.78,NULL,NULL,NULL,'2022-03-01','2022-12-01',335.01,10),
	 ('zSepnWFgLH0tQb1s4mxKZQ==','game 3','uk',24,false,'2022-09-01',39.87,'2022-08-01','2022-10-01','2022-10-01',36.18,'2022-08-01',NULL,NULL,NULL,NULL,NULL,3.69,NULL,NULL,NULL,'2022-03-01','2022-12-01',335.01,10),
	 ('zSepnWFgLH0tQb1s4mxKZQ==','game 3','uk',24,false,'2022-10-01',48.63,'2022-09-01','2022-11-01','2022-11-01',39.87,'2022-09-01',NULL,NULL,NULL,NULL,NULL,8.76,NULL,NULL,NULL,'2022-03-01','2022-12-01',335.01,10),
	 ('zSepnWFgLH0tQb1s4mxKZQ==','game 3','uk',24,false,'2022-11-01',20.28,'2022-10-01','2022-12-01','2022-12-01',48.63,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,-28.35,NULL,NULL,'2022-03-01','2022-12-01',335.01,10),
	 ('zSepnWFgLH0tQb1s4mxKZQ==','game 3','uk',24,false,'2022-12-01',39.51,'2022-11-01','2023-01-01',NULL,20.28,'2022-11-01',39.51,1,NULL,NULL,'2023-01-01',19.23,NULL,NULL,NULL,'2022-03-01','2022-12-01',335.01,10);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('ztW05pPmN1YloSEDlJoJ3g==','game 3','uk',20,false,'2022-12-01',32.94,NULL,'2023-01-01',NULL,NULL,'2022-11-01',32.94,1,32.94,1,'2023-01-01',NULL,NULL,NULL,NULL,'2022-12-01','2022-12-01',32.94,1),
	 ('ZU1vF9G4TjB+iEZ001MU3g==','game 3','ru',29,false,'2022-06-01',17.22,NULL,'2022-07-01','2022-07-01',NULL,'2022-05-01',NULL,NULL,17.22,1,NULL,NULL,NULL,NULL,NULL,'2022-06-01','2022-12-01',91.32,7),
	 ('ZU1vF9G4TjB+iEZ001MU3g==','game 3','ru',29,false,'2022-07-01',22.2,'2022-06-01','2022-08-01','2022-08-01',17.22,'2022-06-01',NULL,NULL,NULL,NULL,NULL,4.98,NULL,NULL,NULL,'2022-06-01','2022-12-01',91.32,7),
	 ('ZU1vF9G4TjB+iEZ001MU3g==','game 3','ru',29,false,'2022-08-01',23.1,'2022-07-01','2022-09-01','2022-10-01',22.2,'2022-07-01',23.1,1,NULL,NULL,'2022-09-01',0.9,NULL,NULL,NULL,'2022-06-01','2022-12-01',91.32,7),
	 ('ZU1vF9G4TjB+iEZ001MU3g==','game 3','ru',29,false,'2022-10-01',16.11,'2022-08-01','2022-11-01','2022-12-01',23.1,'2022-09-01',16.11,1,NULL,NULL,'2022-11-01',NULL,NULL,16.11,1,'2022-06-01','2022-12-01',91.32,7),
	 ('ZU1vF9G4TjB+iEZ001MU3g==','game 3','ru',29,false,'2022-12-01',12.69,'2022-10-01','2023-01-01',NULL,16.11,'2022-11-01',12.69,1,NULL,NULL,'2023-01-01',NULL,NULL,12.69,1,'2022-06-01','2022-12-01',91.32,7),
	 ('ZxxZ87IcpgSh4lQ/VSIjnA==','game 3','uk',22,false,'2022-04-01',42.18,NULL,'2022-05-01','2022-05-01',NULL,'2022-03-01',NULL,NULL,42.18,1,NULL,NULL,NULL,NULL,NULL,'2022-04-01','2022-12-01',338.40,9),
	 ('ZxxZ87IcpgSh4lQ/VSIjnA==','game 3','uk',22,false,'2022-05-01',38.76,'2022-04-01','2022-06-01','2022-06-01',42.18,'2022-04-01',NULL,NULL,NULL,NULL,NULL,NULL,-3.42,NULL,NULL,'2022-04-01','2022-12-01',338.40,9),
	 ('ZxxZ87IcpgSh4lQ/VSIjnA==','game 3','uk',22,false,'2022-06-01',71.97,'2022-05-01','2022-07-01','2022-07-01',38.76,'2022-05-01',NULL,NULL,NULL,NULL,NULL,33.21,NULL,NULL,NULL,'2022-04-01','2022-12-01',338.40,9),
	 ('ZxxZ87IcpgSh4lQ/VSIjnA==','game 3','uk',22,false,'2022-07-01',71.58,'2022-06-01','2022-08-01','2022-11-01',71.97,'2022-06-01',71.58,1,NULL,NULL,'2022-08-01',NULL,-0.39,NULL,NULL,'2022-04-01','2022-12-01',338.40,9);
INSERT INTO "WITH monthly_payments AS (
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
    ON sm.user_id = gpu.user_id" (user_id,game_name,"language",age,has_older_device_model,payment_month,total_revenue,previous_paid_month,next_calendar_month,next_paid_month,previous_paid_month_revenue,previous_calendar_month,churned_revenue,churned_users,new_mrr,new_paid_users,churn_month,expansion_revenue,contraction_revenue,back_from_churn_revenue,back_from_churn_users,first_payment_month,last_payment_month,user_lifetime_revenue,user_lifetime_months) VALUES
	 ('ZxxZ87IcpgSh4lQ/VSIjnA==','game 3','uk',22,false,'2022-11-01',63.21,'2022-07-01','2022-12-01','2022-12-01',71.58,'2022-10-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,63.21,1,'2022-04-01','2022-12-01',338.40,9),
	 ('ZxxZ87IcpgSh4lQ/VSIjnA==','game 3','uk',22,false,'2022-12-01',50.70,'2022-11-01','2023-01-01',NULL,63.21,'2022-11-01',50.70,1,NULL,NULL,'2023-01-01',NULL,-12.51,NULL,NULL,'2022-04-01','2022-12-01',338.40,9);
