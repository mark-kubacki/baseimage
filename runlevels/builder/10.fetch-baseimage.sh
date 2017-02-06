#!/bin/bash
.  /dgr/bin/functions.sh
isLevelEnabled "debug" && set -x

set -euo pipefail
: ${CACHEDIR:="/cache"}
: ${BASEIMAGE:="ubuntu-16.04-linux-amd64.aci"}
: ${ACI_HOST:="https://s.blitznote.com/aci"}

curl --fail --progress-bar --location --remote-time --create-dirs \
  -H "Accept: application/aci, application/octet-stream" \
  -{z,o}"${CACHEDIR}/${BASEIMAGE}" \
  ${ACI_HOST}/${BASEIMAGE}

tar -C ${ROOTFS}/ \
  --exclude "manifest" \
  --strip-components=1 \
  -xJf "${CACHEDIR}/${BASEIMAGE}"
