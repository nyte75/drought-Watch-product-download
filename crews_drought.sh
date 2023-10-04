#!/bin/bash

# Change this to suit.
export DL_DIR=~/climatology/crewsPNG/july
download_access=true	# default true
download_monthly=true	# default true
download_daily=false	# default false

function check_folder ()
{
	if [ ! -d "$1" ]; then
		mkdir -p $1
		chmod -R 775 $1
	fi 
}

function validate_url()
{
	if [[ `wget -S --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
		return 0;
	else
		return 1;
	fi 
}

function clean_archive {
	#	#Remove maps older than 1 months (based on file creation)
	find ${DL_DIR}/satellite_products/monthly/ -name '*.png' -mtime +40 -type f -delete 2>/dev/null
	echo "Archive of the past satellite images cleaned"

}

# # ACCESS-S products

if [ "$download_access" = true ]; then
	for domain in PNG_crews_ag aiyura asaro bena kerevat markham	# Select domains. Can add others if needed.
	do
		check_folder ${DL_DIR}/ACCESS_S-outlooks/monthly/$domain
		check_folder ${DL_DIR}/ACCESS_S-outlooks/weekly/$domain
		wget -r --no-parent --no-directories -N -R index.html* "http://access-s.clide.cloud/files/project/PNG_crews/ACCESS_S-outlooks/$domain/monthly/forecast/" -P ${DL_DIR}/ACCESS_S-outlooks/monthly/$domain -A rain.*.png
		wget -r --no-parent --no-directories -N -R index.html* "http://access-s.clide.cloud/files/project/PNG_crews/ACCESS_S-outlooks/$domain/weekly/forecast/" -P ${DL_DIR}/ACCESS_S-outlooks/weekly/$domain -A rain.*.png
	done
fi 

# Satellite Products

# Download monthly products
if [ "$download_monthly" = true ]; then
	check_folder ${DL_DIR}/satellite_products/monthly

	now=$(date +"%Y%m%d")
	not_exists=true
	echo $not_exists
	while [ "$not_exists" = true ]
	do 
		validate_url http://access-s.clide.cloud/files/archive/$now/project/PNG_crews/SEMDP-products/monthly/
		if [ $? == 0 ]; then
			echo $now exists
			for agg_period in 1 2 3 4 6 # Select monthly periods. If new ones needed, contact BOM.
			do
				# For var in gsmap gsmap.pct hir spi.moments.png.gsmap ndvi vhi hir.pct		# Select monthly variables. Can add others if needed
				for var in gsmap.pct vhi spi.moments.png.gsmap		# Default
				do
					wget -r --no-parent --no-directories -N -R index.html*,*.transparent.* "http://access-s.clide.cloud/files/archive/${now}/project/PNG_crews/SEMDP-products/monthly" -P ${DL_DIR}/satellite_products/monthly/ -A ${var}.${agg_period}month.*.png
				done
			done
			not_exists=false
		else
			echo $now does not exists
			now=$(date -d "${now} -1 days" +"%Y%m%d")
		fi
	done
fi

# Download multiday products
if [ "$download_daily" = true ]; then
	check_folder ${VIEWER_DIR}/satellite_products/multiday

	for period in 1 7 30	# Select daily periods
	do
		for file in gsmap.pct.${period}day gsmap.anom.${period}day gsmap.${period}day	# Select daily variables. can add others if needed
		do
			echo http://access-s.clide.cloud/files/project/PNG_crews/SEMDP-products/multiday/${file}.png
			wget -r --no-parent --no-directories -N -R index.html* -P ${VIEWER_DIR}/satellite_products/multiday/ http://access-s.clide.cloud/project/PNG_crews/SEMDP-products/multiday/${file}.png
		done

	done
fi

clean_archive
				
