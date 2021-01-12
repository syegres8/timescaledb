-- This file and its contents are licensed under the Timescale License.
-- Please see the included NOTICE for copyright information and
-- LICENSE-TIMESCALE for a copy of the license.

SET client_min_messages TO ERROR;

SET ROLE :ROLE_DEFAULT_PERM_USER;

-- create normal hypertable with dropped columns, each chunk will have different attribute numbers
CREATE TABLE metrics(filler_1 int, filler_2 int, filler_3 int, time timestamptz NOT NULL, device_id int, v0 int, v1 int, v2 float, v3 float);
CREATE INDEX ON metrics(time DESC);
CREATE INDEX ON metrics(device_id,time DESC);
SELECT create_hypertable('metrics','time',create_default_indexes:=false);

ALTER TABLE metrics DROP COLUMN filler_1;
INSERT INTO metrics(time,device_id,v0,v1,v2,v3) SELECT time, device_id, device_id+1,  device_id + 2, device_id + 0.5, NULL FROM generate_series('2000-01-01 0:00:00+0'::timestamptz,'2000-01-05 23:55:00+0','2m') gtime(time), generate_series(1,5,1) gdevice(device_id);
ALTER TABLE metrics DROP COLUMN filler_2;
INSERT INTO metrics(time,device_id,v0,v1,v2,v3) SELECT time, device_id, device_id-1, device_id + 2, device_id + 0.5, NULL FROM generate_series('2000-01-06 0:00:00+0'::timestamptz,'2000-01-12 23:55:00+0','2m') gtime(time), generate_series(1,5,1) gdevice(device_id);
ALTER TABLE metrics DROP COLUMN filler_3;
INSERT INTO metrics(time,device_id,v0,v1,v2,v3) SELECT time, device_id, device_id, device_id + 2, device_id + 0.5, NULL FROM generate_series('2000-01-13 0:00:00+0'::timestamptz,'2000-01-19 23:55:00+0','2m') gtime(time), generate_series(1,5,1) gdevice(device_id);
ANALYZE metrics;

-- create identical hypertable with space partitioning
CREATE TABLE metrics_space(filler_1 int, filler_2 int, filler_3 int, time timestamptz NOT NULL, device_id int, v0 int, v1 int, v2 float, v3 float);
CREATE INDEX ON metrics_space(time);
CREATE INDEX ON metrics_space(device_id,time);
SELECT create_hypertable('metrics_space','time','device_id',3,create_default_indexes:=false);

ALTER TABLE metrics_space DROP COLUMN filler_1;
INSERT INTO metrics_space(time,device_id,v0,v1,v2,v3) SELECT time, device_id, device_id+1, device_id + 2, device_id + 0.5, NULL FROM generate_series('2000-01-01 0:00:00+0'::timestamptz,'2000-01-05 23:55:00+0','2m') gtime(time), generate_series(1,5,1) gdevice(device_id);
ALTER TABLE metrics_space DROP COLUMN filler_2;
INSERT INTO metrics_space(time,device_id,v0,v1,v2,v3) SELECT time, device_id, device_id+1, device_id + 2, device_id + 0.5, NULL FROM generate_series('2000-01-06 0:00:00+0'::timestamptz,'2000-01-12 23:55:00+0','2m') gtime(time), generate_series(1,5,1) gdevice(device_id);
ALTER TABLE metrics_space DROP COLUMN filler_3;
INSERT INTO metrics_space(time,device_id,v0,v1,v2,v3) SELECT time, device_id, device_id+1, device_id + 2, device_id + 0.5, NULL FROM generate_series('2000-01-13 0:00:00+0'::timestamptz,'2000-01-19 23:55:00+0','2m') gtime(time), generate_series(1,5,1) gdevice(device_id);
ANALYZE metrics_space;


