#!/bin/bash
DATE=`date +%Y-%m-%d_%H-%M-%S`
DIR_TEMP="/tmp/docker-backups"

for FOLDER in /data/*; do
	FOLDER_NAME=${FOLDER//\/data\//}
	echo -ne "> Backing up ${FOLDER}..."
	(
		set -e
		DIR_TEMP="${DIR_TEMP}/${FOLDER_NAME}_${DATE}"
		FILENAME=$(echo ${FOLDER_NAME}_${APP_NAME}_${DATE} | tr A-Z a-z)
		FILENAME=${FILENAME// /-}
		FILENAME="${FILENAME//./-}.tar.gz"
		mkdir -p "${DIR_TEMP}"
		tar -zcf "${DIR_TEMP}/${FILENAME}" -C "${FOLDER}" .
		aws s3 mv "${DIR_TEMP}/${FILENAME}" "${S3_PATH}/${APP_NAME}/${DATE}/${FILENAME}" --quiet
	)
	if [ "$?" -ne "0" ]; then
		rm -rf "${DIR_TEMP}/${FOLDER_NAME}_"*
		echo -ne "failed!\n"
	else
		rm -rf "${DIR_TEMP}/${FOLDER_NAME}_"*
		echo -ne "success!\n"
	fi
done
