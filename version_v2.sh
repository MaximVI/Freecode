#!/bin/bash
#Скрипт для анализа занимаемого диска и прочего.
#Описание условий: if - если, then - тогда, else - еще

echo "Enter ip address"
read address

#Подключение по протоколу SSH к серверу
#Получение информации о доступном дисковом пространстве сервера

ssh root@$address echo '"Available disk space"; df --output=avail -h "$PWD";
echo "Largest directories";
du -Sh /var/www/*/data/www/* | sort -rh | head -10;
echo "The largest databases";
du -Sh /var/lib/mysql/* --exclude=/var/lib/mysql/ib* --exclude=/var/lib/mysql/aria* --exclude=/var/lib/mysql/multi* --exclude=/var/lib/mysql/roundcube* --exclude=/var/lib/mysql/*.log --exclude=/var/lib/mysql/performance_schema* --exclude=/var/lib/mysql/mysql* | sort -rh | head -5;
echo "Check search key"; 
cat /var/www/*/data/www/*/bitrix/license_key.php | grep LICENSE'

#Проверка лицензионного ключа Битрикс путем обращения к служебному скрипту Аспро
#license_key.php который можно запускать в отличие от сервиса Битрикс многократно
#без капчи, но не следует злоупотреблять с его запусками

echo "Product license key"
read license
curl https://aspro.ru/support/key_info.php?key=$license
