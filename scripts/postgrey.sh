#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset

readonly POSTGREY_SOCKET="/var/spool/postfix/${POSTGREY_SOCKET_PATH:-}"

cleanup() {
  rm -rf ${POSTGREY_SOCKET}
}
trap cleanup EXIT

noop() {
    while true; do
        # 2147483647 = max signed 32-bit integer
        # 2147483647 s ≅ 70 years
        sleep infinity || sleep 2147483647
    done
}

if [[ -n "${POSTGREY_SOCKET_PATH:-}" ]]; then
  exec /usr/sbin/postgrey --unix="${POSTGREY_SOCKET}" | \
    while read line; do echo "postgrey: $line"; done
else
  echo "INFO: Not running postgrey, since socket is disabled"
  noop
fi
