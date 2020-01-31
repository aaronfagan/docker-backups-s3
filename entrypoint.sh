#!/bin/bash
set -e
shopt -s dotglob

VARS_REQUIRED=(
	APP_NAME
	AWS_DEFAULT_REGION
	CRON_SCHEDULE
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

cp -rf /opt/sbackups.sh /root/backups.sh
chmod +x /root/backups.sh

ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
echo "${TZ}" > /etc/timezone && \
dpkg-reconfigure -f noninteractive tzdata > /dev/null 2>&1

[ "${CRON}" == "minutely" ] && TIME="* * * * *" || TIME="@${CRON}"
echo "${TIME} root /root/backups.sh > /proc/1/fd/1" > /etc/cron.d/backups

/etc/init.d/cron start > /dev/null 2>&1

echo "AWS S3 Backups is running!"
exec $(which tail) -f /dev/null
