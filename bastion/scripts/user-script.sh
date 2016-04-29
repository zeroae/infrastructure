#!/bin/bash

# Disable the admin's shell
usermod -s /bin/false admin

# Disable SFTP
sed -E -i .bck \
    -e "s/^Subsystem(.*)/#Subsystem\1/" \
    /etc/ssh/sshd_config

# Disable root login in prod
environment = $(mdata-get env)
if [ "$environment" == "prod" ]; then
    sed -E -i .bck \
        -e "s/PermitRootLogin.*/PermitRootLogin no/" \
        /etc/ssh/sshd_config
else
    sed -E -i .bck \
        -e "s/PermitRootLogin.*/PermitRootLogin without-password/" \
        /etc/ssh/sshd_config
fi

svcadm refresh ssh
