#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset

test -f /etc/default/spamassassin && . /etc/default/spamassassin

noop() {
    while true; do
        # 2147483647 = max signed 32-bit integer
        # 2147483647 s ≅ 70 years
        sleep infinity || sleep 2147483647
    done
}

if [[ -n "${SPAMASS_SOCKET_PATH:-}" ]]; then
  exec /usr/sbin/spamd --max-children=5 -u debian-spamd --virtual-config-dir=/vhome/users/%u/spamassassin
else
  echo "Not running Spamd, since spamass is diabled"
  noop
fi