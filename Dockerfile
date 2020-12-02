FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

ENV CRON="0 0 * * *"

RUN apt-get update && apt-get install -y --no-install-recommends \
		awscli \
		cron \
		curl \
		dnsutils \
		nano \
		software-properties-common

COPY ./ /root/src

RUN chmod -R +x /root/src

ENTRYPOINT ["/root/src/entrypoint.sh"]

CMD ["/usr/bin/bash"]
