CREATE TABLE students(
student_id INT PRIMARY KEY,
student_name VARCHAR(50)
);

CREATE TABLE courses(
course_id INT PRIMARY KEY,
course_name VARCHAR(50)
);

CREATE TABLE enrollments(
student_id INT,
course_id INT,
PRIMARY KEY(student_id,course_id)
);