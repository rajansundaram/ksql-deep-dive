# Multi column keys 



## (Option 1) Creating a multi column key in the STREAM definition 
# Note KEY is mentioned twice for customerid & itemid

DROP stream if EXISTS orders_multi_key;
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


## (Option 2) Creating a multicolumn key using PARTITION BY 

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


##  (Option 3) Creating a multicolumn key using PARTITION BY & STRUCT

# starting with the same old orders stream
DROP STREAM IF EXISTS orders ;
CREATE OR REPLACE STREAM orders (orderid STRING , customerid STRING KEY, itemid STRING KEY, purchasedate STRING)
    WITH (KAFKA_TOPIC='orders',
          VALUE_FORMAT='json', KEY_FORMAT='json',
          PARTITIONS=6);	

INSERT INTO orders VALUES ('abc123', '1', '101', '2020-05-01');
INSERT INTO orders VALUES ('abc345', '1', '102', '2020-05-01');
INSERT INTO orders VALUES ('abc678', '2', '101', '2020-05-01');


### TIP : REKEY to a STRUCT USING PARTITION BY
DROP  STREAM IF EXISTS ORDERS_MULTIKEY_STRUCT;
CREATE OR REPLACE STREAM ORDERS_MULTIKEY_STRUCT AS
SELECT ORDERID , STRUCT(CUSTOMERID:=ORDERS.CUSTOMERID, ITEMID:=ORDERS.ITEMID) as myKey , PURCHASEDATE  
FROM
ORDERS  
PARTITION BY STRUCT(CUSTOMERID:=ORDERS.CUSTOMERID, ITEMID:=ORDERS.ITEMID) EMIT CHANGES;

NOTE :
Multikey will remove that element  from value, the If you want to keep them a copy in the value, you need to add the corresponding columns twice to SELECT using AS_VALUE to tell ksqlDB to store one copy in the value:
SELECT newKey, AS_VALUE(newKey) AS newKeyInValue FROM ... PARTITION BY newKey;

## You cannot repartition a TABLE (Strem only) -- a TABLE is always partitions by its primary key.
# So creating a item with a struct	
DROP STREAM IF EXISTS items_multi_key_struct ;

CREATE TABLE items_multi_key_struct (myKey STRUCT<itemid STRING, customerid STRING> PRIMARY KEY, itemname STRING)
    WITH (KAFKA_TOPIC='items_multi_key_struct',
          VALUE_FORMAT='json',KEY_FORMAT='json',
          PARTITIONS=6);

INSERT INTO items_multi_key_struct VALUES (STRUCT(itemid:='101',customerid:='1'),'Television 60-in'); 








# works

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
INSERT INTO items_multi_key_struct VALUES (STRUCT(itemid:='101',customerid:='1'),'Television 60-in'); 




https://www.confluent.io/blog/ksqldb-0-15-reads-more-message-keys-supports-more-data-types/#multiple-key-columns

https://confluent.slack.com/archives/C337JP2F8/p1657162738222339
