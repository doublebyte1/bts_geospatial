![QGIS](et4h.jpeg)

# Introduction to Big Spatial Queries
In this tutorial, we instantiate an Hadoop cluster on AWS, and add the [spatial extension from ESRI](http://esri.github.io/gis-tools-for-hadoop/). We present two use cases, both involving loading large datasets from csv files, using hive. The first use case, is a point in polygon aggregation, for aggregating earthquakes in counties. The second use case is a spatial bining of taxi trips.

- [Launch cluster](#launch-cluster)
- [Prepare environment](#prepare-environment)
- [Query data on hive](#query-data-on-hive)
- [Run a hive script](#run-a-hive-script)
- [Aggregate csv data](#aggregate-csv-data)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>


## Launch cluster

https://eu-west-3.console.aws.amazon.com/console/home?region=eu-west-3#

EMR: create Hadoop cluster

* Core Hadoop: Hadoop 2.8.5 with Ganglia 3.7.2, Hive 2.3.4, Hue 4.3.0, Mahout 0.13.0, Pig 0.17.0, and Tez 0.9.1
* m5.xlarge (3: 1 master and 2 slaves)
* Disk size: Root device EBS volume size: 50 GB
* Keys
* Security

Follow the ssh instructions to access the cluster

## Prepare environment

Install git:

```bash
yum update
yum install git
```

Clone gis tools for Hadoop:
```bash
git clone https://github.com/Esri/gis-tools-for-hadoop.git
```
https://github.com/Esri/spatial-framework-for-hadoop/wiki

Look at the data:
```bash
cat gis-tools-for-hadoop/samples/data/
```

Create folder to hold data:
```bash
hadoop fs -mkdir earthquake-demo
```

Copy files to HDFS:
```bash
hadoop fs -put gis-tools-for-hadoop/samples/data/counties-data earthquake-demo
hadoop fs -put gis-tools-for-hadoop/samples/data/earthquake-data earthquake-demo
```

Check that it worked:
```bash
hadoop fs -ls earthquake-demo
```

## Query data on hive

Enter hive:

```bash
hive
```

Add the required external libraries and create temporary functions for the geometry api calls:

```sql
add jar
  ${env:HOME}/gis-tools-for-hadoop/samples/lib/esri-geometry-api-2.0.0.jar
  ${env:HOME}/gis-tools-for-hadoop/samples/lib/spatial-sdk-hive-2.0.0.jar
  ${env:HOME}/gis-tools-for-hadoop/samples/lib/spatial-sdk-json-2.0.0.jar;
```

```sql
create temporary function ST_Point as 'com.esri.hadoop.hive.ST_Point';
create temporary function ST_Contains as 'com.esri.hadoop.hive.ST_Contains';
```

Complete UDF documentation:

https://github.com/Esri/spatial-framework-for-hadoop/wiki/UDF-Documentation

Drop the tables named counties and earthquakes, if they exist:

```sql
drop table earthquakes;
drop table counties;
```

Define a schema for the earthquake data. The earthquake data is in CSV (comma-separated values) format, which is natively supported by Hive.

```sql
CREATE TABLE earthquakes (earthquake_date STRING, latitude DOUBLE, longitude DOUBLE, depth DOUBLE, magnitude DOUBLE,
    magtype string, mbstations string, gap string, distance string, rms string, source string, eventid string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;
```

Define a schema for the California counties data. The counties data is stored as Enclosed JSON.

```sql
CREATE TABLE counties (Area string, Perimeter string, State string, County string, Name string, BoundaryShape binary)    
ROW FORMAT SERDE 'com.esri.hadoop.hive.serde.EsriJsonSerDe'
STORED AS INPUTFORMAT 'com.esri.json.hadoop.EnclosedEsriJsonInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat';
```

Load data into the respective tables:
```sql
LOAD DATA INPATH 'earthquake-demo/earthquake-data/earthquakes.csv' OVERWRITE INTO TABLE earthquakes;
```

Do the same thing for counties.

Run the demo analysis:
```sql
SELECT counties.name, count(*) cnt FROM counties
JOIN earthquakes
WHERE ST_Contains(counties.boundaryshape, ST_Point(earthquakes.longitude, earthquakes.latitude))
GROUP BY counties.name
ORDER BY cnt desc;
```

```sql
set hive.strict.checks.cartesian.product;
hive.strict.checks.cartesian.product=true;
set hive.strict.checks.cartesian.product;
```

```sql
set hive.mapred.mode;
set hive.mapred.mode=nonstrict;
set hive.mapred.mode;
```

## Run a hive script
Exit hive. Go to the script path:
```sql
cd /home/hadoop/gis-tools-for-hadoop/samples/point-in-polygon-aggregation-hive
```

Edit paths of script ```run-sample.sql```.

Enter hive.
Disable checks

Run script:
```sql
source run-sample.sql;
```

## Aggregate csv data

For this example, we need to download the taxi dataset, which is compressed using [7 Zip](https://www.7-zip.org/).

Download 7 Zip:
```bash
wget https://www.mirrorservice.org/sites/dl.fedoraproject.org/pub/epel/6/x86_64/Packages/p/p7zip-16.02-10.el6.x86_64.rpm
wget https://www.mirrorservice.org/sites/dl.fedoraproject.org/pub/epel/6/x86_64/Packages/p/p7zip-plugins-16.02-10.el6.x86_64.rpm
```

Install 7 Zip:
```bash
sudo rpm -U --quiet p7zip-16.02-10.el6.x86_64.rpm
sudo rpm -U --quiet p7zip-plugins-16.02-10.el6.x86_64.rpm
```

Download trip data from an S3 bucket:
```bash
 wget https://s3.eu-west-3.amazonaws.com/joana-bts-ada/trip_data.7z
```

Uncompress it:
```bash
 7z x trip_data.7z 
```

Create a directory to hold the data and move it there:
```bash
mkdir gis-tools-for-hadoop/samples/data/taxi-data
mv trip*csv gis-tools-for-hadoop/samples/data/taxi-data
```

Put data in Hadoop FS. Make a directory, if needed:
```bash
hadoop fs -mkdir taxidemo
```

Sit back and relax ;-)
```bash
hadoop fs -put gis-tools-for-hadoop/samples/data/taxi-data taxidemo
```

Check that it worked:
```bash
hadoop fs -ls taxidemo
```

View schema:
```bash
head -2 trip_data_1.csv > header_taxi.csv
```

Enter hive.

Add the necessary jars:
```sql
add jar
  ${env:HOME}/gis-tools-for-hadoop/samples/lib/esri-geometry-api-2.0.0.jar
  ${env:HOME}/gis-tools-for-hadoop/samples/lib/spatial-sdk-hive-2.0.0.jar
  ${env:HOME}/gis-tools-for-hadoop/samples/lib/spatial-sdk-json-2.0.0.jar;
```

List tables:
```sql
show tables;
```

Drop table, if it exists:
```sql
drop table taxi_demo;
```

Create table to hold the data:
```sql
 CREATE EXTERNAL TABLE taxi_demo(medallion STRING, hack_license STRING,vendor_id STRING,
 rate_code STRING,store_and_fwd_flag STRING,pickup_datetime STRING, 
 dropoff_datetime STRING, passenger_count DOUBLE, trip_time_in_secs DOUBLE, 
 trip_distance DOUBLE, pickup_longitude DOUBLE,pickup_latitude DOUBLE, 
 dropoff_longitude DOUBLE, dropoff_latitude DOUBLE)
 ROW FORMAT delimited fields terminated by ',' STORED AS textfile
 tblproperties ("skip.header.line.count"="1");
```

Check that the table was created correctly:
```sql
describe taxi_demo;
```

Load the taxi CSV data into the table:
```sql
LOAD DATA INPATH 'taxidemo/taxi-data/trip_data_1.csv' OVERWRITE INTO TABLE taxi_demo;
```

Load the rest of the data (2-12).
```sql
Check how many records we have:
select count(*) from taxi_demo;
```

Create the temporary functions that will be used in aggregating bins:
```sql
 create temporary function ST_Bin as 'com.esri.hadoop.hive.ST_Bin';
 create temporary function ST_Point as 'com.esri.hadoop.hive.ST_Point';
 create temporary function ST_BinEnvelope as 'com.esri.hadoop.hive.ST_BinEnvelope';
```

Try out the aggregation:
```sql
FROM (SELECT ST_Bin(1/1000, ST_Point(dropoff_longitude,dropoff_latitude)) bin_id, *FROM taxi_demo) bins
SELECT ST_BinEnvelope(1/1000, bin_id) shape,
COUNT(*) count
GROUP BY bin_id;
```

N.b.: 0.001 refers to 0.001 degrees (the unit the data is in). This can easily be changed if you want less or more detail.

If it ran without errors, create a new hive table to save the results to, but first drop it, if it exists.

```sql
drop table taxi_agg;
```

```sql
CREATE TABLE taxi_agg(area BINARY, count DOUBLE)
ROW FORMAT SERDE 'com.esri.hadoop.hive.serde.GeoJsonSerDe' 
STORED AS INPUTFORMAT 'com.esri.json.hadoop.UnenclosedGeoJsonInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat';
```

Rerun the query, and save the results to the new table taxi_agg:
```sql
FROM (SELECT ST_Bin(1, ST_Point(dropoff_longitude,dropoff_latitude)) bin_id, *FROM taxi_demo) bins
INSERT OVERWRITE TABLE taxi_agg
SELECT ST_BinEnvelope(1, bin_id) shape, COUNT(*) count
GROUP BY bin_id;
```

How many records do we have now?

Add support for ST_AsGeoJSON:
```sql
create temporary function ST_AsGeoJSON as 'com.esri.hadoop.hive.ST_AsGeoJson';
```

Query data:
```sql
select ST_AsGeoJSON(area), count from taxi_agg limit 10;
```sql