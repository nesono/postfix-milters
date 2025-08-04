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

# Add user spamass-milter to debian-spamd, to access the user spam databases below `/vhome`
# - since spamass-milter is the same group as postfix in the postfix docker container
RUN usermod -aG debian-spamd spamass-milter

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