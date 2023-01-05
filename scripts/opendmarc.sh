#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset

noop() {
    while true; do
        # 2147483647 = max signed 32-bit integer
        # 2147483647 s ≅ 70 years
        sleep infinity || sleep 2147483647
    done
}

if [[ -n "${DMARC_SOCKET_PATH:-}" ]]; then
  /usr/sbin/opendmarc -f -c /etc/opendmarc.conf -u spamass-milter  | \
    while read -r line; do echo "opendmarc: $line"; done
else
  echo "INFO: Not running opendmarc, since no socket path is set"
  noop
fi