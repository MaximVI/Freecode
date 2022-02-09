#!/bin/bash
#Список IP хостов
HOST="`cat /home/loop/m.ageev_2107/ipfile.txt`"
echo "Start of execution `date +%d-%m-%Y\ %H:%M:%S`" >> /home/loop/m.ageev_2107/script.log
for var in $HOST
do
echo "Reading the host $var Start" &>>script.log
##ssh root@$var "cat /var/named/*; cat /var/named/domains" | tee -a script.log
ssh -oStrictHostKeyChecking=no root@$var "grep -iRl 'IN' /var/named/ --exclude named.* --exclude *.bind" | tee -a script.log
echo "Reading the host $var Completion" &>>script.log
done
