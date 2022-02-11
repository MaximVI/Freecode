#!/bin/bash
# Script author: Danie Pham
# Script site: https://www.writebash.com
# Script date: 28-03-2018
# Script ver: 1.0
# Script use to install rkhunter on CentOS 6
#--------------------------------------------------
# Software version:
# 1. OS: CentOS 6.9 (Final) 64 bit
# 2. Rootkit Hunter version 1.4.6
#--------------------------------------------------

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

# Function install rkhunter
f_install_rkhunter () {
    # All files required for installation of RKHunter are contained in the EPEL repository
    echo "Install EPEL repository ..."
    echo ""
    sleep 1
    yum install epel-release -y
    echo ""
    sleep 1

    # Install rkhunter
    echo "Install rkhunter ..."
    echo ""
    sleep 1
    yum install rkhunter -y
    echo ""
    sleep 1

    # Update database for rkhunter
    echo "Update database for rkhunter ..."
    echo ""
    sleep 1
    rkhunter --update
    echo ""
    sleep 1

    # Update system file properties
    echo "Update system file properties ..."
    echo ""
    sleep 1
    rkhunter --propupd
    echo ""
    sleep 1

    echo "You can type this command to manual scan rootkit: rkhunter -c"
    echo ""
    sleep 1
}

# The sub main function, use to call neccessary functions of installation
f_sub_main () {
    f_install_rkhunter
}

# The main function
f_main () {
    f_check_root
}
f_main

exit