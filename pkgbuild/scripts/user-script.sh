#!/bin/bash

export PS4='[\D{%FT%TZ}] ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

export PATH=/opt/local/bin:${PATH}
export HOME=/root

set -o xtrace
set -o errexit
set -o pipefail

#
# The presence of the /var/svc/.ran-user-script file indicates that the
# instance has already been setup (i.e. the instance has booted previously).
#
# Upon first boot, run the setup.sh script if present. On all boots including
# the first one, run the configure.sh script if present.
#

SENTINEL=/var/svc/.ran-user-script

DIR=/opt/smartdc/boot

if [[ ! -e ${SENTINEL} ]]; then
  cd /data/pkgsrc
  if [ ! -d zeroae ]; then
    git submodule add --name zeroae https://github.com/zeroae/pkgsrc-zeroae zeroae
  fi

  gpg_key_id=$(mdata-get user-data | gpg --import - 2>&1 | grep 'key .*:' | tail -n 1 | sed -e 's/gpg: key //' -e 's/:.*//')
  mdata-put gpg_key_id ${gpg_key_id}

  touch ${SENTINEL}
fi

cd /data/packages
nohup python -m SimpleHTTPServer 80 > /dev/null&
