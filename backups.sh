#!/bin/bash

CREATE_LATEST=""
RECURSIVE=""

usage() {
	echo "
Usage:
    ./$(basename "$0") [options]

Options:
    --create-latest   Create a latest folder with most recent backups.
    --dir-backup      The directory to backup. REQUIRED.
    --exclude         A comma separated list of files & folders to not include in backups.
    --recursive       Backup subfolders of --dir-backup into separate files.
    --s3-path         The full Amazon S3 bucket path. REQUIRED.

Example:
    ./$(basename "$0") \\
    --create-latest \\
    --dir-backup /data \\
    --exclude .DS_Store \\
    --recursive \\
    --s3-path s3://my-bucket/backups
"
}

backup() {
	DATE=`date +%Y-%m-%d`
	TIME=`date +%H-%M-%S`
	APP_NAME="$(basename "$(dirname "${1}")")"
	DIR_TEMP="/tmp/docker-backups"
	DIR_NAME=$(basename ${1})
	echo -ne "[$(date +'%F %T')] Backing up ${1}..."
	(
		set -e
		for EXC in $(echo ${EXCLUDE} | sed -e "s/,/ /g" -e "s/  / /g"); do
			EXCLUSIONS+=(--exclude="${EXC}")
		done
		DIR_TEMP="${DIR_TEMP}/${DIR_NAME}_${DATE}_${TIME}"
		FILENAME="$(echo ${DIR_NAME}_${APP_NAME}_${DATE}_${TIME} | tr A-Z a-z | tr ' ' '-' | tr '.' '-').tar.gz"
		FILENAME_LATEST="$(echo ${DIR_NAME} | tr A-Z a-z | tr ' ' '-' | tr '.' '-').tar.gz"
		mkdir -p "${DIR_TEMP}"
		tar "${EXCLUSIONS[@]}" -zcf "${DIR_TEMP}/${FILENAME}" -C "${1}" .
		/usr/bin/aws s3 cp "${DIR_TEMP}/${FILENAME}" "${S3_PATH}/${DATE}/${APP_NAME}/${FILENAME}" --quiet
		if [ -n "${CREATE_LATEST}" ]; then
			/usr/bin/aws s3 cp "${S3_PATH}/${DATE}/${APP_NAME}/${FILENAME}" "${S3_PATH}/latest/${APP_NAME}/${FILENAME_LATEST}" --quiet
		fi
		rm -rf "${DIR_TEMP}"
	)
	[ "$?" -ne "0" ] && echo -ne "failed!\n" || echo -ne "success!\n"
}

while [[ $# -gt 0 ]]; do
	case ${1} in
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
		--recursive)
			RECURSIVE=true
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

if [ -z "${DIR_BACKUP}" ] || [ -z "${S3_PATH}" ]; then
	if [ -z "${DIR_BACKUP}" ]; then echo -ne "\033[0;31mERROR:\033[0;37m --dir-backup arguement is required.\033[0m\n"; fi
	if [ -z "${S3_PATH}" ]; then echo -ne "\033[0;31mERROR:\033[0;37m --s3-path arguement is required.\033[0m\n"; fi
	usage
	exit 0
else
	if [ "${RECURSIVE}" ]; then
		for DIR in ${DIR_BACKUP}/*; do
			backup ${DIR}
		done
	else
		backup ${DIR_BACKUP}
	fi
fi
