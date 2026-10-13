CREATE TABLE students_filter(
id INT,
name VARCHAR(50),
age INT,
marks INT
);

INSERT INTO students_filter VALUES
(1,'Sanjiv',20,85),
(2,'Arun',21,70),
(3,'Nithin',20,90),
(4,'Rahul',22,65);

SELECT * FROM students_filter
WHERE marks>70;

SELECT * FROM students_filter
ORDER BY marks DESC;

SELECT * FROM students_filter
LIMIT 2;