


## Initialize the project with the  customer & items table  a stream
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (customerid STRING PRIMARY KEY, customername STRING)
    WITH (KAFKA_TOPIC='customers',
          VALUE_FORMAT='json',
          PARTITIONS=6);

DROP TABLE IF EXISTS items;
CREATE TABLE items (itemid STRING PRIMARY KEY, itemname STRING)
    WITH (KAFKA_TOPIC='items',
          VALUE_FORMAT='json',
          PARTITIONS=6);

# create a Stream of orders;
CREATE STREAM orders (orderid STRING KEY, customerid STRING, itemid STRING, purchasedate STRING)
    WITH (KAFKA_TOPIC='orders',
          VALUE_FORMAT='json',
          PARTITIONS=6);

### First some customer data:

INSERT INTO customers VALUES ('1', 'Adrian Garcia');
INSERT INTO customers VALUES ('2', 'Robert Miller');
INSERT INTO customers VALUES ('3', 'Brian Smith');


### And some items available in our store:

INSERT INTO items VALUES ('101', 'Television 60-in');
INSERT INTO items VALUES ('102', 'Laptop 15-in');
INSERT INTO items VALUES ('103', 'Speakers');


### Then we insert some orders. Each order contains a unique order id, a customer id, an item id, and a purchase date:

INSERT INTO orders VALUES ('abc123', '1', '101', '2020-05-01');
INSERT INTO orders VALUES ('abc345', '1', '102', '2020-05-01');
INSERT INTO orders VALUES ('abc678', '2', '101', '2020-05-01');
INSERT INTO orders VALUES ('abc987', '3', '101', '2020-05-03');
INSERT INTO orders VALUES ('xyz123', '2', '103', '2020-05-03');
INSERT INTO orders VALUES ('xyz987', '2', '102', '2020-05-05');


## 
SET 'auto.offset.reset' = 'earliest';

# Join one stream with 2 tables
DROP STREAM IF EXISTS orders_enriched;
CREATE OR REPLACE STREAM orders_enriched AS
  SELECT customers.customerid AS customerid, customers.customername AS customername,
         orders.orderid, orders.purchasedate,
         items.itemid, items.itemname, items_french.itemname_french
  FROM orders
  LEFT JOIN customers on orders.customerid = customers.customerid
  LEFT JOIN items on orders.itemid = items.itemid; 


# and now 4 Way join ( one stream with 3 tables)

CREATE TABLE items_french (itemid STRING PRIMARY KEY, itemname_french STRING)
    WITH (KAFKA_TOPIC='items_french',
          VALUE_FORMAT='json',
          PARTITIONS=6);


INSERT INTO items_french VALUES ('101', 'Télévision 60-in');
INSERT INTO items_french VALUES ('102', 'Portable 15-in');
INSERT INTO items_french VALUES ('103', 'Haut-parleurs');


# 4 way LEFT join Query
CREATE OR REPLACE STREAM orders_enriched_bilingual AS
  SELECT customers.customerid AS customerid, customers.customername AS customername,
         orders.orderid, orders.purchasedate,
         items.itemid, items.itemname, items_french.itemname_french
  FROM orders
  LEFT JOIN customers on orders.customerid = customers.customerid
  LEFT JOIN items on orders.itemid = items.itemid
  LEFT JOIN items_french on orders.itemid = items_french.itemid;



# Clean up
### DROP TABLE [IF EXISTS] table_name [DELETE TOPIC];
DROP TABLE IF EXISTS ITEMS DELETE TOPIC;
DROP TABLE IF EXISTS ITEMS_FRENCH DELETE TOPIC;
DROP TABLE IF EXISTS CUSTOMERS DELETE TOPIC;
DROP STREAM IF EXISTS ORDERS DELETE TOPIC;

# References :
https://developer.confluent.io/tutorials/multi-joins/ksql.html

