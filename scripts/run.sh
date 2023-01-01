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
  echo "Spamass socket path set: ${DKIM_SOCKET_PATH}"
fi
echo_exec_banner

# Ensuring the directories for the sockets exist (usually not necessary in prod)
mkdir -p /var/spool/postfix/${POSTGREY_SOCKET_PATH%/*}
mkdir -p /var/spool/postfix/${SPAMASS_SOCKET_PATH%/*}
mkdir -p /var/spool/postfix/${DKIM_SOCKET_PATH%/*}

chmod -R a+rw /var/spool/postfix
exec supervisord -c /etc/supervisord.conf