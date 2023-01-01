#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset

noop() {
    while true; do
        # 2147483647 = max signed 32-bit integer
        # 2147483647 s ≅ 70 years
        sleep infinity || sleep 2147483647
    done
}

if [[ -n "${SPAMASS_SOCKET_PATH:-}" ]]; then
  exec /usr/sbin/spamass-milter -r 15 -p "/var/spool/postfix/${SPAMASS_SOCKET_PATH}"
else
  echo "Not running spamass-milter, since socket is disabled"
  noop
fi
