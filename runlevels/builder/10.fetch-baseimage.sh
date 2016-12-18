#!/bin/bash
.  /dgr/bin/functions.sh
isLevelEnabled "debug" && set -x

set -euo pipefail
: ${CACHEDIR:="/cache"}
: ${BASEIMAGE:="ubuntu-16.04-linux-$(dpkg --print-architecture).aci"}
: ${ACI_HOST:="https://s.blitznote.com/aci"}

if [[ ! -s "${CACHEDIR}/${BASEIMAGE}" ]]; then
  find / -name 'cache' -type d
  exit 9
fi

curl --fail --progress-bar --location --remote-time --create-dirs \
  -H "Accept: application/aci, application/octet-stream" \
  -{z,o}"${CACHEDIR}/${BASEIMAGE}" \
  ${ACI_HOST}/${BASEIMAGE}

tar -C ${ROOTFS}/ \
  --exclude "manifest" \
  --strip-components=1 \
  -xJf "${CACHEDIR}/${BASEIMAGE}"
