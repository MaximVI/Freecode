#!/bin/bash

echo "Enter IP"
read ipaddress
ssh root@$ipaddress 'echo "Free disk space"; df -h | grep "/dev/*"; echo "The five largest directories"; du -Sh /var/www/*/data/www/* | sort -rh | head -5; echo "The five largest databases"; du -Sh /var/lib/mysql/* --exclude=/var/lib/mysql/ib* --exclude=/var/lib/mysql/aria* --exclude=/var/lib/mysql/multi* --exclude=/var/lib/mysql/roundcube* --exclude=/var/lib/mysql/*.log --exclude=/var/lib/mysql/performance_schema* --exclude=/var/lib/mysql/mysql* | sort -rh | head -5; echo "Check license key bitrix"; cat /var/www/*/data/www/*/bitrix/license_key.php | grep LICENSE'

echo "licensekey"
read license
curl https://aspro.ru/support/key_info.php?key=$license
