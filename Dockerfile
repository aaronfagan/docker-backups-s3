FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

ENV CRON="0 0 * * *"

RUN apt-get update && apt-get install -y \
		awscli \
		cron \
		curl \
		dnsutils \
		nano \
		software-properties-common

COPY ./ /opt
COPY ./entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/bin/bash"]
