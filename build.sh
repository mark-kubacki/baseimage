#!/bin/bash

set -euo pipefail
if [[ ! -z ${debug+x} ]]; then
  set -x
fi

V_BOLD_RED="\e[1m\e[0;31m"
V_BOLD_PURPLE="\e[1m\e[0;35m"
V_BOLD_GREEN="\e[1m\e[0;32m"
V_VIDOFF="\e[0m"

if [[ -t 1 ]] && tput colors &>/dev/null; then
  V_BOLD_RED=$(tput bold; tput setaf 1)
  V_BOLD_GREEN=$(tput bold; tput setaf 2)
  V_VIDOFF=$(tput sgr0)
fi

info() {
  printf "${V_BOLD_GREEN}${1}${V_VIDOFF}"
}
error() {
  >&2 printf "${V_BOLD_RED}${1}${V_VIDOFF}"
}

if [[ ! -s target/image.aci ]]; then
  info "About to run 'dgr' to build the ACI file.\n"
  # Subshell, because dgr could close STDIN or other channels.
  (sudo dgr build)
fi

: ${build_date:="$(<target/manifest.json jq -r '.annotations[] | select(.name == "build-date").value')"}
: ${workdir:="$(mktemp -d -t baseimage.XXXXXX)"}
trap "rm -r \"${workdir}\"" EXIT

info "Extracting the ACI file… "
tar --exclude "manifest" --strip-components=1 \
  -C "${workdir}" -xpf target/image.aci
info "OK\n"
chmod 0755 "${workdir}"

info "Collect the files in a tarball… "
tar -C "${workdir}" --exclude "./dgr" \
  --transform "s@^./\$@/@" \
  --transform "s@^./@@" \
  --one-file-system \
  --absolute-names \
  --sort=name --numeric-owner \
  --mtime "${build_date}" --clamp-mtime \
  -cf amd64/pre-rootfs.tar .
info "OK\n"

info "Move the result to amd64/rootfs.tar\n"
mv amd64/pre-rootfs.tar amd64/rootfs.tar

info "Update the Dockerfile… "
sed -i \
  -e "/build-date/s@=.*\$@=\"${build_date}\" \\\\@" \
  amd64/Dockerfile

info "OK\n"

exit 0
