#!/bin/bash

DIR_BACKUP='/Users/Aaron/Sites'
EXCLUDE='/test, /test1, /test2'
CREATE_LATEST=false


for EXCLUSIONS in $(echo ${EXCLUDE} | sed -e "s/,/ /g" -e "s/  / /g"); do
	EXC+=(--exclude="${EXCLUSIONS}")
done

echo "${EXC[@]}"

for DIR in $(echo ${DIR_BACKUP} | sed -e "s/,/ /g" -e "s/  / /g"); do
	echo "/root/backups.sh --app-name '$(basename ${DIR})' --dir-backup '/${DIR}' $([ "$(echo ${EXCLUDE} | tr A-Z a-z)" ] && echo "--exclude '${EXCLUDE}'" || echo -e "\b")"
done



