CREATE TABLE employees(
id INT,
name VARCHAR(50),
department VARCHAR(50),
salary INT
);

INSERT INTO employees VALUES
(1,'Sanjiv','IT',50000),
(2,'Arun','IT',45000),
(3,'Nithin','HR',40000),
(4,'Rahul','HR',35000);

SELECT department,COUNT(*)
FROM employees
GROUP BY department;

SELECT department,AVG(salary)
FROM employees
GROUP BY department;

SELECT department,AVG(salary)
FROM employees
GROUP BY department
HAVING AVG(salary)>40000;