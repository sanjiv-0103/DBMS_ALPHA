CREATE TABLE orders_denormalized (
    order_id INT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(50),
    product_id INT,
    product_name VARCHAR(50),
    quantity INT,
    price DECIMAL(10,2)
);
INSERT INTO orders_denormalized
VALUES
(1,101,'Sanjiv',201,'Laptop',1,55000),
(2,101,'Sanjiv',202,'Mouse',2,800),
(3,102,'Rahul',203,'Keyboard',1,1500);
SELECT * FROM orders_denormalized;