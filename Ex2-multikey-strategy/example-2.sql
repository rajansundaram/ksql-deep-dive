# Multi column keys 


## Creating a multi column key in the definition (Option 1)

drop stream orders_multi_key;

DROP stream orders_multi_key;
CREATE STREAM orders_multi_key (orderid STRING , customerid STRING KEY, itemid STRING KEY, purchasedate STRING)
    WITH (KAFKA_TOPIC='orders_multi_key',
          VALUE_FORMAT='json',KEY_FORMAT='json',
          PARTITIONS=6);
          


DROP stream  items_multi_key;
CREATE TABLE items_multi_key (itemid STRING PRIMARY KEY,customerid STRING PRIMARY KEY, itemname STRING)
    WITH (KAFKA_TOPIC='items_multi_key',
          VALUE_FORMAT='json',KEY_FORMAT='json',
          PARTITIONS=6);


CREATE TABLE items_multi_key_struct (MY_KEY STRUCT<itemid STRING, customerid STRING> PRIMARY KEY, itemname STRING)
    WITH (KAFKA_TOPIC='items_multi_key_struct',
          VALUE_FORMAT='json',KEY_FORMAT='json',
          PARTITIONS=6);


INSERT INTO items_multi_key_struct VALUES (STRUCT(itemid:='101',customerid:='1'),'Television 60-in'); 
select * from items_multi_key emit changes;


INSERT INTO orders_multi_key VALUES ('abc123', '1', '101', '2020-05-01');
select * from orders_multi_key emit changes;


## Creating a multicolumn key using PARTITION BY ( Option 2)

DROP STREAM IF EXISTS orders ;
CREATE OR REPLACE STREAM orders (orderid STRING KEY, customerid STRING , itemid STRING , purchasedate STRING)
    WITH (KAFKA_TOPIC='orders',
          VALUE_FORMAT='json', KEY_FORMAT='json',
          PARTITIONS=6);	

INSERT INTO orders VALUES ('abc123', '1', '101', '2020-05-01');
INSERT INTO orders VALUES ('abc345', '1', '102', '2020-05-01');
INSERT INTO orders VALUES ('abc678', '2', '101', '2020-05-01');

### NOW LETS CHANGE AND HAVE MULTIPLE KEYS
DROP STREAM IF EXISTS orders_multikey ;
CREATE OR REPLACE STREAM orders_multikey  AS
    SELECT orderid, customerid, itemid , purchasedate
    FROM ORDERS
    PARTITION BY customerid, itemid;

NOTE : MULTIPLE KEYS CAN BE ADDED USING THIS SYNTAX, HOWEVER DATA CANNOT BE JOINED WITH MULTIPLE KEYS AND MULTIPLE KEYS SHOULD BE MOVED TO A STRUCT AS SHOWN IN THE NEXT EXAMPLE.


## Creating a multicolumn key using PARTITION BY & STRUCT ( Option 3)

DROP STREAM IF EXISTS orders ;
CREATE OR REPLACE STREAM orders (orderid STRING , customerid STRING KEY, itemid STRING KEY, purchasedate STRING)
    WITH (KAFKA_TOPIC='orders',
          VALUE_FORMAT='json', KEY_FORMAT='json',
          PARTITIONS=6);	

INSERT INTO orders VALUES ('abc123', '1', '101', '2020-05-01');
INSERT INTO orders VALUES ('abc345', '1', '102', '2020-05-01');
INSERT INTO orders VALUES ('abc678', '2', '101', '2020-05-01');

DROP STREAM IF EXISTS orders_multikey_struct ;
CREATE OR REPLACE STREAM orders_multikey_struct  AS
    SELECT orderid, customerid, itemid , purchasedate
    FROM ORDERS
    PARTITION BY STRUCT (customerid, itemid);

DROP TABLE IF EXISTS items ;
CREATE OR REPLACE TABLE items (itemid STRING PRIMARY KEY, customerid STRING PRIMARY KEY, itemname STRING)
    WITH (KAFKA_TOPIC='items',
          VALUE_FORMAT='json', KEY_FORMAT='json',
          PARTITIONS=6);

INSERT INTO items VALUES ('101', '1', 'Television 60-in');
INSERT INTO items VALUES ('102','2', 'Laptop 15-in');



CREATE OR REPLACE STREAM orders_enriched_multikey AS
  SELECT 
         orders.orderid, orders.purchasedate,
         items.itemid, items.itemname
  FROM orders
  LEFT JOIN customers on orders.customerid = customers.customerid 
  LEFT JOIN items on orders.itemid = items.itemid 



https://www.confluent.io/blog/ksqldb-0-15-reads-more-message-keys-supports-more-data-types/#multiple-key-columns

https://confluent.slack.com/archives/C337JP2F8/p1657162738222339
