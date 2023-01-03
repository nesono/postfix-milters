#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset

readonly SPAMASS_SOCKET="/var/spool/postfix/${SPAMASS_SOCKET_PATH:-}"

cleanup() {
  rm -rf "${SPAMASS_SOCKET}"
}
trap cleanup EXIT

noop() {
    while true; do
        # 2147483647 = max signed 32-bit integer
        # 2147483647 s ≅ 70 years
        sleep infinity || sleep 2147483647
    done
}

if [[ -n "${SPAMASS_SOCKET_PATH:-}" ]]; then
  /usr/sbin/spamass-milter -r 15 -p "${SPAMASS_SOCKET}" | \
    while read line; do echo "spamass-milter: $line"; done
else
  echo "INFO: Not running spamass-milter, since socket is disabled"
  noop
fi
