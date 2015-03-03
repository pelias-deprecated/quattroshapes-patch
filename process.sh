#! /bin/bash

# Description:
#   Perform all custom processing of Quattroshapes.
#
# Use:
#   bash process.sh

main(){
	for dep in psql shp2pgsql unzip ogr2ogr; do
		command -v $dep > /dev/null 2>&1 || {
			echo >&2 "You must have $dep installed. Aborting.";
			exit 1;
		}
	done

	bash import_quattroshapes/import_quattroshapes_pgsql.sh
	bash patch_alpha3.sh
	psql -d quattroshapes -v ON_ERROR_STOP=1 -f patch_popularity.sql > /dev/null
	bash export_shapefiles.sh
}

main
