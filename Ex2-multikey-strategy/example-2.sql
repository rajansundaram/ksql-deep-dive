# Multi column keys 

CREATE STREAM my_other_stream (
    key_col STRUCT<k1 STRING, k2 BOOLEAN> KEY, v1 STRING, v2 INT 
) WITH (KAFKA_TOPIC='my_topic', FORMAT='JSON');


a join on a condition such as stream1.key_col = my_other_stream.key_col.


## Creating a multi column key (Option 1)

drop stream orders_multi_key;

DROP stream orders_multi_key;
CREATE STREAM orders_multi_key (orderid STRING , customerid STRING KEY, itemid STRING KEY, purchasedate STRING)
    WITH (KAFKA_TOPIC='orders_multi_key',
          VALUE_FORMAT='json',KEY_FORMAT='json',
          PARTITIONS=6);
          


DROP stream items_multi_key;
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


## Creating a multicolumn key ( Option 2)



## Creating a multicolumn key ( Option 3)



https://www.confluent.io/blog/ksqldb-0-15-reads-more-message-keys-supports-more-data-types/#multiple-key-columns

https://confluent.slack.com/archives/C337JP2F8/p1657162738222339
