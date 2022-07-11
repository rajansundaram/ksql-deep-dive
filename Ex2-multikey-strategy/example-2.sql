# Multi column keys 

Multikey will remove that element  from value, the If you want to keep them a copy in the value, you need to add the corresponding columns twice to SELECT using AS_VALUE to tell ksqlDB to store one copy in the value:
SELECT newKey, AS_VALUE(newKey) AS newKeyInValue FROM ... PARTITION BY newKey;


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


CREATE TABLE items_multi_key_struct (myKey STRUCT< customerid STRING, itemid STRING> PRIMARY KEY, itemname STRING)
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


### REKEY to a STRUCT USING PARTITION BY
DROP  STREAM IF EXISTS ORDERS_MULTIKEY_STRUCT;
CREATE OR REPLACE STREAM ORDERS_MULTIKEY_STRUCT AS
SELECT ORDERID , STRUCT(CUSTOMERID:=ORDERS.CUSTOMERID, ITEMID:=ORDERS.ITEMID) as myKey , PURCHASEDATE  
FROM
ORDERS  
PARTITION BY STRUCT(CUSTOMERID:=ORDERS.CUSTOMERID, ITEMID:=ORDERS.ITEMID) EMIT CHANGES;

## You cannot repartition a TABLE -- a TABLE is always partitions by its primary key.
CREATE TABLE items_multi_key_struct (myKey STRUCT<itemid STRING, customerid STRING> PRIMARY KEY, itemname STRING)
    WITH (KAFKA_TOPIC='items_multi_key_struct',
          VALUE_FORMAT='json',KEY_FORMAT='json',
          PARTITIONS=6);

INSERT INTO items_multi_key_struct VALUES (STRUCT(itemid:='101',customerid:='1'),'Television 60-in'); 



DROP STREAM IF EXISTS orders ;
CREATE OR REPLACE STREAM orders (orderid STRING KEY, customerid STRING , itemid STRING , purchasedate STRING)
    WITH (KAFKA_TOPIC='orders',
          VALUE_FORMAT='json', KEY_FORMAT='json',
          PARTITIONS=6);	

INSERT INTO items_multi_key_struct VALUES (STRUCT(itemid:='101',customerid:='1'),'Television 60-in'); 
DROP STREAM IF EXISTS orders_multikey_struct ;





# Optional
INSERT INTO items_multi_key_struct VALUES (STRUCT(itemid:='101',customerid:='1'),'Television 60-in'); 


DROP TABLE IF EXISTS items ;
CREATE OR REPLACE TABLE items (itemid STRING PRIMARY KEY, customerid STRING PRIMARY KEY, itemname STRING)
    WITH (KAFKA_TOPIC='items',
          VALUE_FORMAT='json', KEY_FORMAT='json',
          PARTITIONS=6);

INSERT INTO items VALUES ('101', '1', 'Television 60-in');
INSERT INTO items VALUES ('102','2', 'Laptop 15-in');

DROP STREAM IF EXISTS  ITEMS_MULTIKEY_STRUCT;
CREATE OR REPLACE STREAM ITEMS_MULTIKEY_STRUCT AS
SELECT ORDERID , STRUCT( CUSTOMERID:=ORDERS.CUSTOMERID, ITEMID:=ORDERS.ITEMID ) as myKey , PURCHASEDATE  
FROM
ORDERS  
PARTITION BY STRUCT(CUSTOMERID:=ORDERS.CUSTOMERID, ITEMID:=ORDERS.ITEMID) EMIT CHANGES;


INSERT INTO ITEMS VALUES ('101', '1', 'Television 60-in');




# worked

CREATE OR REPLACE STREAM orders_enriched_multikey AS
  SELECT 
       *
        FROM ORDERS_MULTIKEY_STRUCT orders
    INNER JOIN items_multi_key_struct items on orders.myKey = items.myKey ;

CREATE OR REPLACE STREAM orders_enriched_multikey AS
  SELECT 
         orders.orderid, orders.purchasedate,
         items.itemid, items.itemname
  FROM ORDERS_MULTIKEY_STRUCT orders
    INNER JOIN items_multi_key_struct items on orders.myKey = items.myKey ;

INSERT INTO orders VALUES ('abc123', '1', '101', '2020-05-01');
INSERT INTO items_multi_key_struct VALUES (STRUCT(customerid:='1', itemid:='101'),'Television 60-in'); 




https://www.confluent.io/blog/ksqldb-0-15-reads-more-message-keys-supports-more-data-types/#multiple-key-columns

https://confluent.slack.com/archives/C337JP2F8/p1657162738222339
