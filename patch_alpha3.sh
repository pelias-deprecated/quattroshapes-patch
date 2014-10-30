#! /bin/bash

# Description:
#   Patch alpha 3 values in Quattroshapes using `patch_alpha3.sql`.
#
# Use:
#   bash patch_alpha3.sh

quattro_psql(){
	psql -d quattroshapes -v ON_ERROR_STOP=1 $* > /dev/null 2>&1
}

main(){
	adm0PolysZip="TM_WORLD_BORDERS-0.3.zip"
	local adm0PolysUrl="http://thematicmapping.org/downloads/$adm0PolysZip"

	echo "Downloading/unzipping canonical_adm0 polygons."
	wget --quiet "$adm0PolysUrl"
	unzip "$adm0PolysZip" > /dev/null
	rm "$adm0PolysZip"

	echo "Importing canonical_adm0 polygons."
	shp2pgsql -WLATIN1 -s SRID=4326 TM_WORLD_BORDERS-0.3.shp canonical_adm0 |\
		quattro_psql

	quattro_psql -f patch_alpha3.sql
}

main
