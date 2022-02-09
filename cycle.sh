#!/bin/bash

echo "Enter ip address"
read address

ssh root@$address 
while
do
 echo '"Free disk space"; df -h | grep "/dev/*";
 echo "The five largest directories";
 du -Sh /var/www/*/data/www/* | sort -rh | head -9;
 echo "The five largest databases";
 du -Sh /var/lib/mysql/* --exclude=/var/lib/mysql/ib* --exclude=/var/lib/mysql/aria* --exclude=/var/lib/mysql/multi* --exclude=/var/lib/mysql/roundcube* --exclude=/var/lib/mysql/*.log --exclude=/var/lib/mysql/performance_schema* --exclude=/var/lib/mysql/mysql* | sort -rh | head -5;
echo "Check search key"; 
cat /var/www/*/data/www/*/bitrix/license_key.php | grep LICENSE'

echo "Product license key"
read license
curl https://aspro.ru/support/key_info.php?key=$license
done
##https://aspro.ru/support/key_info.php
##https://www.1c-bitrix.ru/support/key_info.php
