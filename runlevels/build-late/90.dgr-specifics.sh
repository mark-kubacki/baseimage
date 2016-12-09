#!/bin/bash
.  /dgr/bin/functions.sh
isLevelEnabled "debug" && set -x

set -euo pipefail

rm -r /dgr/runlevels/inherit-build-late

exit 0