-- create hypertable with compression
CREATE TABLE metrics_compressed(filler_1 int, filler_2 int, filler_3 int, time timestamptz NOT NULL, device_id int, v0 int, v1 int, v2 float, v3 float);
CREATE INDEX ON metrics_compressed(time);
CREATE INDEX ON metrics_compressed(device_id,time);
SELECT create_hypertable('metrics_compressed','time',create_default_indexes:=false);

ALTER TABLE metrics_compressed DROP COLUMN filler_1;
INSERT INTO metrics_compressed(time,device_id,v0,v1,v2,v3) SELECT time, device_id, device_id+1,  device_id + 2, device_id + 0.5, NULL FROM generate_series('2000-01-01 0:00:00+0'::timestamptz,'2000-01-05 23:55:00+0','2m') gtime(time), generate_series(1,5,1) gdevice(device_id);
ALTER TABLE metrics_compressed DROP COLUMN filler_2;
INSERT INTO metrics_compressed(time,device_id,v0,v1,v2,v3) SELECT time, device_id, device_id-1, device_id + 2, device_id + 0.5, NULL FROM generate_series('2000-01-06 0:00:00+0'::timestamptz,'2000-01-12 23:55:00+0','2m') gtime(time), generate_series(1,5,1) gdevice(device_id);
ALTER TABLE metrics_compressed DROP COLUMN filler_3;
INSERT INTO metrics_compressed(time,device_id,v0,v1,v2,v3) SELECT time, device_id, device_id, device_id + 2, device_id + 0.5, NULL FROM generate_series('2000-01-13 0:00:00+0'::timestamptz,'2000-01-19 23:55:00+0','2m') gtime(time), generate_series(1,5,1) gdevice(device_id);
ANALYZE metrics_compressed;

-- compress chunks
ALTER TABLE metrics_compressed SET (timescaledb.compress, timescaledb.compress_orderby='time DESC', timescaledb.compress_segmentby='device_id');
SELECT compress_chunk(c.schema_name|| '.' || c.table_name)
FROM _timescaledb_catalog.chunk c, _timescaledb_catalog.hypertable ht where c.hypertable_id = ht.id and ht.table_name = 'metrics_compressed' and c.compressed_chunk_id IS NULL
ORDER BY c.table_name DESC;

-- create hypertable with space partitioning and compression
CREATE TABLE metrics_space_compressed(filler_1 int, filler_2 int, filler_3 int, time timestamptz NOT NULL, device_id int, v0 int, v1 int, v2 float, v3 float);
CREATE INDEX ON metrics_space_compressed(time);
CREATE INDEX ON metrics_space_compressed(device_id,time);
SELECT create_hypertable('metrics_space_compressed','time','device_id',3,create_default_indexes:=false);

ALTER TABLE metrics_space_compressed DROP COLUMN filler_1;
INSERT INTO metrics_space_compressed(time,device_id,v0,v1,v2,v3) SELECT time, device_id, device_id+1, device_id + 2, device_id + 0.5, NULL FROM generate_series('2000-01-01 0:00:00+0'::timestamptz,'2000-01-05 23:55:00+0','2m') gtime(time), generate_series(1,5,1) gdevice(device_id);
ALTER TABLE metrics_space_compressed DROP COLUMN filler_2;
INSERT INTO metrics_space_compressed(time,device_id,v0,v1,v2,v3) SELECT time, device_id, device_id+1, device_id + 2, device_id + 0.5, NULL FROM generate_series('2000-01-06 0:00:00+0'::timestamptz,'2000-01-12 23:55:00+0','2m') gtime(time), generate_series(1,5,1) gdevice(device_id);
ALTER TABLE metrics_space_compressed DROP COLUMN filler_3;
INSERT INTO metrics_space_compressed(time,device_id,v0,v1,v2,v3) SELECT time, device_id, device_id+1, device_id + 2, device_id + 0.5, NULL FROM generate_series('2000-01-13 0:00:00+0'::timestamptz,'2000-01-19 23:55:00+0','2m') gtime(time), generate_series(1,5,1) gdevice(device_id);
ANALYZE metrics_space_compressed;

