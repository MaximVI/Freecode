#!/bin/bash
# Script author: Danie Pham
# Script site: https://www.writebash.com
# Script date: 17-03-2018
# Script ver: 1.0
# Script use to install LAMP stack on Debian 9.x
#--------------------------------------------------
# Software version:
# 1. OS: Debian 9.3 (stretch) 64 bit.
# 2. Apache: 2.4.25
# 3. MariaDB: 10.1.26
# 4. PHP 7: 7.0.27-0+deb9u1
#--------------------------------------------------
# List function:
# 1. f_check_root: check to make sure script can be run by user root
# 2. f_disable_cdrom: use to disable this line 'deb cdrom:[Debian GNU/Linux 9.3.0 _Stretch_ - Official amd64 DVD Binary-1 20171209-12:11]/ stretch contrib main'
# 3. f_update_os: update all the packages
# 4. f_install_lamp: funtion to install LAMP stack
# 5. f_sub_main: function use to call the main part of installation
# 6. f_main: the main function, add your functions to this place


# Function check user root
f_check_root () {
if (( $EUID == 0 )); then
    # If user is root, continue to function f_sub_main
    f_sub_main
else
    # If user not is root, print message and exit script
    echo "Please run this script by user root !"
    exit
fi
}

# Function disable cdrom repository in file sources.list
f_disable_cdrom () {
    # Because of we do not use repository from cdrom
    echo "Disable cdrom repository ..."
    sleep 1
    sed -i 's:^deb cdrom:#deb cdrom:g' /etc/apt/sources.list
    echo ""
    sleep 1

    # This part base on link: https://gooroo.io/GoorooTHINK/Article/17003/Installing-PHP-7-MySQLMariaDB-and-Apache-on-Debian-8-or-CentOS-7/24769#.Wqod2B99LZs
    echo "Add default repositories for Debian 9 ..."
    sleep 1
    echo "deb http://httpredir.debian.org/debian stretch main contrib non-free" >> /etc/apt/sources.list
    echo "deb-src http://httpredir.debian.org/debian stretch main contrib non-free" >> /etc/apt/sources.list
    echo "" >> /etc/apt/sources.list
    echo "deb http://httpredir.debian.org/debian stretch-updates main contrib non-free" >> /etc/apt/sources.list
    echo "deb-src http://httpredir.debian.org/debian stretch-updates main contrib non-free" >> /etc/apt/sources.list
    echo ""
    sleep 1
}

# Function update os
f_update_os () {
    echo "Starting update os ..."
    sleep 1

    apt-get update
    apt-get upgrade -y

    echo ""
    sleep 1
}

# Function install LAMP stack
f_install_lamp () {
    ########## INSTALL APACHE2 ##########
    echo "Installing apache2 ..."
    sleep 1
    apt-get install apache2 -y
    # This part base on: https://linode.com/docs/web-servers/lamp/lamp-on-debian-8-jessie/
    # This part is optimize for server 2GB RAM
    sed -i '/<If/,/<\/If/{//!d}' /etc/apache2/mods-available/mpm_prefork.conf
    sed -i '/<If/a\ StartServers              4\n MinSpareServers           20\n MaxSpareServers           40\n MaxRequestWorkers         200\n MaxConnectionsPerChild    4500' /etc/apache2/mods-available/mpm_prefork.conf

    # The event module is enabled by default. This should be disabled, and the prefork module enabled:
    a2dismod mpm_event
    echo ""
    sleep 1
    a2enmod mpm_prefork
    echo ""
    sleep 1

    # Restart apache2
    systemctl restart apache2
    echo ""
    sleep 1

    ########## INSTALL MARIADB ##########
    echo "Installing MariaDB server ..."
    sleep 1
    apt-get install mariadb-server mariadb-client -y
    echo ""
    sleep 1

    ########## INSTALL PHP7 ##########
    echo "Start install PHP 7 ..."
    sleep 1
    apt-get install php7.0 php7.0-fpm php7.0-gd php7.0-mysql -y
    # To enable PHP7.0 in Apache2
    a2enmod proxy_fcgi setenvif
    a2enconf php7.0-fpm
    systemctl restart apache2
    echo ""
    sleep 1

    echo "<?php phpinfo(); ?>" > /var/www/html/info.php
    echo ""
    echo "You can access http://YOUR-SERVER-IP/info.php to see more informations about PHP"
    sleep 1
}

# The sub main function, use to call neccessary functions of installation
f_sub_main () {
    f_disable_cdrom
    f_update_os
    f_install_lamp
}

# The main function
f_main () {
    f_check_root
}
f_main

exit