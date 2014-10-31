#! /bin/bash

# Description:
#   Perform all custom processing of Quattroshapes.
#
# Use:
#   bash process.sh

main(){
	bash import_quattroshapes/import_quattroshapes_pgsql.sh
	bash patch_alpha3.sh
	bash export_shapefiles.sh
}

main
