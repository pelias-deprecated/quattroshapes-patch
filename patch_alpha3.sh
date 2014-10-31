#! /bin/bash

# Description:
#   Patch alpha 3 values in Quattroshapes using `patch_alpha3.sql`.
#
# Use:
#   bash patch_alpha3.sh

quattro_psql(){
	psql -d quattroshapes -v ON_ERROR_STOP=1 $* > /dev/null
}

main(){
	local adm0PolysZip="TM_WORLD_BORDERS-0.3.zip"
	local adm0PolysUrl="http://thematicmapping.org/downloads/$adm0PolysZip"

	echo "Downloading/unzipping canonical_adm0 polygons."

	local adm0DestDir="canonical_adm0_shp"
	mkdir "$adm0DestDir"
	cd "$adm0DestDir"
	wget --quiet "$adm0PolysUrl"
	unzip "$adm0PolysZip" > /dev/null
	rm "$adm0PolysZip"

	echo "Importing canonical_adm0 polygons."
	shp2pgsql -WLATIN1 -s 4326 TM_WORLD_BORDERS-0.3.shp canonical_adm0 2> /dev/null |\
		quattro_psql
	cd ..
	quattro_psql -f patch_alpha3.sql
}

main
