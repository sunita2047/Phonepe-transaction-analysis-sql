create database phonepe_project;
use phonepe_project;

CREATE TABLE users_stage (
    user_id VARCHAR(50),
    name VARCHAR(100),
    age VARCHAR(10),
    join_date VARCHAR(20)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/all_users.csv'
INTO TABLE users_stage
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
CREATE TABLE users (
    user_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    join_date DATE
);
INSERT INTO users (user_id, name, age, join_date)
SELECT 
    user_id,
    name,
    NULLIF(age,'') AS age,
    STR_TO_DATE(join_date,'%m/%d/%Y')
FROM users_stage
WHERE user_id IS NOT NULL AND user_id <> '';
SELECT COUNT(*) FROM users;
SELECT * FROM users LIMIT 10;
SELECT 
    SUM(CASE WHEN user_id IS NULL OR user_id='' THEN 1 ELSE 0 END) AS missing_ids,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS missing_age
FROM users;
select min(age),max(age) from users;

CREATE TABLE transactions_stage (
    transaction_id VARCHAR(50),
    amount VARCHAR(20),
    user_id VARCHAR(20),
    service VARCHAR(50),
    service_type VARCHAR(50),
    payment_status VARCHAR(30),
    reason VARCHAR(100),
    date VARCHAR(20)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/all_transactions.csv'
INTO TABLE transactions_stage
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
CREATE TABLE all_transactions (
    transaction_id VARCHAR(30) PRIMARY KEY,
    amount DECIMAL(10,2),
    user_id VARCHAR(20),
    service VARCHAR(50),
    service_type VARCHAR(50),
    payment_status VARCHAR(30),
    reason VARCHAR(100),
    date DATE
);
INSERT INTO all_transactions
SELECT 
    transaction_id,
    amount,
    user_id,
    service,
    service_type,
    payment_status,
    reason,
    STR_TO_DATE(date,'%m/%d/%Y')
FROM transactions_stage;
-- check null values
SELECT 
    SUM(user_id IS NULL OR user_id='') AS null_user_id,
    SUM(name IS NULL OR name='') AS null_name,
    SUM(age IS NULL) AS null_age,
    SUM(join_date IS NULL) AS null_join_date
FROM users;
SELECT 
    SUM(transaction_id IS NULL OR transaction_id='') AS null_txn_id,
    SUM(user_id IS NULL OR user_id='') AS null_user_id,
    SUM(amount IS NULL) AS null_amount,
    SUM(date IS NULL) AS null_date,
    SUM(service IS NULL OR service='') AS null_service,
    SUM(payment_status IS NULL OR payment_status='') AS null_status,
    SUM(reason IS NULL OR reason='') AS null_reason
FROM all_transactions;

-- KPI CALCULATIONS
select count(*)from users; -- total users
select count(*) from all_transactions; -- total transx
select sum(amount) as total_revenue from all_transactions where payment_status='Successful'; -- total revenue 
select count(distinct user_id)as unique_users from all_transactions; -- unique users
select round(avg(amount),2) as avg_amount from all_transactions; -- avg amount
select max(amount) as highest_transx ,min(amount) as lowest_transx from all_transactions; -- highest and lowest amount
select service,count(*) as tsx_count from all_transactions group by service order by tsx_count desc; -- transaction by service
select service,sum(amount) as revenue from all_transactions group by service order by revenue desc; -- revenue by service
select payment_status,count(*) as tsx_count from all_transactions group by payment_status; -- payment status distribution
select reason,count(*) as failures from all_transactions where payment_status <>'Successful' group by reason order by failures desc; -- failure reasons
select round(100*sum(payment_status<>'Successful')/count(*),2) from all_transactions; -- failure rate

create index idx_user_id on users(user_id);
create index idx_user_id on all_transactions(user_id);

create table transaction_sample_100k as select * from all_transactions limit 100000;
select count(*) from transaction_sample_100k;
create index idx_user_id on transaction_sample_100k(user_id);
create index idx_date on transaction_sample_100k(date);
create index idx_service on transaction_sample_100k(service);
create index idx_status on transaction_sample_100k(payment_status);

-- time analysis with all_transactions
select date_format(date,'%Y-%M')month,sum(amount) as monthly_revenue from all_transactions  group by month; -- monthly revenue
select date_format(date,'%Y-%M')month,count(*) as  monthly_transactions from all_transactions  group by month; -- monthly transactions
select date,sum(amount) from all_transactions  group by date; -- daily revenue
select dayname(date),sum(amount) from all_transactions  group by 1; -- weekday total revenue
select dayname(date),count(*) from all_transactions  group by 1; -- weekday total transactions
select date_format(date,'%Y-%M')month,sum(amount) from all_transactions  where payment_status='Successful' group by month order by sum(amount) desc limit 1; -- highest revenue month with successful payments
select date_format(date,'%Y-%M')month,sum(amount) from all_transactions  where payment_status='Successful' group by month order by sum(amount) asc limit 1; -- lowest revenue month with successful payments

-- service analysis WITH ALL TRANSACTIONS
select service,count(*) from all_transactions group by service; -- transactions by service
select count(*) from all_transactions;
select service,sum(amount) from all_transactions group by service order by sum(amount) desc ; -- revenue by service
select service,count(*) from all_transactions group by service ; -- transaction by service
select service,count(*) from all_transactions group by service order by count(*) desc limit 1 ; -- top service
select service,count(*) from all_transactions group by service order by count(*) asc limit 2 ; -- least used service
select service,round(avg(amount),2) from all_transactions group by service; -- avg amount by service
select service_type,count(*) from all_transactions group by service_type; -- service type distribution 
select service,count(*) as failures from all_transactions where payment_status<>'Successful' group by service; -- service based failures

-- join analysis with users + all_transactions
select u.age,sum(t.amount) as total_revenue from users u join all_transactions t on u.user_id=t.user_id group by u.age order by total_revenue desc; -- total revenue by age
select u.user_id,u.name,sum(t.amount) as total_spent from users u join all_transactions t on u.user_id=t.user_id group by u.user_id,u.name order by total_spent desc limit 5; -- top 5 users by spendings
select u.user_id,u.name,count(*) from users u join all_transactions t on u.user_id=t.user_id group by u.user_id,u.name order by count(*) desc limit 5; -- top 5 users by transactions
select 
	case 
			when u.age<25 then 'young' 
            when u.age between 25 and 40 then 'adult' 
            else 'senior' 
		end as age_group,sum(t.amount) as revenue from users u join all_transactions t on u.user_id=t.user_id group by age_group; -- revenue by age group
select date_format(join_date,'%Y')year from users group by year;
select year(u.join_date) as join_year,sum(t.amount) as revenue from users u join all_transactions t on u.user_id=t.user_id group by join_year order by join_year; -- revenue by join year
select u.age,t.service,round(avg(t.amount),2) as avg_revenue from users u join all_transactions t on u.user_id=t.user_id group by u.age,t.service order by avg_revenue desc; -- avg revenue by age and service

-- subqueries with all_transactions
select * from users where user_id=(select user_id from all_transactions group by user_id order by sum(amount) desc limit 1); -- highest spending user
 SELECT service,
       SUM(amount) AS revenue
FROM all_transactions
GROUP BY service
HAVING SUM(amount) >
(
    SELECT AVG(revenue)
    FROM (
        SELECT SUM(amount) AS revenue
        FROM all_transactions
        GROUP BY service
    ) x
); -- services above avg revenue
SELECT user_id,
       COUNT(*) AS txn_count
FROM all_transactions
GROUP BY user_id
HAVING COUNT(*) >
(
    SELECT AVG(cnt)
    FROM (
        SELECT COUNT(*) AS cnt
        FROM all_transactions
        GROUP BY user_id
        
    ) x
); -- users with more transactions than AVG
SELECT service,
       revenue
FROM (
    SELECT service,
           SUM(amount) AS revenue
    FROM all_transactions
    GROUP BY service
) x
WHERE revenue =
(
    SELECT MAX(revenue)
    FROM (
        SELECT SUM(amount) AS revenue
        FROM all_transactions
        GROUP BY service
    ) y
); -- SERVICE WITH HIGHEST REVENUE
SELECT service,
       COUNT(*) AS failures
FROM all_transactions
WHERE payment_status <> 'success'
GROUP BY service
HAVING COUNT(*) >
(
    SELECT AVG(failure_count)
    FROM (
        SELECT COUNT(*) AS failure_count
        FROM all_transactions
        WHERE payment_status <> 'success'
        GROUP BY service
    ) x
); -- SERVICE WITH FAILURE COUNT ABOVE AVG
SELECT service,
       COUNT(DISTINCT user_id) AS users_count
FROM all_transactions
GROUP BY service
HAVING COUNT(DISTINCT user_id) >
(
    SELECT AVG(users_count)
    FROM (
        SELECT COUNT(DISTINCT user_id) AS users_count
        FROM all_transactions
        GROUP BY service
    ) x
); -- SEVICES USED BY MORE THAN AVG NO. OF USERS

-- CTE QUERIES WITH ALL_TRANSACTIONS
WITH user_spend AS (
    SELECT 
        u.user_id,u.name,
        u.age,
        SUM(t.amount) AS total_spent
    FROM users u
    JOIN all_transactions t
        ON u.user_id = t.user_id
    GROUP BY u.user_id, u.age
),
age_avg AS (
    SELECT
        age,
        AVG(total_spent) AS avg_age_spend
    FROM user_spend
    GROUP BY age
)
SELECT
    us.user_id,
    us.name,
    us.age,
    us.total_spent,
    aa.avg_age_spend
FROM user_spend us
JOIN age_avg aa
    ON us.age = aa.age
WHERE us.total_spent > aa.avg_age_spend
ORDER BY us.total_spent DESC; 

-- WINDOW FUNCTIONS 
select 
	service,sum(amount)as revenue,
    rank() over(
	order by sum(amount)desc ) as revenue_rank from all_transactions group by service; -- rank services by revenue
    
    select 
		user_id,
        sum(amount) as Total_spent,
        Row_number()over(order by sum(amount) desc)
        as row_num 
        from all_transactions 
        group by user_id; -- row number by top users
SELECT
    date,
    SUM(amount) AS daily_revenue,
    SUM(SUM(amount))
    OVER(ORDER BY date) AS running_revenue
FROM all_transactions
GROUP BY date; -- running revenue

WITH monthly AS (
    SELECT
        DATE_FORMAT(date,'%Y-%m') AS month,
        SUM(amount) AS revenue
    FROM all_transactions
    GROUP BY month
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER(ORDER BY month) AS previous_month,
    revenue - LAG(revenue) OVER(ORDER BY month) AS growth
FROM monthly; -- revenue growth(lag())
WITH monthly AS (
    SELECT
        DATE_FORMAT(date,'%Y-%m') AS month,
        SUM(amount) AS revenue
    FROM all_transactions
    GROUP BY month
)
SELECT
    month,
    revenue,
    LEAD(revenue) OVER(ORDER BY month) AS next_month_revenue
FROM monthly; -- monthly revenue + next month revenue(lead())

