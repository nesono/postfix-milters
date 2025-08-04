FROM ubuntu:24.04
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
    netcat-traditional  \
    miltertest && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/spool/postfix && \
    mkdir -p /vhome/users/ && \
    chown -R debian-spamd:debian-spamd /vhome/users

# Note that in scripts/run.sh are more dependencies
# Postfix container: postfix u=101 g=103
# This container: u(101)=spamass-milter g(103)=opendkim
# This container: u(101)=syslog g(103)=opendkim
#
# KEEP ALL LINES IN  SYNC WITH THE TEXT "Keep in sync with the postfix uid"
#
# Add user syslog to debian-spamd, to access the user spam databases below `/vhome`
# since syslog has the same uid as postfix in the postfix docker container
RUN usermod -aG debian-spamd syslog

# Make SpamAssassin more lenient with Date headers by disabling strict date rules
RUN echo "" >> /etc/spamassassin/local.cf && \
    echo "# Disable strict Date header rules to allow emails from automated senders" >> /etc/spamassassin/local.cf && \
    echo "score MISSING_DATE 0" >> /etc/spamassassin/local.cf && \
    echo "score INVALID_DATE 0" >> /etc/spamassassin/local.cf

VOLUME [ "/var/spool/postfix", "/etc/opendkim/keys", "/vhome/users", "/var/mail" ]

COPY scripts/* /scripts/
COPY configs/* /etc/
RUN chmod +x /scripts/*

HEALTHCHECK  --interval=30s --timeout=5s --start-period=10s --retries=3 CMD /scripts/healthcheck.sh

CMD [ "/bin/bash", "-c", "/scripts/run.sh" ]
