#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset

. /scripts/common.sh

echo_start_banner
# Patch rsyslogd to disable kernel message logging
sed 's/^module(load=\"imklog\".*)/#&/' -i.bak /etc/rsyslog.conf

if [[ -n "${POSTGREY_SOCKET_PATH:-}" ]]; then
  echo "Postgrey socket path set: ${POSTGREY_SOCKET_PATH}"
fi
if [[ -n "${SPAMASS_SOCKET_PATH:-}" ]]; then
  echo "Spamass socket path set: ${SPAMASS_SOCKET_PATH}"
fi
if [[ -n "${DKIM_SOCKET_PATH:-}" ]]; then
  echo "DKIM socket path set: ${DKIM_SOCKET_PATH}"
  if [[ -z "${DKIM_DOMAINS:-}" ]]; then (>&2 echo "Error: env var DKIM_DOMAINS not set" && exit 1); fi
  if [[ -z "${DKIM_SELECTOR:-}" ]]; then (>&2 echo "Error: env var DKIM_SELECTOR not set" && exit 1); fi
  if [[ -z "${DKIM_KEY_PATH:-}" ]]; then (>&2 echo "Error: env var DKIM_KEY_PATH not set" && exit 1); fi

  # Create opendkim.conf from template
  /scripts/create_opendkim_conf.sh
fi

# Patch /etc/opendmarc.conf
if [[ -n "${DMARC_SOCKET_PATH:-}" ]]; then
  echo "DMARC socket path is set: ${DMARC_SOCKET_PATH}"
  if [[ -z "${MAIL_HOSTNAME:-}" ]]; then (>&2 echo "Error: env var MAIL_HOSTNAME not set" && exit 1); fi

  # Configuration taken from https://www.linuxbabe.com/mail-server/opendmarc-postfix-ubuntu
  sed 's@^Socket local:.*@Socket local:/var/spool/postfix/'"${DMARC_SOCKET_PATH}"'@' -i.bak /etc/opendmarc.conf
  cat <<EOF >> /etc/opendmarc.conf
AuthservID OpenDMARC
TrustedAuthservIDs ${MAIL_HOSTNAME}
RejectFailures true
IgnoreAuthenticatedClients true
RequiredHeaders    true
SPFSelfValidate true
EOF
fi

# Ensuring the directories for the sockets exist (usually not necessary in prod)
if [[ -n "${POSTGREY_SOCKET_PATH:-}" ]]; then mkdir -p /var/spool/postfix/"${POSTGREY_SOCKET_PATH%/*}"; fi
if [[ -n "${SPAMASS_SOCKET_PATH:-}" ]]; then mkdir -p /var/spool/postfix/"${SPAMASS_SOCKET_PATH%/*}"; fi
if [[ -n "${DKIM_SOCKET_PATH:-}" ]]; then mkdir -p /var/spool/postfix/"${DKIM_SOCKET_PATH%/*}"; fi
if [[ -n "${DMARC_SOCKET_PATH:-}" ]]; then mkdir -p /var/spool/postfix/"${DMARC_SOCKET_PATH%/*}"; fi

# syslog: 101:101
# debian-spamd: 106:106
# postfix in postfix docker container: 101:103
#
# Keep in sync with postfix uid
chown -R syslog:opendkim /var/spool/postfix
chown -R debian-spamd:debian-spamd /var/lib/spamass-milter

echo_exec_banner
exec supervisord -c /etc/supervisord.conf
