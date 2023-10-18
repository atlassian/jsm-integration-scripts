#!/bin/bash

if [ ! -d "/var/log/jsm" ]; then
    mkdir /var/log/jsm
fi

chmod -R 775 /var/log/jsm
chmod -R g+s /var/log/jsm
chmod -R 775 /etc/jsm

chown -R jsm:jsm /etc/jsm
chown -R jsm:jsm /var/log/jsm

chmod 755 /etc/jsm/send2jsm

if id -u oracle >/dev/null 2>&1; then
        usermod -a -G jsm oracle
        chown -R oracle:jsm /var/log/jsm
else
        echo "WARNING : oracle user does not exist. Please don't forget to add your oracle user to jsm group!"
fi
