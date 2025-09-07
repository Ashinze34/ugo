SELECT * FROM attendance
SELECT * FROM department
SELECT * FROM employee
SELECT * FROM performance
SELECT * FROM salary
SELECT * FROM turnover

--Employee Retention Analysis

-- Who are the top 5 highest serving employees?
SELECT 
	e.employee_id,
	e.first_name,
	e.last_name,
	e.job_title,
	e.hire_date, 
	AGE(COALESCE(t.turnover_date, CURRENT_DATE), e.hire_date) 
		AS service_duration
FROM 
	employee e
LEFT JOIN 
	turnover t 
		ON t.employee_id = e.employee_id
WHERE 
	t.employee_id IS NULL
ORDER BY 
	service_duration DESC
LIMIT 5;

-- What is the turnover rate for each department?
SELECT 
	d.department_id, 
	d.department_name,
COUNT
	(t.employee_id) * 100/ COUNT(e.employee_id) 
		AS turnover_rate -- The turnover rate is in %
FROM 
	department d
JOIN 
	employee e 
		ON e.department_id = d.department_id
LEFT JOIN 
	turnover t 
		ON t.employee_id = e.employee_id
GROUP BY 
	d.department_id, d.department_name
ORDER BY
	turnover_rate DESC;

--Which employees are at risk of leaving based on their performance?
SELECT 
	e.employee_id,
	e.first_name,
	e.last_name,
	e.job_title,
	ROUND(AVG(p.performance_score),2) 
		AS Avg_Performance_Score --The average preformance score is 4.09, BenchMark for employees 4.0
FROM 
	employee e
JOIN 
	performance p 
		ON p.employee_id = e.employee_id
GROUP BY 
	e.employee_id,e.first_name,e.last_name,e.job_title
HAVING 
	AVG(p.performance_score) < 4.0	
ORDER BY Avg_Performance_Score DESC;


-- What are the main reasons employees are leaving the company?
SELECT 
	t.reason_for_leaving, 
	COUNT(*) AS reason_count
FROM 
	turnover t
GROUP BY
	reason_for_leaving
ORDER BY
	reason_count DESC;

--Performance Analysis
--How many employees has left the company?
SELECT 
	COUNT (*)
		AS Total_exits
FROM turnover;

--How many employees have a performance score of 5.0 / below 3.5?
---(This shows the the total numnber of employees with performance score of 5 and below 3.5)
SELECT 
    SUM(CASE WHEN p.performance_score = 5.0 
		THEN 1 ELSE 0 END) AS score_5_count,
    SUM(CASE WHEN p.performance_score < 3.5 
		THEN 1 ELSE 0 END) AS below_3_5_count
FROM 
    performance p; 

---(This shows employees would have performance scores of 5 and below 3.5)
SELECT 
    p.employee_id,
    SUM(CASE WHEN p.performance_score = 5.0
		THEN 1 ELSE 0 END) AS score_5_count,
    SUM(CASE WHEN p.performance_score < 3.5 
		THEN 1 ELSE 0 END) AS below_3_5_count
FROM 
    performance p
GROUP BY 
    p.employee_id
HAVING 
    SUM(CASE WHEN p.performance_score = 5.0 
		THEN 1 ELSE 0 END) > 0
    OR SUM(CASE WHEN p.performance_score < 3.5 
		THEN 1 ELSE 0 END) > 0;

---(This shows the employees with both a performance score of 5 and below 3.5)
---Depending on how you want to look at it 
SELECT 
    p.employee_id,
    COUNT(*) AS flagged_scores
FROM 
    performance p
WHERE 
    p.performance_score = 5.0
    	OR p.performance_score < 3.5
GROUP BY 
    p.employee_id;

--Which department has the most employees with a performance of 5.0 / below 3.5?
SELECT d.department_name,
	SUM(CASE WHEN p.performance_score = 5.0 THEN 1 ELSE 0 END) 
		AS performance_of_5,
	SUM(CASE WHEN p.performance_score < 3.5 THEN 1 ELSE 0 END) 
		AS performance_below_3_5
FROM department d
JOIN performance p 
	ON d.department_id = p.department_id
GROUP BY d.department_name
ORDER BY performance_of_5 DESC, performance_below_3_5 DESC;


-- What is the average performance score by department?
SELECT 
	d.department_name,
	ROUND(AVG(p.performance_score),2)
		AS Avg_Performance
FROM 
	performance p
JOIN  
	department d 
		ON p.department_id = d.department_id
GROUP BY 
	d.department_name
ORDER BY
	Avg_Performance DESC;


--Salary Analysis
--What is the total salary expense for the company?
SELECT 
	SUM(s.salary_amount) 
		AS Salary_Expenses
FROM salary s

-- What is the average salary by job title?
SELECT 
	e.job_title,
	ROUND(AVG(s.salary_amount),2)
		AS Avg_salary_job_title
FROM 
	salary s
JOIN 
	employee e 
		ON e.employee_id = s.employee_id
GROUP BY 
	e.job_title
ORDER BY 
	Avg_salary_job_title DESC;

-- How many employees earn above 80,000?
SELECT 
    COUNT(DISTINCT s.employee_id)
		AS employees_above_80k
FROM 
    salary s
WHERE 
    s.salary_amount >= 80000;

--How does performance correlate with salary across departments?
SELECT 
    d.department_name,
    ROUND(AVG(p.performance_score), 2) 
		AS avg_performance,
    ROUND(AVG(s.salary_amount), 2)
		AS avg_salary
FROM 
    employee e
JOIN 
    performance p 
		ON e.employee_id = p.employee_id
JOIN 
    salary s 
		ON e.employee_id = s.employee_id
JOIN 
    department d 
		ON e.department_id = d.department_id
GROUP BY 
    d.department_name
ORDER BY 
    d.department_name DESC;











