FROM ubuntu:22.04
LABEL maintainer="Jochen Issing <c.333+github@nesono.com> (@jochenissing)"

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update &&  \
    apt-get install -y --no-install-recommends  \
    bash  \
    rsyslog \
    postgrey  \
    spamassassin \
    spamass-milter  \
    opendmarc  \
    opendkim  \
    supervisor  \
    netcat && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/spool/postfix && \
    chown -R postfix:postfix /var/run/postfix && \
    mkdir -p /vhome/users/ && \
    groupadd -g 101 postfix && \
    useradd -u 101 -g 102 postfix -d /var/run/postfix && \
    passwd -l vmail && \
    mkdir -p /var/run/postfix && \
    chown -R postfix:postfix /var/run/postfix

VOLUME [ "/var/spool/postfix", "/etc/opendkim/keys", "/vhome/users" ]

COPY scripts/* /scripts/
COPY configs/* /etc/
RUN chmod +x /scripts/*

CMD [ "/bin/bash", "-c", "/scripts/run.sh" ]