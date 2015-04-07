#! /bin/bash

# Description:
#   Perform all custom processing of Quattroshapes.
#
# Use:
#   bash process.sh

exec_sql_script(){
	psql -d quattroshapes -v ON_ERROR_STOP=1 -f $1 > /dev/null
}

main(){
	for dep in psql shp2pgsql unzip ogr2ogr; do
		command -v $dep > /dev/null 2>&1 || {
			echo >&2 "You must have $dep installed. Aborting.";
			exit 1;
		}
	done

	bash import_quattroshapes/import_quattroshapes_pgsql.sh
	bash patch_alpha3.sh
	exec_sql_script patch_popularity.sql
	exec_sql_script clean_data.sql
	bash export_shapefiles.sh
}

main
