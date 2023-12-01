if [ ! -d "/var/log/jsm" ]; then
    mkdir /var/log/jsm
fi
chmod -R 775 /var/log/jsm
chmod -R g+s /var/log/jsm

chmod 755 /opt/jsm/opsview/monitoringscripts/notifications/send2jsm

if id -u opsview >/dev/null 2>&1; then
        usermod -a -G jsm opsview
        chown -R opsview:jsm /var/log/jsm
else
        echo "WARNING : opsview user does not exist. Please don't forget to add your opsview user to JSM group!"
fi
