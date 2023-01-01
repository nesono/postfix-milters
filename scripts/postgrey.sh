#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset

noop() {
    while true; do
        # 2147483647 = max signed 32-bit integer
        # 2147483647 s ≅ 70 years
        sleep infinity || sleep 2147483647
    done
}

if [[ -n "${POSTGREY_SOCKET_PATH:-}" ]]; then
  exec /usr/sbin/postgrey --unix="/var/spool/postfix/${POSTGREY_SOCKET_PATH}"
else
  noop
fi
