#creating database
CREATE DATABASE interview_practise;
USE interview_practise;

#creating tables
CREATE TABLE employee_sales (
emp_id INT,
emp_name VARCHAR(50),
department VARCHAR(30),
sale_month DATE,
sales_amount INT);

#insering data
INSERT INTO employee_sales VALUES
(101,'Keerthana','Data','2026-01-01',5000),
(101,'Keerthana','Data','2026-02-01',7000),
(101,'Keerthana','Data','2026-03-01',8000),

(102,'Rahul','Data','2026-01-01',5000),
(102,'Rahul','Data','2026-02-01',6000),
(102,'Rahul','Data','2026-03-01',9000),

(103,'Priya','Analytics','2026-01-01',4000),
(103,'Priya','Analytics','2026-02-01',5000),
(103,'Priya','Analytics','2026-03-01',7000),

(104,'Amit','Analytics','2026-01-01',4000),
(104,'Amit','Analytics','2026-02-01',7000),
(104,'Amit','Analytics','2026-03-01',7000),

(105,'Neha','Cloud','2026-01-01',8000),
(105,'Neha','Cloud','2026-02-01',10000),
(105,'Neha','Cloud','2026-03-01',12000);

#1. Display all records
SELECT * FROM employee_sales;

#Generate row numbers based on sales amount.
SELECT *, ROW_NUMBER() OVER(ORDER BY sales_amount DESC) AS row_num
FROM employee_sales;
-- ROW_NUMBER() assigns a unique sequential interger to each row starting from 1.

#Find rank
SELECT *, RANK() OVER(ORDER BY sales_amount DESC) AS sales_rank
FROM employee_sales;
-- RANK() assigns same rank if there is a tie and skips number.

#Find Dense rank
SELECT *, DENSE_RANK() OVER(ORDER BY sales_amount DESC) AS dense_sales_rank
FROM employee_sales;

#Find difference between row number, rank and dense rank.
SELECT *,
ROW_NUMBER() OVER(ORDER BY sales_amount DESC) AS row_num,
RANK() OVER(ORDER BY sales_amount DESC) AS sales_rank,
DENSE_RANK() OVER(ORDER BY sales_amount DESC) AS dense_sales_rank
FROM employee_sales;

#Rank employees within department
SELECT emp_name,department,sales_amount,
RANK() OVER(PARTITION BY department
ORDER BY sales_amount DESC
) AS emp_rank
FROM employee_sales;
-- Think of PARTITION BY department as: 'Separate the data into departments first, 
-- then rank employees inside each department.'

# Top performer in each department.
SELECT * FROM 
(
SELECT emp_name,department,
RANK() OVER(PARTITION BY department
ORDER BY sales_amount DESC) AS rank_col
FROM employee_sales
) AS t1
WHERE rank_col = 1;	
-- nested query (subquery) : SQL does not allow you to filter directly on a window function result
-- in the WHERE clause.

# Second highest sales
SELECT * FROM
(
SELECT emp_name, sales_amount, DENSE_RANK() OVER(ORDER BY sales_amount DESC) AS t_rank
FROM employee_sales) as t1
WHERE t_rank = 2;

#Running total of sales
SELECT emp_id, emp_name,sales_amount,
SUM(sales_amount) OVER(PARTITION BY emp_id
ORDER BY sale_month) AS running_total
FROM employee_sales;

#Find top 3 employees by sales
SELECT *
FROM (
    SELECT emp_name,
           SUM(sales_amount) AS total_sales,
           DENSE_RANK() OVER (ORDER BY SUM(sales_amount) DESC) rnk
    FROM employee_sales
    GROUP BY emp_name
) t
WHERE rnk <= 3;

#Find employees having same rank.
SELECT emp_name, 
SUM(sales_amount) AS total_sales,
DENSE_RANK() OVER(ORDER BY SUM(sales_amount) DESC) AS rnk
FROM employee_sales
GROUP BY emp_name;

