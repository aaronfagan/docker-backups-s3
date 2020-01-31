#!/bin/bash
DATE=`date +%Y-%m-%d`
DIR_TEMP="/tmp/docker-backups"
LABEL=$(hostname)

for FOLDER in /data/*; do
	NAME=${FOLDER//\/data\//}
	echo -ne "> Backing up ${FOLDER}..."
	(
		set -e
		DIR_TEMP="${DIR_TEMP}/${NAME}_`date +%s`"
		FILENAME=$(echo ${NAME}_${DATE}_${LABEL} | tr A-Z a-z)
		FILENAME=${FILENAME// /-}
		FILENAME="${FILENAME//./-}.tar.gz"
		mkdir -p "${DIR_TEMP}"
		tar -zcf "${DIR_TEMP}/${FILENAME}" -C "${FOLDER}" .
		aws s3 mv "${DIR_TEMP}/${FILENAME}" "${S3_PATH}/${LABEL}/${DATE}/${FILENAME}" --quiet
	)
	if [ "$?" -ne "0" ]; then
		pushover --title "${LABEL}" --message "Cronjob failed @ `date +"%r"`\n[$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")]" --priority 1 -q
		rm -rf "${DIR_TEMP}/${NAME}_"*
		echo -ne "failed!\n"
	else
		rm -rf "${DIR_TEMP}/${NAME}_"*
		echo -ne "success!\n"
	fi
done
