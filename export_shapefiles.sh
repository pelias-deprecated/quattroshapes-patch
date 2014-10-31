#! /bin/bash

# Description:
#   Export Quattroshapes tables from Postgres to shapefiles.
#
# Use:
#   bash export_shapefiles.sh

main(){
	local shapefiles=(
		qs_adm0
		qs_adm1
		qs_adm2
		qs_localities
		qs_localadmin
		qs_neighborhoods
	)

	local exportDir="exported_quattroshapes"
	mkdir "$exportDir"
	cd "$exportDir"
	for shp in ${shapefiles[@]}; do
		echo "Exporting $shp table."
		mkdir "$shp"
		pgsql2shp -f "$shp/$shp.shp" quattroshapes "$shp" > /dev/null 2>&1
	done
}

main
