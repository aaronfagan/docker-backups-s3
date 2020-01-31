#!/bin/bash
DATE=`date +%Y-%m-%d`
HOST="aaronfagan-ca-www"
DIR_S3="s3://aaronfagan-ca-cdn/.private/backups"
DIR_TEMP="/tmp/docker-backups"

for FOLDER in /data/*; do
	NAME=${FOLDER//\/data\//}
	echo -ne "> Backing up ${FOLDER}..."
	(
		set -e
		DIR_TEMP="${DIR_TEMP}/${NAME}_`date +%s`"
		FILENAME=$(echo ${NAME}_${DATE}_${HOST} | tr A-Z a-z)
		FILENAME=${FILENAME// /-}
		FILENAME="${FILENAME//./-}.tar.gz"
		mkdir -p "${DIR_TEMP}"
		tar -zcf "${DIR_TEMP}/${FILENAME}" -C "${FOLDER}" .
		aws s3 mv "${DIR_TEMP}/${FILENAME}" "${DIR_S3}/${HOST}/${DATE}/${FILENAME}" --quiet
	)
	if [ "$?" -ne "0" ]; then
		pushover --title "${HOSTNAME}" --message "Cronjob failed @ `date +"%r"`\n[$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")]" --priority 1 -q
		rm -rf "${DIR_TEMP}/${NAME}_"*
		echo -ne "failed!\n"
	else
		rm -rf "${DIR_TEMP}/${NAME}_"*
		echo -ne "success!\n"
	fi
done