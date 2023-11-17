chmod 755 /home/jsm/jec/scripts/send2jsm

if id -u zabbix >/dev/null 2>&1; then
        usermod -a -G jsm zabbix
        chown -R zabbix:jsm /var/log/jec
else
        echo "WARNING : zabbix user does not exist. Please don't forget to add your zabbix user to jsm group!"
fi