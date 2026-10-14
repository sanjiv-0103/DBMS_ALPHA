CREATE TABLE student_course (
    student_id INT,
    course_id INT,
    teacher_name VARCHAR(50)
);
--BCNF means the column deciding another column shd be a key.
CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    teacher_name VARCHAR(50)
);
CREATE TABLE enrollments (
    student_id INT,
    course_id INT
);
INSERT INTO courses VALUES(101,'Mr Ravi'),(102,'Ms Priya');
INSERT INTO enrollments VALUES (1,101),(2,101),(1,102);
SELECT * FROM courses;
SELECT * FROM enrollments;