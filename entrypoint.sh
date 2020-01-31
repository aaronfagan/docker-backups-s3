#!/bin/bash
set -e
shopt -s dotglob

VARS_REQUIRED=(
	AWS_DEFAULT_REGION
    AWS_DEFAULT_OUTPUT
    CRON_SCHEDULE
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

aws configure set default.region ${AWS_DEFAULT_REGION}
aws configure set default.output json

[ "${CRON}" == "minutely" ] && TIME="* * * * *" || TIME="@${CRON}"
echo "${TIME} root /root/backups.sh > /proc/1/fd/1" > /etc/cron.d/backups

/etc/init.d/cron start > /dev/null 2>&1

echo "Cron is running!"
exec $(which tail) -f /dev/null