-- compress chunks
ALTER TABLE metrics_space_compressed SET (timescaledb.compress, timescaledb.compress_orderby='time DESC', timescaledb.compress_segmentby='device_id');
SELECT compress_chunk(c.schema_name|| '.' || c.table_name)
FROM _timescaledb_catalog.chunk c, _timescaledb_catalog.hypertable ht where c.hypertable_id = ht.id and ht.table_name = 'metrics_space_compressed' and c.compressed_chunk_id IS NULL
ORDER BY c.table_name DESC;

RESET ROLE;
-- Add data nodes
SELECT * FROM add_data_node('data_node_1', host => 'localhost', database => 'data_node_1');
SELECT * FROM add_data_node('data_node_2', host => 'localhost', database => 'data_node_2');
SELECT * FROM add_data_node('data_node_3', host => 'localhost', database => 'data_node_3');
GRANT USAGE ON FOREIGN SERVER data_node_1, data_node_2, data_node_3 TO PUBLIC;

SET ROLE :ROLE_DEFAULT_PERM_USER;

CREATE TABLE metrics_dist(filler_1 int, filler_2 int, filler_3 int, time timestamptz NOT NULL, device_id int, v0 int, v1 int, v2 float, v3 float);
SELECT create_distributed_hypertable('metrics_dist','time','device_id',3);

ALTER TABLE metrics_dist DROP COLUMN filler_1;
INSERT INTO metrics_dist(time,device_id,v0,v1,v2,v3) SELECT time, device_id, device_id+1, device_id + 2, device_id + 0.5, NULL FROM generate_series('2000-01-01 0:00:00+0'::timestamptz,'2000-01-05 23:55:00+0','2m') gtime(time), generate_series(1,5,1) gdevice(device_id);
ALTER TABLE metrics_dist DROP COLUMN filler_2;
INSERT INTO metrics_dist(time,device_id,v0,v1,v2,v3) SELECT time, device_id, device_id+1, device_id + 2, device_id + 0.5, NULL FROM generate_series('2000-01-06 0:00:00+0'::timestamptz,'2000-01-12 23:55:00+0','2m') gtime(time), generate_series(1,5,1) gdevice(device_id);
ALTER TABLE metrics_dist DROP COLUMN filler_3;
INSERT INTO metrics_dist(time,device_id,v0,v1,v2,v3) SELECT time, device_id, device_id+1, device_id + 2, device_id + 0.5, NULL FROM generate_series('2000-01-13 0:00:00+0'::timestamptz,'2000-01-19 23:55:00+0','2m') gtime(time), generate_series(1,5,1) gdevice(device_id);
ANALYZE metrics_dist;

-- Tables for gapfill and distributed gapfill tests

CREATE TABLE gapfill_plan_test(time timestamptz NOT NULL, value float);
SELECT create_hypertable('gapfill_plan_test','time',chunk_time_interval=>'4 weeks'::interval);
INSERT INTO gapfill_plan_test SELECT generate_series('2018-01-01'::timestamptz,'2018-04-01'::timestamptz,'1m'::interval), 1.0;

CREATE TABLE metrics_int(
    time int NOT NULL,
    device_id int,
    sensor_id int,
    value float);
INSERT INTO metrics_int VALUES
    (-100,1,1,0.0),
    (-100,1,2,-100.0),
    (0,1,1,5.0),
    (5,1,2,10.0),
    (100,1,1,0.0),
    (100,1,2,-100.0);

CREATE TABLE devices(device_id INT, name TEXT);
INSERT INTO devices VALUES (1,'Device 1'),(2,'Device 2'),(3,'Device 3');

CREATE TABLE sensors(sensor_id INT, name TEXT);
INSERT INTO sensors VALUES (1,'Sensor 1'),(2,'Sensor 2'),(3,'Sensor 3');

CREATE TABLE insert_test(id INT);
INSERT INTO insert_test SELECT time_bucket_gapfill(1,time,1,5) FROM (VALUES (1),(2)) v(time) GROUP BY 1 ORDER BY 1;

