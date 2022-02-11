#!/bin/bash

D='/var/www/www-root/data/www/inmircom.ru/bitrix'
R='cache html_pages managed_cache'
for s in ${R}
do
  find "$D/$s" -type d -name '*.~[0-9]*' -print|xargs /bin/rm -rf
done