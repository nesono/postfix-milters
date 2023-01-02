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
    rm -rf /var/lib/apt/lists/*

# TODO: spamass-milter:spamass-milter here needs to be the same as postfix:postfix in the postfix container
RUN mkdir -p /var/spool/postfix && \
    chown -R spamass-milter:spamass-milter /var/spool/postfix && \
    mkdir -p /vhome/users/ && \
    chown -R spamass-milter:spamass-milter /vhome/users

VOLUME [ "/var/spool/postfix", "/etc/opendkim/keys", "/vhome/users" ]

COPY scripts/* /scripts/
COPY configs/* /etc/
RUN chmod +x /scripts/*

CMD [ "/bin/bash", "-c", "/scripts/run.sh" ]