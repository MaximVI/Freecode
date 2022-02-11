#!/bin/bash
# Script author: Danie Pham
# Script site: https://www.writebash.com
# Script date: 26-03-2018
# Script ver: 1.0
# Script use to install LEMP stack on Debian 8.x
#--------------------------------------------------
# Software version:
# 1. OS: Debian 8.10 (Jessie) 64 bit
# 2. Nginx: 1.13.10
# 3. MariaDB: 10.2.13
# 4. PHP 7: 7.0.28-1~dotdeb+8.1
#--------------------------------------------------
# List function:
# 1. f_check_root: check to make sure script can be run by user root
# 2. f_disable_cdrom: disable cdrom repository and add some needed repositories
# 3. f_update_os: update all the packages
# 4. f_install_lemp: funtion to install LEMP stack
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
    echo "Add default repositories for Debian 8 ..."
    sleep 1
    echo "deb http://httpredir.debian.org/debian jessie main contrib non-free" >> /etc/apt/sources.list
    echo "deb-src http://httpredir.debian.org/debian jessie main contrib non-free" >> /etc/apt/sources.list
    echo "" >> /etc/apt/sources.list
    echo "deb http://httpredir.debian.org/debian jessie-updates main contrib non-free" >> /etc/apt/sources.list
    echo "deb-src http://httpredir.debian.org/debian jessie-updates main contrib non-free" >> /etc/apt/sources.list
    echo ""
    sleep 1
}

# Function update os
f_update_os () {
    echo "Starting update os ..."
    echo ""
    sleep 1
    apt-get update
    apt-get upgrade -y
    echo ""
    sleep 1
}

# Function install LEMP stack
f_install_lemp () {
    ########## INSTALL NGINX ##########
    echo "Start install nginx ..."
    echo ""
    sleep 1

    # Add Nginx's repository to server Debian 8
    echo "Add Nginx's repository to server ..."
    echo ""
    sleep 1
    echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list
    echo "deb-src http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list

    # Download and add Nginx key
    wget https://nginx.org/keys/nginx_signing.key -O /tmp/nginx_signing.key
    apt-key add /tmp/nginx_signing.key
    rm -f /tmp/nginx_signing.key

    # Update new packages from Nginx repo
    echo ""
    echo "Update new packages from Nginx's repository ..."
    echo ""
    sleep 1
    apt-get update

    # Install and start nginx
    echo ""
    echo "Installing nginx ..."
    echo ""
    sleep 1
    apt-get install nginx -y
    systemctl start nginx
    echo ""
    sleep 1

    ########## INSTALL MARIADB ##########
    echo "Start install MariaDB server ..."
    echo ""
    sleep 1

    # Add MariaDB's repository to server Debian 8
    echo "Add MariaDB's repository to server ..."
    echo ""
    sleep 1
    apt-get install software-properties-common -y
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
    add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.2/debian jessie main'

    # Update new packages from MariaDB repo
    echo ""
    echo "Update new packages from MariaDB's repository ..."
    echo ""
    sleep 1
    apt-get update

    # Install MariaDB server
    echo "Installing MariaDB server ..."
    echo ""
    sleep 1
    apt-get install mariadb-server mariadb-client -y
    echo ""
    sleep 1

    ########## INSTALL PHP7 ##########
    # This is unofficial repository, it's up to you if you want to use it.
    echo "Add repository PHP 7 ..."
    echo ""
    sleep 1

    # Add unofficial repository PHP 7.0 to server Debian 8
    echo "" >> /etc/apt/sources.list
    echo "# Add repository PHP 7" >> /etc/apt/sources.list
    echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list
    echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list

    # Download and add DotDeb key
    wget https://www.dotdeb.org/dotdeb.gpg -O /tmp/dotdeb.gpg
    apt-key add /tmp/dotdeb.gpg
    rm -f /tmp/dotdeb.gpg
    echo ""
    sleep 1

    echo "Update packages from Dotdeb repository ..."
    echo ""
    sleep 1
    apt-get update
    echo ""
    sleep 1

    echo "Start install PHP 7 ..."
    echo ""
    sleep 1
    apt-get install php7.0 php7.0-fpm php7.0-gd php7.0-mysql -y
    echo ""
    sleep 1

    # Config to make PHP-FPM working with Nginx
    echo "Config to make PHP-FPM working with Nginx ..."
    echo ""
    sleep 1
    sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' /etc/php/7.0/fpm/php.ini
    sed -i 's:user = www-data:user = nginx:g' /etc/php/7.0/fpm/pool.d/www.conf
    sed -i 's:group = www-data:group = nginx:g' /etc/php/7.0/fpm/pool.d/www.conf
    sed -i 's:listen.owner = www-data:listen.owner = nginx:g' /etc/php/7.0/fpm/pool.d/www.conf
    sed -i 's:listen.group = www-data:listen.group = nginx:g' /etc/php/7.0/fpm/pool.d/www.conf
    sed -i 's:;listen.mode = 0660:listen.mode = 0660:g' /etc/php/7.0/fpm/pool.d/www.conf

    # Create web root directory and php info file
    echo "Create web root directory and PHP info file ..."
    echo ""
    sleep 1
    mkdir /etc/nginx/html
    echo "<?php phpinfo(); ?>" > /etc/nginx/html/info.php
    chown -R nginx:nginx /etc/nginx/html

    # Create demo nginx vhost config file
    echo "Create demo Nginx vHost config file ..."
    echo ""
    sleep 1
    cat > /etc/nginx/conf.d/writebash.com.conf <<"EOF"
server {
    listen 80;
    listen [::]:80;

    root /etc/nginx/html;
    index index.php index.html index.htm;

    server_name 192.168.56.30;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include         fastcgi_params;
        fastcgi_pass    unix:/run/php/php7.0-fpm.sock;
        fastcgi_param   SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_index   index.php;
    }
}
EOF

    # Restart nginx and php-fpm
    echo "Restart Nginx & PHP-FPM ..."
    echo ""
    sleep 1
    systemctl restart nginx
    systemctl restart php7.0-fpm

    echo ""
    echo "You can access http://YOUR-SERVER-IP/info.php to see more informations about PHP"
    sleep 1
}

# The sub main function, use to call neccessary functions of installation
f_sub_main () {
    f_disable_cdrom
    f_update_os
    f_install_lemp
}

# The main function
f_main () {
    f_check_root
}
f_main

exit