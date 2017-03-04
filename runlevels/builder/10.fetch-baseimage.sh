#!/bin/bash
.  /dgr/bin/functions.sh
isLevelEnabled "debug" && set -x

set -euo pipefail
: ${CACHEDIR:="/cache"}
: ${BASEIMAGE:="ubuntu-16.04-linux-amd64.aci"}

tar -C ${ROOTFS}/ \
  --exclude "manifest" \
  --strip-components=1 \
  -xJf "${CACHEDIR}/${BASEIMAGE}"
