#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset

. /scripts/common.sh

echo_start_banner
if [[ -n "${POSTGREY_SOCKET_PATH:-}" ]]; then
  echo "Postgrey socket path set: ${POSTGREY_SOCKET_PATH}"
fi
echo_exec_banner

exec supervisord -c /etc/supervisord.conf