#Highest sales employee in each department.
SELECT * FROM
(
SELECT emp_name, department, SUM(sales_amount) AS total_sales,
ROW_NUMBER() OVER(PARTITION BY department
ORDER BY SUM(sales_amount) DESC) AS rnk
FROM employee_sales
GROUP BY emp_name, department
) AS t1
WHERE rnk = 1;

#Second Highest Employee in Each Department
SELECT * FROM
(
SELECT emp_name,department, SUM(sales_amount) AS total_sales,
DENSE_RANK() OVER(PARTITION BY department
ORDER BY SUM(sales_amount) DESC) AS rnk
FROM employee_sales
GROUP BY emp_name, department
) AS t1
WHERE rnk = 2;

#Running total department wise
SELECT department, sale_month, sales_amount, 
SUM(sales_amount) OVER( PARTITION BY department
ORDER BY sale_month)  AS cumulative_sales
FROM employee_sales;

#Difference between current and previous sale
SELECT emp_name,sales_amount, 
sales_amount - LAG(sales_amount) OVER(
PARTITION BY emp_name
ORDER BY sales_amount DESC) AS difference
FROM employee_sales;
#LAG() - helps to access previous row
#LEAD () - helps to access next row

#Find Month With Highest Sale Per Employee
SELECT * FROM
(
SELECT emp_name,sale_month, sales_amount, 
ROW_NUMBER() OVER(PARTITION BY emp_name
ORDER BY sales_amount DESC) AS rnk
FROM employee_sales) AS t1
WHERE rnk = 1;

# Find consecutive sales
SELECT emp_name, sale_month, sales_amount,
LAG(sales_amount) OVER(PARTITION BY emp_name
ORDER BY sale_month) AS consecutive_sales
FROM employee_sales; 

# Follow up question - Return only records where sales_amount > prev_sales from previous question
SELECT * FROM(
SELECT emp_name, sale_month, sales_amount,
LAG(sales_amount) OVER(PARTITION BY emp_name
ORDER BY sale_month) AS consecutive_sales
FROM employee_sales) AS t1
WHERE sales_amount > consecutive_sales; 

# Find Employee Contributing More Than Department Average
SELECT * FROM
(
SELECT emp_name,department, sales_amount,
AVG(sales_amount) OVER(PARTITION BY department) AS avg_sales
FROM employee_sales
) AS t1
WHERE sales_amount > avg_sales;

# Running Total Reset Every Employee
SELECT emp_name, sale_month, sales_amount, 
SUM(sales_amount) OVER(PARTITION BY emp_name ORDER BY sale_month) AS running_total
FROM employee_sales;

# Find Last Sale Record of Every Employee
SELECT * FROM 
(
SELECT emp_name,sale_month, sales_amount,
ROW_NUMBER() OVER(PARTITION BY emp_name ORDER BY sale_month DESC) AS rnk
FROM employee_sales
) AS t1
WHERE rnk = 1;

# Find First Sale Record of Every Employee
SELECT * FROM
(
SELECT emp_name,sale_month,sales_amount,
ROW_NUMBER() OVER(PARTITION BY emp_name ORDER BY sale_month) AS rnk
FROM employee_sales
) AS t1
WHERE rnk = 1;

# Month-over-Month Growth %
SELECT emp_name, sale_month, sales_amount,
ROUND(
		(
        sales_amount - LAG(sales_amount)
		OVER(PARTITION BY emp_name
		ORDER BY sale_month)
        )*100.0
		/
        LAG(sales_amount)
        OVER(PARTITION BY emp_name
        ORDER BY sale_month)
        ,2
) AS growth_percent
FROM employee_sales;

# Find Nth Highest Sale (3rd Highest)
SELECT * FROM (
SELECT *, DENSE_RANK() OVER(ORDER BY sales_amount DESC) AS sales_rank
FROM employee_sales ) t1
WHERE sales_rank = 3;

# Find Employees Above Overall Average Sales
SELECT emp_name, SUM(sales_amount) AS total_sales
FROM employee_sales
GROUP BY emp_name
HAVING SUM(sales_amount) > 
(
	SELECT AVG(total_sales)
    FROM
    ( SELECT SUM(sales_amount) AS total_sales
    FROM employee_sales
    GROUP BY emp_name
    ) t
);
