add jar
  ${env:HOME}/gis-tools-for-hadoop/samples/lib/esri-geometry-api-2.0.0.jar
  ${env:HOME}/gis-tools-for-hadoop/samples/lib/spatial-sdk-hive-2.0.0.jar
  ${env:HOME}/gis-tools-for-hadoop/samples/lib/spatial-sdk-json-2.0.0.jar;





 create temporary function ST_Bin as 'com.esri.hadoop.hive.ST_Bin';
 create temporary function ST_Point as 'com.esri.hadoop.hive.ST_Point';
 create temporary function ST_BinEnvelope as 'com.esri.hadoop.hive.ST_BinEnvelope';
 create temporary function ST_AsGeoJSON as 'com.esri.hadoop.hive.ST_AsGeoJson';
 screate temporary function ST_AsText as 'com.esri.hadoop.hive.ST_AsText';
