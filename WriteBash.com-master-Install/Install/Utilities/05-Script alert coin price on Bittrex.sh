#!/bin/bash
#
# Author: Danie Pham
# Website: https://www.writebash.com
# Date: 24-07-2018
# Use: simple script use to alert coin price on Bittrex

echo -n "COIN (usdt-btg): "; read coin;
echo -n "LOW PRICE: "; read lprice;
echo -n "HIGH PRICE: "; read hprice;

while true
do
	COIN=`curl -s https://bittrex.com/api/v1.1/public/getmarketsummary?market=$coin | python -mjson.tool | grep Last | awk '{print $2}' | sed 's/,//g'`
	sleep 0.5

	compare_low=`echo "$COIN <=$lprice" | bc`
	if [[ $compare_low -gt 0 ]]; then
		zenity --warning --text="$coin lower than $lprice"
	else
		echo "$COIN"
	fi

	compare_high=`echo "$COIN >=$hprice" | bc`
	if [[ $compare_high -gt 0 ]]; then
		zenity --warning --text="$coin higher then $hprice"
	else
		echo "$COIN"
		echo "----- $(date) -----"
	fi
done