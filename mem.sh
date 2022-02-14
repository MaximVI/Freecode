bash-4.2$ cat mem.sh 
#!/bin/bash
#Убедитесь, что только root может запустить наш скрипт

if [ "$(id -u)" != "0" ]; then
echo "This script must be run as root" 1>&2
exit 1
fi

### Functions
# Эта функция будет считать статистику памяти для переданного PID
get_process_mem ()
{
PID=$1
#we need to check if 2 files exist
if [ -f /proc/$PID/status ];
then
if [ -f /proc/$PID/smaps ];
then
# здесь мы считаем использование памяти, Pss, Private и Shared = Pss-Private
Pss=`cat /proc/$PID/smaps | grep -e "^Pss:" | awk '{print $2}'| paste -sd+ | bc `
Private=`cat /proc/$PID/smaps | grep -e "^Private" | awk '{print $2}'| paste -sd+ | bc `
# мы должны быть уверены, что мы считаем Pss и Private memory чтобы избежать ошибок
if [ x"$Rss" != "x" -o x"$Private" != "x" ];
then

let Shared=${Pss}-${Private}
Name=`cat /proc/$PID/status | grep -e "^Name:" |cut -d':' -f2`
# все результаты сохраняем в байтах
let Shared=${Shared}*1024
let Private=${Private}*1024
let Sum=${Shared}+${Private}

echo -e "$Private + $Shared = $Sum \t $Name"
fi
fi
fi
}

# эта функция выполняет преобразование из байтов в Кб или Мб или Гб
convert()
{
value=$1
power=0
#if value 0, we make it like 0.00
if [ "$value" = "0" ];
then
value="0.00"
fi

# Мы делаем преобразование до значения больше 1024, и если да, то делим на 1024
while [ $(echo "${value} > 1024"|bc) -eq 1 ]
do
value=$(echo "scale=2;${value}/1024" |bc)
let power=$power+1
done

# эта часть получает b, kb, mb или gb в зависимости от количества делений
case $power in
0) reg=b;;
1) reg=kb;;
2) reg=mb;;
3) reg=gb;;
esac

echo -n "${value} ${reg} "
}

# чтобы гарантировать, что временные файлы не существуют
[[ -f /tmp/res ]] && rm -f /tmp/res
[[ -f /tmp/res2 ]] && rm -f /tmp/res2
[[ -f /tmp/res3 ]] && rm -f /tmp/res3

# если передан аргумент, скрипт покажет статистику только для этого pid, а не - мы перечислим все процессы в / proc / # и получим статистику для всех, все результаты сохраним в файле / tmp / res
if [ $# -eq 0 ]
then
pids=`ls /proc | grep -e [0-9] | grep -v [A-Za-z] `
for i in $pids
do
get_process_mem $i >> /tmp/res
done
else
get_process_mem $1>> /tmp/res
fi

# Результат будет отсортирован по использованию памяти
cat /tmp/res | sort -gr -k 5 > /tmp/res2

# эта часть получит имена uniq из списка процессов, и мы добавим все строки с тем же списком процессов
# мы посчитаем количество процессов с одинаковыми именами, поэтому если будет больше 1 процесса, где будет
# процесс (2) в выводе
for Name in `cat /tmp/res2 | awk '{print $6}' | sort | uniq`
do
count=`cat /tmp/res2 | awk -v src=$Name '{if ($6==src) {print $6}}'|wc -l| awk '{print $1}'`
if [ $count = "1" ];
then
count=""
else
count="(${count})"
fi

VmSizeKB=`cat /tmp/res2 | awk -v src=$Name '{if ($6==src) {print $1}}' | paste -sd+ | bc`
VmRssKB=`cat /tmp/res2 | awk -v src=$Name '{if ($6==src) {print $3}}' | paste -sd+ | bc`
total=`cat /tmp/res2 | awk '{print $5}' | paste -sd+ | bc`
Sum=`echo "${VmRssKB}+${VmSizeKB}"|bc`
#all result stored in /tmp/res3 file
echo -e "$VmSizeKB + $VmRssKB = $Sum \t ${Name}${count}" >>/tmp/res3
done

# это сделает сортировку еще раз
cat /tmp/res3 | sort -gr -k 5 | uniq > /tmp/res

# теперь печатаем результат, первый заголовок
echo -e "Private \t + \t Shared \t = \t RAM used \t Program"
# после того, как мы прочитаем построчно временный файл
while read line
do
echo $line | while read a b c d e f
do
# печатаем все процессы, если используется Ram, если не 0
if [ $e != "0" ]; then
# здесь мы используем функцию, которая производит преобразование
echo -en "`convert $a` \t $b \t `convert $c` \t $d \t `convert $e` \t $f"
echo ""
fi
done
done < /tmp/res


# эта часть печати нижнего колонтитула с подсчетом использования Ram
echo "--------------------------------------------------------"
echo -e "\t\t\t\t\t\t `convert $total`"
echo "========================================================"

# we clean temporary file
[[ -f /tmp/res ]] && rm -f /tmp/res
[[ -f /tmp/res2 ]] && rm -f /tmp/res2
[[ -f /tmp/res3 ]] && rm -f /tmp/res3
