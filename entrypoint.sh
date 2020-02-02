#!/bin/bash
set -e
shopt -s dotglob

VARS_REQUIRED=(
	APP_NAME
	AWS_DEFAULT_REGION
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

cp -rf /opt/backups.sh /root/backups.sh
chmod +x /root/backups.sh

ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
echo "${TZ}" > /etc/timezone && \
dpkg-reconfigure -f noninteractive tzdata > /dev/null 2>&1

[ "${AWS_ACCESS_KEY_ID}" ] && aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
[ "${AWS_SECRET_ACCESS_KEY}" ] && aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
aws configure set default.region ${AWS_DEFAULT_REGION}
aws configure set default.output json

[ "${CRON}" == "minutely" ] && CRON_SCHEDULE="* * * * *" || CRON_SCHEDULE="@${CRON_SCHEDULE}"
echo "${CRON_SCHEDULE} root /root/backups.sh --app-name '${APP_NAME}' --dir-backup '${DIR_BACKUP}' --s3-path '${S3_PATH}' > /proc/1/fd/1" > /etc/cron.d/backups

/etc/init.d/cron start > /dev/null 2>&1

echo "AWS S3 Backups is running!"
exec $(which tail) -f /dev/null
