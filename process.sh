#! /bin/bash

# Description:
#   Perform all custom processing of Quattroshapes.
#
# Use:
#   bash process.sh

main(){
	bash import_quattroshapes/import_quattroshapes_pgsql.sh
	bash patch_alpha3.sh
	psql -d quattroshapes -v ON_ERROR_STOP=1 -f patch_popularity.sql > /dev/null
	bash export_shapefiles.sh
}

main
