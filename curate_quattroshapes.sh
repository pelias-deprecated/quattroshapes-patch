#!/bin/bash

# get the data moved where we need it and split and compress along alpha3
#
export ENCODING="UTF-8"

# move sql output data to simplified
if [ ! -d 'simplified' ]; then
  mkdir simplified
fi

types="qs_adm0 qs_adm1 qs_adm2 qs_localities qs_localadmin qs_neighborhoods"
for i in ${types}; do
  mv exported_quattroshapes/${i}/* simplified
done
tar czf quattroshapes-simplified.tar.gz ./simplified

# split alpha3
mkdir -p quattroshapes-alpha3/compressed

for i in $(cat /var/lib/postgresql/alpha3.csv); do
  mkdir quattroshapes-alpha3/${i}
  ogr2ogr -f "ESRI Shapefile" -where "qs_adm0_a3 = '${i}'" quattroshapes-alpha3/${i}/${i}_admin0.shp        simplified/qs_adm0.shp
  ogr2ogr -f "ESRI Shapefile" -where "qs_adm0_a3 = '${i}'" quattroshapes-alpha3/${i}/${i}_admin1.shp        simplified/qs_adm1.shp
  ogr2ogr -f "ESRI Shapefile" -where "qs_adm0_a3 = '${i}'" quattroshapes-alpha3/${i}/${i}_admin2.shp        simplified/qs_adm2.shp
  ogr2ogr -f "ESRI Shapefile" -where "qs_adm0_a3 = '${i}'" quattroshapes-alpha3/${i}/${i}_localadmin.shp    simplified/qs_localadmin.shp
  ogr2ogr -f "ESRI Shapefile" -where "qs_adm0_a3 = '${i}'" quattroshapes-alpha3/${i}/${i}_localities.shp    simplified/qs_localities.shp
  ogr2ogr -f "ESRI Shapefile" -where "qs_adm0_a3 = '${i}'" quattroshapes-alpha3/${i}/${i}_neighborhoods.shp simplified/qs_neighborhoods.shp

  tar czf quattroshapes-alpha3/compressed/${i}.tgz -C quattroshapes-alpha3 ${i}
done
