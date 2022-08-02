# Foriegn keys

CREATE TABLE orders (
     id INT PRIMARY KEY,
     user_id INT,
     value INT
   ) WITH (
     KAFKA_TOPIC = 'my-orders-topic', 
     VALUE_FORMAT = 'JSON',
     PARTITIONS = 2
   );

CREATE TABLE users (
     u_id INT PRIMARY KEY,
     name VARCHAR,
     last_name VARCHAR
   ) WITH (
     KAFKA_TOPIC = 'my-users-topic', 
     VALUE_FORMAT = 'JSON',
     PARTITIONS = 3
   );

CREATE TABLE orders_with_users AS
SELECT * FROM orders JOIN users ON user_id = u_id
EMIT CHANGES;

INSERT INTO orders (id, user_id, value) VALUES (1, 1, 100);
INSERT INTO users (u_id, name, last_name) VALUES (1, 'John', 'Smith');
