CREATE TABLE marks(
id INT,
student_name VARCHAR(50),
score INT
);

INSERT INTO marks VALUES
(1,'Sanjiv',80),
(2,'Arun',70),
(3,'Nithin',90);

SELECT COUNT(*) FROM marks;

SELECT SUM(score) FROM marks;

SELECT AVG(score) FROM marks;

SELECT MIN(score) FROM marks;

SELECT MAX(score) FROM marks;