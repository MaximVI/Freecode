#!/usr/bin/python
# -*- coding: utf-8 -*-
import fileinput, os, shutil
from datetime import datetime
from sys import argv
#------------------------------------------
path = "/var/named/" # Пути до файлов
#-----------------------------------------
now = datetime.now()
date = (now.strftime("%Y%m%d00")) # Генерация даты для serial
datefile = (now.strftime("%Y%m%d%M%S")) # Генерация даты для архивирования старой директории
#-----------------------------------------
#print('Изменение SOA записей\nОдновременно меняются все параметры, указывай поочереди\nSerialNumber\nRefresh\nRetry\nExpire\nMinimum TTL\n')
script, refresh, retry, expire, minttl = argv
#--------Создаём директорию для бэкапа----
backupdir= ("/root/named_backup/")
renamedir= ("/root/named_backup"+'_old_'+datefile)
if os.path.exists(backupdir) == True: #проверяем наличие папки, если есть создаём архив
    shutil.make_archive(renamedir, 'tar', backupdir) # архивируем старую папрку
    shutil.rmtree(backupdir) # удаляем старую директорию
    os.mkdir(backupdir) # создаём заново 
else:
    os.mkdir(backupdir)
#-----------------------------------------
for dirs,folder,files in os.walk(path):#получаем список файлов и директорий
    for file in files: #перебираем и выводим полный путь
#--------Файлы исключения, которые не должны изменится--------
        if file == "named.ca":
            break
        elif file == "named.localhost":
            break
        elif file == "named.empty":
            break
        elif file == "test.domain":
            break
        elif file == "managed-keys.bind":
            break
        elif file == "named.run":
            break
        elif file == "named.loopback":
            break
        else:
           filepath = os.path.join(dirs,file)
#           print(file)
#--------------Узнаём владельца файла для дальнейшего назначения ( файл перезаписывается, соответсвенно владелец будет тот юзер с которого запускался скрипт )
           uid = os.stat(filepath).st_uid
           gid = os.stat(filepath).st_gid
#---------------Копируем оригинал--------
           shutil.copy(filepath, "/root/named_backup/")
#-----------------------------------------          
           for line in fileinput.input(filepath, inplace=True): #Открываем файл на изменения, все вызовы print() изменят строку
               index = line.find("SOA") #Ищём SOA запись, find отдаёт -1 значит подстроки нет, либо другое число значит подстрока в строке есть
#-----------------------------------------    
               if index == -1: #-1 означает что нет записи, такие строки пропускаем
                  #print(line, end='') #python3
                  print(line.rstrip()) #python2 Вывод строки без пробелов
                  #continue
               else:
                  l = line.split()# остальные строки превращаем в список для замены
#-----------------------Проверка Serial, он равен или больше сегодняшней дате, то увеличивается на 1---------
                  if l[-5] >= "("+date:
                     tmp = l[-5]
                     tmp = tmp[1:11]
                     tmp = int(tmp)+1
                     tmp = "("+str(tmp)
                     l[-5] = tmp
                      #datetmp = int(date)+1
                     #datetmp2 = "("+str(datetmp)
                     #l[-5] = datetmp2
                  else:
                       l[-5] = "("+date #меняем значение по позиции на сегодняшнее число
                  l[-4] = refresh     #ttl-refresh
                  l[-3] = retry       #retry
                  l[-2] = expire      #expire
                  l[-1] = minttl+")"  #minimum
                  donel= ('  '.join(l)) # возращаем строку print(donel)
                  print(donel)
#-----------Возвращаем владельца-----------
           os.chown(filepath, uid, gid)
#-----------------------------------------

