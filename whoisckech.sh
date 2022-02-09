#!/bin/bash

echo "DNS check"
read dns
curl https://2whois.ru/?t=dns&data=$dns
