#!/bin/bash

## скрипт для мониторинга доменных имён -> проверка срока действия домена
## url: http://rocknroot.pp.ua/blog/skript-dlya-monitoringa-domennyih-imyon.html


# НЕ ЗАБЫТЬ ДОБАВИТЬ В /etc/whois.conf СТРОКИ:
# \.ua$ whois.com.ua
# \.by$ whois.cctld.by
#(если нужно)
# или положить где-нибудь свой whois.conf и указать параметром к команде whois

export LC_ALL=ru_RU.utf8

# массив доменных имён для опроса
ARR_DOMAIN+=(
ya.ru
mail.ru
)

# если нет возможности править whois.conf - тогда можно попробовать вписать в массив bash следующее значение: '-h whois.cctld.by tut.by' (в кавычках)

# создаём файл для временных данных
echo "" > tmp_file_domain_renew

# записывает туда заголовок таблицы 
printf "%-35s\t %-25s\t %-25s\n" "Domain     " "< 50 days" "> 50 days" >> tmp_file_domain_renew
printf "%-35s\t %-25s\t %-25s\n" "---------------" "----------" "----------" >> tmp_file_domain_renew

# парсим информацию о сроке действия домена
for DOMAIN_ in "${ARR_DOMAIN[@]}"
 do
 sleep 0.2
 dateexp_=`whois $DOMAIN_ | \
 egrep -i 'Expiration Date:|paid-till:|OK-UNTIL|Domain Currently Expires:|Record expires on|expires:|Registry Expiry Date:'| \
 head -n 1 | \
 sed 's/\(OK-UNTIL\) \(.\{,8\}\).*/\2/i' | \
 sed 's/.*Currently //' | \
 sed 's/.*Expiration Date:/ExpDate: /' | \
 sed 's/.*Registry Expiry Date:/RegExpDate: /' | \
 sed 's/T[0-9][0-9]\:.*//'| \
 awk '{$1=""; print $0}' | \
 sed 's/^\ //' | \
 sed 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\)/\1\2\3/i'`

#  высчитываем, сколько остаётся дней от текущей даты
dateexp_s=`date -d "${dateexp_}" +"%s"`
datenow_s=`date +"%s"`
diff_s=`expr $dateexp_s - $datenow_s`
diff_d=`expr $diff_s / 3600 / 24`

# заполняем стоблцы таблицы в зависимости от того
# больше или меньше, в данном случае, 50 дней
if [[ $diff_d -ge 50 ]];
then
  printf "%-35s\t %-25s\t %-25s\n" "$DOMAIN_"  "-" "$diff_d" >> tmp_file_domain_renew
else
  printf "%-35s\t %-25s\t %-25s\n" "$DOMAIN_" "$diff_d" "-" >> tmp_file_domain_renew
fi

done

# отсылаем на почту
# mail -s DomainRenewCheck iam@aspetruk.xyz < tmp_file_domain_renew
# mail -s DomainRenewCheck aspetruk@gmail.com < tmp_file_domain_renew
cat tmp_file_domain_renew

# прибираем за собой
rm tmp_file_domain_renew