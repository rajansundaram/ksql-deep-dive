# Join based on multiple keys


CREATE STREAM my_other_stream (
    key_col STRUCT<k1 STRING, k2 BOOLEAN> KEY, v1 STRING, v2 INT 
) WITH (KAFKA_TOPIC='my_topic', FORMAT='JSON');


a join on a condition such as stream1.key_col = my_other_stream.key_col.



https://www.confluent.io/blog/ksqldb-0-15-reads-more-message-keys-supports-more-data-types/#multiple-key-columns

