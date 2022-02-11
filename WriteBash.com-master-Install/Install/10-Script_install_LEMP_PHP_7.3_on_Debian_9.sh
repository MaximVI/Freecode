#!/bin/bash
# Script author: Danie Pham
# Script site: https://www.writebash.com
# Script date: 11-03-2019
# Script ver: 1.0
# Script use to install LEMP stack on Debian 9
#--------------------------------------------------
# Software version:
# 1. OS: 9 (stretch) 64 bit
# 2. Nginx: 1.14.2
# 3. MariaDB: 10.3.13
# 4. PHP 7: 7.3.3-1+0~20190307202245.32+stretch~1.gbp32ebb2
#--------------------------------------------------
# List function:
# 1. f_check_root: check to make sure script can be run by user root
# 2. f_update_os: update all the packages
# 3. f_install_lemp: funtion to install LEMP stack
# 4. f_sub_main: function use to call the main part of installation
# 5. f_main: the main function, add your functions to this place

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

    apt install curl gnupg2 ca-certificates lsb-release -y


    # Add Nginx's repository to server Debian 9
    echo "Add Nginx's repository to server ..."
    echo ""
    sleep 1
    echo "deb http://nginx.org/packages/debian `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list

    # Download and add Nginx key
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
    apt-key fingerprint ABF5BD827BD9BF62

    # Update new packages from Nginx repo
    echo ""
    echo "Update new packages from Nginx's repository ..."
    echo ""
    sleep 1
    apt update

    # Install and start nginx
    echo ""
    echo "Installing nginx ..."
    echo ""
    sleep 1
    apt install nginx -y
    systemctl enable nginx && systemctl start nginx
    echo ""
    sleep 1

    ########## INSTALL MARIADB ##########
    echo "Start install MariaDB server ..."
    echo ""
    sleep 1

    # Add MariaDB's repository to server Debian 9
    echo "Add MariaDB's repository to server ..."
    echo ""
    sleep 1
    apt-get install software-properties-common dirmngr -y
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
    add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mariadb.nethub.com.hk/repo/10.3/debian stretch main'

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
    apt-get install mariadb-server -y
    systemctl enable mysql && systemctl start mysql
    echo ""
    sleep 1

    ########## INSTALL PHP7 ##########
    # This is unofficial repository, it's up to you if you want to use it.
    echo "Add repository PHP 7 ..."
    echo ""
    sleep 1

    # Add unofficial repository PHP 7.3 to server Debian 9
    apt install lsb-release apt-transport-https ca-certificates software-properties-common wget -y
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php7.3.list

    echo "Update packages from Dotdeb repository ..."
    echo ""
    sleep 1
    apt update
    echo ""
    sleep 1

    echo "Start install PHP 7 ..."
    echo ""
    sleep 1
    apt install php7.3 php7.3-cli php7.3-common php7.3-fpm php7.3-gd php7.3-mysql -y
    echo ""
    sleep 1

    # Config to make PHP-FPM working with Nginx
    echo "Config to make PHP-FPM working with Nginx ..."
    echo ""
    sleep 1
    sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' /etc/php/7.3/fpm/php.ini
    sed -i 's:user = www-data:user = nginx:g' /etc/php/7.3/fpm/pool.d/www.conf
    sed -i 's:group = www-data:group = nginx:g' /etc/php/7.3/fpm/pool.d/www.conf
    sed -i 's:listen.owner = www-data:listen.owner = nginx:g' /etc/php/7.3/fpm/pool.d/www.conf
    sed -i 's:listen.group = www-data:listen.group = nginx:g' /etc/php/7.3/fpm/pool.d/www.conf
    sed -i 's:;listen.mode = 0660:listen.mode = 0660:g' /etc/php/7.3/fpm/pool.d/www.conf

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
        fastcgi_pass    unix:/run/php/php7.3-fpm.sock;
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
    systemctl restart php7.3-fpm

    echo ""
    echo "You can access http://YOUR-SERVER-IP/info.php to see more informations about PHP"
    sleep 1
}

# The sub main function, use to call neccessary functions of installation
f_sub_main () {
    f_update_os
    f_install_lemp
}

# The main function
f_main () {
    f_check_root
    f_sub_main
}
f_main

exit