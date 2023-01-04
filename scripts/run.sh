#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset

. /scripts/common.sh

echo_start_banner
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
fi

# Ensuring the directories for the sockets exist (usually not necessary in prod)
mkdir -p /var/spool/postfix/${POSTGREY_SOCKET_PATH%/*}
mkdir -p /var/spool/postfix/${SPAMASS_SOCKET_PATH%/*}
mkdir -p /var/spool/postfix/${DKIM_SOCKET_PATH%/*}

# TODO: keep this in sync with the postfix user and group of the postfix docker container
chown -R spamass-milter:spamass-milter /var/spool/postfix

# Patch rsyslogd to disable kernel message logging
sed 's/^module(load=\"imklog\".*)/#&/' -i.bak /etc/rsyslog.conf

# Create opendkim.conf from template
/scripts/create_opendkim_conf.sh

echo_exec_banner
exec supervisord -c /etc/supervisord.conf