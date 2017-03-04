#!/bin/bash
.  /dgr/bin/functions.sh
isLevelEnabled "debug" && set -x

set -uo pipefail

# Perl
rm -r /usr/share/perl5 /usr/lib/**/perl* /usr/bin/perl*

# package manager and Ubuntu-specifics
rm -r /etc/apt /usr/bin/apt* /usr/lib/apt /usr/lib/**/libapt* \
  /usr/share/bash-completion/completions/apt /usr/share/bug/apt /var/cache/apt /var/lib/apt /var/log/apt
rm -r /etc/dpkg /usr/bin/debconf* /usr/bin/dpkg* /usr/lib/dpkg /usr/sbin/dpkg* /usr/share/dpkg
rm -r /usr/share/bash-completion/completions/debconf* /usr/share/debconf /usr/share/lintian \
  /var/cache/debconf
rm -r /usr/bin/sensible* /usr/bin/select* /usr/bin/update* /usr/share/pixmaps /usr/share/upstart \
  /usr/bin/deb* /usr/sbin/update*
rm -r /usr/share/**/python /usr/lib/python*
rm -r /usr/share/base-files

# Retain chpst.
cp -a /usr/bin/chpst ./

set -e
# Now prune all files.
while read fname; do
  if [[ -e "${fname}" && ! -d "${fname}" ]]; then
    rm "${fname}"
  fi
done < <(cat \
    /var/lib/dpkg/info/{apt,apt-transport-https,dash,debconf,debianutils,dpkg,gnupg-agent,gnupg2,libassuan0,libsqlite3-0}*.list \
    /var/lib/dpkg/info/{pinentry-curses,sensible-utils,ubuntu-keyring,gpgv2,libgpg-error0}*.list \
    /var/lib/dpkg/info/{libapt-pkg5.0,libgcrypt20,perl-base}*.list \
    /var/lib/dpkg/info/{libpam,passwd,login,adduser,runit}*.list \
  | sort -u -r)
rm /usr/bin/localedef

mv ./chpst /usr/bin/

# Remove package lists.
rm -r /var/lib/dpkg /var/log/installer

# Remove broken symlinks.
remove_broken_symlinks() {
  while read fname; do
    rm "${fname}"
  done < <(find / -type l -! -exec test -e {} \; -print | grep -v "/proc")
}
remove_broken_symlinks
remove_broken_symlinks

# Due to removed libraries.
ln -s /bin/bash /bin/sh
ldconfig
rm /var/cache/ldconfig/aux-cache

exit 0
