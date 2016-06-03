#!/bin/bash

REPO_FILE=/opt/local/etc/pkgin/repositories.conf

sed -i '' \
	-e 's|pkgsrc.joyent.com|${pkgbuild_host}:8080|'\
	$REPO_FILE

tail -n 1 /opt/local/etc/pkgin/repositories.conf |\
   	sed -e 's|:8080/packages||' >> $REPO_FILE

wget http://${pkgbuild_host}/pkgbuild.gpg
gpg --no-default-keyring \
	--keyring $(pkg_admin config-var GPG_KEYRING_VERIFY)\
	--import pkgbuild.gpg
rm -f pkgbuild.gpg

