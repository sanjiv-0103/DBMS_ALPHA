CREATE TABLE students(student_id INT, name VARCHAR(50), dept_id INT);
CREATE TABLE departments(dept_id INT,dept_name VARCHAR(50));

INSERT INTO students VALUES(1,'Sanjiv',101),(2,'Rahul',102),(3,'Anu',103);
INSERT INTO departments VALUES(101,'CSE'),(102,'ECE'),(104,'MECH');

-- INNER JOIN #only shows matching rows

SELECT students.name, departments.dept_name FROM students
INNER JOIN departments ON students.dept_id = departments.dept_id;

-- LEFT JOIN #shows all students and matching dept

SELECT students.name,departments.dept_name FROM students
LEFT JOIN departments ON students.dept_id=departments.dept_id;

-- RIGHT JOIN #shows all depts and matching students

SELECT students.name,departments.dept_name FROM students
RIGHT JOIN departments ON students.dept_id=departments.dept_id;

-- FULL OUTER JOIN #shows all rows from both tables

SELECT students.name, departments.dept_name FROM students
FULL OUTER JOIN departments ON students.dept_id=departments.dept_id;