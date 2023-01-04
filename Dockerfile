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

RUN mkdir -p /var/spool/postfix && \
    mkdir -p /vhome/users/ && \
    chown -R debian-spamd:debian-spamd /vhome/users

# Add user spamass-milter to debian-spamd, to access the user spam databases below `/vhome`
# - since spamass-milter is the same group as postfix in the postfix docker container
RUN usermod -aG debian-spamd spamass-milter

VOLUME [ "/var/spool/postfix", "/etc/opendkim/keys", "/vhome/users", "/var/mail" ]

COPY scripts/* /scripts/
COPY configs/* /etc/
RUN chmod +x /scripts/*

CMD [ "/bin/bash", "-c", "/scripts/run.sh" ]