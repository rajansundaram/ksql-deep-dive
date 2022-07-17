SET 'auto.offset.reset' = 'earliest';



DROP STREAM IF EXISTS items_multi_key_struct ;

CREATE TABLE items_multi_key_struct (myKey STRUCT<itemid STRING, customerid STRING> PRIMARY KEY, itemname STRING)
    WITH (KAFKA_TOPIC='items_multi_key_struct',
          VALUE_FORMAT='json',KEY_FORMAT='json',
          PARTITIONS=6);

INSERT INTO items_multi_key_struct VALUES (STRUCT(itemid:='101',customerid:='1'),'Television 60-in'); 


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







Here's an example code(not part of the lab) stream-stream-stream join that combines orders, payments and shipments streams. The resulting shipped_orders stream contains all orders paid within 1 hour of when the order was placed, and shipped within 2 hours of the payment being received.


   CREATE STREAM shipped_orders AS
     SELECT 
        o.id as orderId,
        o.itemid as itemId,
        s.id as shipmentId,
        p.id as paymentId
     FROM orders o
        INNER JOIN payments p WITHIN 1 HOURS ON p.id = o.id
        INNER JOIN shipments s WITHIN 2 HOURS ON s.id = o.id;