
# materialized views



CREATE STREAM readings (
    sensor VARCHAR KEY,
    area VARCHAR,
    reading INT
) WITH (
    kafka_topic = 'readings',
    partitions = 2,
    value_format = 'json'
);





INSERT INTO readings (sensor, area, reading) VALUES ('sensor-1', 'wheel', 45);
INSERT INTO readings (sensor, area, reading) VALUES ('sensor-2', 'motor', 41);
INSERT INTO readings (sensor, area, reading) VALUES ('sensor-1', 'wheel', 92);
INSERT INTO readings (sensor, area, reading) VALUES ('sensor-2', 'engine', 13);
INSERT INTO readings (sensor, area, reading) VALUES ('sensor-2', 'engine', 90);

INSERT INTO readings (sensor, area, reading) VALUES ('sensor-4', 'motor', 95);
INSERT INTO readings (sensor, area, reading) VALUES ('sensor-3', 'engine', 67);
INSERT INTO readings (sensor, area, reading) VALUES ('sensor-3', 'wheel', 52);
INSERT INTO readings (sensor, area, reading) VALUES ('sensor-4', 'engine', 55);
INSERT INTO readings (sensor, area, reading) VALUES ('sensor-3', 'engine', 37);



-- process from the beginning of each stream
SET 'auto.offset.reset' = 'earliest';

CREATE TABLE avg_readings AS
    SELECT sensor,
           AVG(reading) AS avg
    FROM readings
    GROUP BY sensor
    EMIT CHANGES;

The most common way to create a materialized view is GROUP BY.
 ksqlDB repartitions your streams to ensure that all rows that have the same key reside on the same partition. This happens invisibility through a second, automatic stage of computation:

Many materialized views compound data over time, aggregating data into one value that reflects history. Sometimes, though, you might want to create a materialized view that is just the last value for each key.

CREATE TABLE latest_readings AS
    SELECT sensor,
           LATEST_BY_OFFSET(area) AS area,
           LATEST_BY_OFFSET(reading) AS last
    FROM readings
    GROUP BY sensor
    EMIT CHANGES;
    

https://www.confluent.io/blog/how-real-time-materialized-views-work-with-ksqldb/
https://www.youtube.com/watch?v=WFO4CYUoIG4
