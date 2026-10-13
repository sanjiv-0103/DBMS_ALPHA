CREATE TABLE departments(
department_id INT PRIMARY KEY,
department_name VARCHAR(50)
);

CREATE TABLE students_rel(
student_id INT PRIMARY KEY,
student_name VARCHAR(50),
department_id INT,
FOREIGN KEY(department_id) REFERENCES departments(department_id)
);