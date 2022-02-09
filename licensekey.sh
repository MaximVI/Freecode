#!/bin/bash


echo "Check license key bitrix"; 
cat /var/www/*/data/www/*/bitrix/license_key.php | grep LICENSE
echo "licensekey"
read license
curl https://aspro.ru/support/key_info.php?key=$license
