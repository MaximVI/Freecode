#!/bin/bash

version=1.0

pname=${0##*/}
#(($#)) || {
#	echo
#	echo Prepares info for transfering site.
#	echo Use:
#	echo $pname \<file\>
#	echo Where file must contain source www-domain per line.
#	exit 1
#}

echo
echo Подготавливает сводные данные для переноса сайтов.
echo
echo v.$version
echo


function dostr() {		# prompts by parameter, gets string and outs it all.
	declare s;		# if presents the second parameter returns value of the string.
	read -p "$1:  " s
	[[ $2 != '' ]] && echo -n "$s"
	[[ $s == '.' ]] && return 10
	#[[ $s == '' ]] && return 0
	echo "$1:  $s" >>$out
}

#file=$1
#out=$file.out

out=${pname%.*}.out
echo -n '' >$out

echo
echo В любой момент можно ввести точку для выхода.
echo
echo По выходу смотри файл $out
echo

for i in Источник Назначение; do 
	echo $i: >&2
	echo $i: >>$out
	for j in Хост Пользователь Пароль; do
		dostr $'\t'$j || exit
	done
done

while :; do
	dostr "Задание от пользователя или от root-а" || break
done

while :; do
	domain="$(dostr www-домен 1)" || break
	dostr $'\tалиас?' || break
	dostr $'\tверсия PHP' || break
	while :; do
		dostr $'\tредирект' || break
	done
	echo >>$out
	[[ $domain != '' ]] && {
		for t in a aaaa ns mx txt; do
			host -t $t $domain |while read x; do
				echo $'\t'$x >>$out
			done
		done
		host -t txt _dmarc.$domain |while read x; do
			echo $'\t'$x >>$out
		done
		if wget -O /dev/null https://$domain >/dev/null 2>&1; then
			echo $'\tSSL-сертификат:  ЕСТЬ' >>$out
		   else
			echo $'\tSSL-сертификат:  НЕТ' >>$out
		fi
	}
	echo >>$out
	dostr $'\tпуть к источнику' || break
	echo $'\tНовая база данных:' >&2
	echo $'\tНовая база данных:' >>$out
	for j in База Пользователь Пароль; do
		dostr $'\t\t'$j || break
	done
	dostr $'\tПроизводительность и время отклика' || break
done



#cat $file |while read x y; do
#	echo $x >>$out
#done


## PHP ver.
## DNS: NS, A, TXT, SPF, DMARC
## crontab from user and from root
## redirects (301)
## производительность
## new database's
## SSL
