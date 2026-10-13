CREATE TABLE students_1nf(
student_id INT,
student_name VARCHAR(50),
course VARCHAR(50)
);

INSERT INTO students_1nf VALUES
(1,'Sanjiv','DBMS'),
(1,'Sanjiv','Python');

SELECT * FROM students_1nf;