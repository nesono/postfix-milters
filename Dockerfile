FROM ubuntu:22.04
LABEL maintainer="Jochen Issing <c.333+github@nesono.com> (@jochenissing)"

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update &&  \
    apt-get install -y --no-install-recommends  \
    bash  \
    rsyslog \
    postgrey  \
    spamass-milter  \
    opendmarc  \
    opendkim  \
    supervisor  \
    netcat  \
    && \
    rm -rf /var/lib/apt/lists/* \
    && \
    mkdir -p /var/spool/postfix

VOLUME [ "/var/spool/postfix", "/etc/opendkim/keys" ]

COPY scripts/* /scripts/
COPY configs/* /etc/
RUN chmod +x /scripts/*

CMD [ "/bin/bash", "-c", "/scripts/run.sh" ]