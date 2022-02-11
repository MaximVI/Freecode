#!/bin/bash

#Ищем все файлы с SOA записями в директории /var/named/
grep -iRl 'SOA' /var/named/ --exclude named.* --exclude *.bind > /tmp/file ;
FILE=`cat /tmp/file`

#Если не находит файлы с SOA, то дальше не проверяем
if [[ $FILE == "" ]]; then
    echo "Нет SOA записей"
    break
    else

   #Резервируем файлы
   mkdir /var/backup_named/
   for c in $FILE
   do
         cp -r $FILE /var/backup_named/ ; echo "$c скопирован в директорию /var/backup_named/" #script.log
   done

   #Изменяем файлы
   for f in $FILE
   do
        #Узнём строку где находится SOA
        grep -n "SOA" $f | cut -c-1 > /tmp/file2
        FILE2=`cat /tmp/file2`
        #Меняем все значения в строке с 900 на 86400
        sed -i "`$FILE2`s/ 900 / 86400 /g" $f;
        echo "$f проверен/изменён" #2>> script.log;  
   done
   systemctl restart named
   cd /tmp/; rm -f file file2


fi