CREATE TABLE metrics_tstz(time timestamptz, device_id INT, v1 float, v2 int);
SELECT create_hypertable('metrics_tstz','time');
INSERT INTO metrics_tstz VALUES
    (timestamptz '2018-01-01 05:00:00 PST', 1, 0.5, 10),
    (timestamptz '2018-01-01 05:00:00 PST', 2, 0.7, 20),
    (timestamptz '2018-01-01 05:00:00 PST', 3, 0.9, 30),
    (timestamptz '2018-01-01 07:00:00 PST', 1, 0.0, 0),
    (timestamptz '2018-01-01 07:00:00 PST', 2, 1.4, 40),
    (timestamptz '2018-01-01 07:00:00 PST', 3, 0.9, 30)
;

CREATE TABLE conditions(
    time timestamptz NOT NULL, 
    device int, 
    value float
);
SELECT * FROM create_hypertable('conditions', 'time');
INSERT INTO conditions VALUES
    ('2017-01-01 06:01', 1, 1.2),
    ('2017-01-01 09:11', 3, 4.3),
    ('2017-01-01 08:01', 1, 7.3),
    ('2017-01-02 08:01', 2, 0.23),
    ('2018-07-02 08:01', 87, 0.0),
    ('2018-07-01 06:01', 13, 3.1),
    ('2018-07-01 09:11', 90, 10303.12),
    ('2018-07-01 08:01', 29, 64);

CREATE TABLE conditions_dist(
    time timestamptz NOT NULL, 
    device int, 
    value float
);
SELECT * FROM create_distributed_hypertable('conditions_dist', 'time', 'device', 3);
INSERT INTO conditions_dist VALUES
    ('2017-01-01 06:01', 1, 1.2),
    ('2017-01-01 09:11', 3, 4.3),
    ('2017-01-01 08:01', 1, 7.3),
    ('2017-01-02 08:01', 2, 0.23),
    ('2018-07-02 08:01', 87, 0.0),
    ('2018-07-01 06:01', 13, 3.1),
    ('2018-07-01 09:11', 90, 10303.12),
    ('2018-07-01 08:01', 29, 64);

CREATE TABLE metrics_int_dist(
    time int NOT NULL,
    device_id int,
    sensor_id int,
    value float);
SELECT create_distributed_hypertable('metrics_int_dist','time','device_id',chunk_time_interval => 50);
INSERT INTO metrics_int_dist VALUES
    (-100,1,1,0.0),
    (-100,1,2,-100.0),
    (0,1,1,5.0),
    (5,1,2,10.0),
    (100,1,1,0.0),
    (100,1,2,-100.0);

CREATE TABLE conditions_dist1(
    time timestamptz NOT NULL, 
    device int, 
    value float
);
SELECT * FROM create_distributed_hypertable('conditions_dist1', 'time', 'device', 1,
    data_nodes => '{"data_node_1"}');
INSERT INTO conditions_dist1 VALUES
    ('2017-01-01 06:01', 1, 1.2),
    ('2017-01-01 09:11', 3, 4.3),
    ('2017-01-01 08:01', 1, 7.3),
    ('2017-01-02 08:01', 2, 0.23),
    ('2018-07-02 08:01', 87, 0.0),
    ('2018-07-01 06:01', 13, 3.1),
    ('2018-07-01 09:11', 90, 10303.12),
    ('2018-07-01 08:01', 29, 64);

CREATE TABLE metrics_int_dist1(
    time int NOT NULL,
    device_id int,
    sensor_id int,
    value float);
SELECT create_distributed_hypertable('metrics_int_dist1', 'time', 'device_id', chunk_time_interval => 50,
    data_nodes => '{"data_node_1"}');
INSERT INTO metrics_int_dist1 VALUES
    (-100,1,1,0.0),
    (-100,1,2,-100.0),
    (0,1,1,5.0),
    (5,1,2,10.0),
    (100,1,1,0.0),
    (100,1,2,-100.0);
