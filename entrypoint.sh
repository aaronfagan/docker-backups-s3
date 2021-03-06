#!/bin/bash
set -e
shopt -s dotglob

VARS_REQUIRED=(
	AWS_DEFAULT_REGION
	CRON
	DIR_BACKUP
	S3_PATH
	TZ
)

for VAR in "${VARS_REQUIRED[@]}"; do
    if [ -z "${!VAR}" ]; then
        echo "ERROR: Required variable \"${VAR}\" is not set!";
        VAR_ERROR=true;
    fi
done
if [ "${VAR_ERROR}" ]; then exit 1; fi

ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
echo "${TZ}" > /etc/timezone && \
dpkg-reconfigure -f noninteractive tzdata > /dev/null 2>&1

[ "${AWS_ACCESS_KEY_ID}" ] && aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
[ "${AWS_SECRET_ACCESS_KEY}" ] && aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
[ "${AWS_DEFAULT_REGION}" ] && aws configure set default.region ${AWS_DEFAULT_REGION}
[ "${AWS_DEFAULT_OUTPUT}" ] && aws configure set default.output ${AWS_DEFAULT_OUTPUT} || aws configure set default.output json

for DIR in $(echo ${DIR_BACKUP} | sed -e "s/,/ /g" -e "s/  / /g"); do
	DIR=$(echo ${DIR} | tr A-Z a-z | sed -e "s/\///")
	FILENAME="backup-${DIR//\//-}"
	echo "${CRON} root /root/src/backups.sh --dir-backup '/${DIR}' --s3-path '${S3_PATH}' $([ "${EXCLUDE}" ] && echo "--exclude '${EXCLUDE}' ")$([ "${CREATE_LATEST}" ] && echo "--create-latest ")$([ "${RECURSIVE}" ] && echo "--recursive ")> /proc/1/fd/1" > /etc/cron.d/${FILENAME}
done

/etc/init.d/cron start > /dev/null 2>&1

echo "AWS S3 Backups is running!"
exec $(which tail) -f /dev/null
