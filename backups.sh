#!/bin/bash

CREATE_LATEST=""

usage() {
	echo "
Usage:
    ./$(basename "$0") [options]

Options:
    --app-name        The name of your app. REQUIRED.
    --create-latest   Create a latest folder with most recent backups.
    --dir-backup      The directory to backup. REQUIRED.
    --exclude         A comma separated list of files & folders to not include in backups.
    --s3-path         The full Amazon S3 bucket path. REQUIRED.

Example:
    ./$(basename "$0") \\
    --app-name my-app \\
    --dir-backup /data \\
    --exclude .DS_Store \\
    --create-latest \\
    --s3-path s3://my-bucket/backups
"
}

while [[ $# -gt 0 ]]; do
	KEY="$1"
	case ${KEY} in
		--app-name)
			APP_NAME="${2:-$APP_NAME}"
			shift
			shift
		;;
        --create-latest)
                CREATE_LATEST=true
                shift
        ;;
		--dir-backup)
			DIR_BACKUP="${2:-$DIR_BACKUP}"
			shift
			shift
		;;
		--exclude)
			EXCLUDE="${2:-$EXCLUDE}"
			shift
			shift
		;;
		--s3-path)
			S3_PATH="${2:-$S3_PATH}"
			shift
			shift
		;;
		--help)
			usage
			exit 0
		;;
		*) 
			INVALID+=("$1")
			shift
			echo -e "\033[0;31mERROR:\033[0;37m Invalid arguement: $INVALID\033[0m"
			usage
			exit 0
		;;
	esac
done

if [ -z "${APP_NAME}" ] || [ -z "${DIR_BACKUP}" ] || [ -z "${S3_PATH}" ]; then
	if [ -z "${APP_NAME}" ]; then echo -ne "\033[0;31mERROR:\033[0;37m --app-name arguement is required.\033[0m\n"; fi
	if [ -z "${DIR_BACKUP}" ]; then echo -ne "\033[0;31mERROR:\033[0;37m --dir-backup arguement is required.\033[0m\n"; fi
	if [ -z "${S3_PATH}" ]; then echo -ne "\033[0;31mERROR:\033[0;37m --s3-path arguement is required.\033[0m\n"; fi
	usage
	exit 0
else
	DATE=`date +%Y-%m-%d`
	TIME=`date +%H-%M-%S`
	DIR_TEMP="/tmp/docker-backups"
	for DIR in ${DIR_BACKUP}/*; do
		DIR_NAME=$(basename ${DIR})
		echo -ne "[$(date +'%F %T')] Backing up ${DIR}..."
		(
			set -e
			for EXCLUSIONS in $(echo ${EXCLUDE} | sed -e "s/,/ /g" -e "s/  / /g"); do
				EXC+=(--exclude="${EXCLUSIONS}")
			done
			DIR_TEMP="${DIR_TEMP}/${DIR_NAME}_${DATE}_${TIME}"
			FILENAME="$(echo ${DIR_NAME}_${APP_NAME}_${DATE}_${TIME} | tr A-Z a-z | tr ' ' '-' | tr '.' '-').tar.gz"
			FILENAME_LATEST="$(echo ${DIR_NAME} | tr A-Z a-z | tr ' ' '-' | tr '.' '-').tar.gz"
			mkdir -p "${DIR_TEMP}"
			tar -zcf "${DIR_TEMP}/${FILENAME}" -C "${DIR}" . "${EXC[@]}"
			/usr/bin/aws s3 cp "${DIR_TEMP}/${FILENAME}" "${S3_PATH}/${DATE}/${APP_NAME}/${FILENAME}" --quiet
			if [ -n "${CREATE_LATEST}" ]; then
				/usr/bin/aws s3 cp "${S3_PATH}/${DATE}/${APP_NAME}/${FILENAME}" "${S3_PATH}/latest/${APP_NAME}/${FILENAME_LATEST}" --quiet
			fi
			rm -rf "${DIR_TEMP}"
		)
		[ "$?" -ne "0" ] && echo -ne "failed!\n" || echo -ne "success!\n"
	done
fi
