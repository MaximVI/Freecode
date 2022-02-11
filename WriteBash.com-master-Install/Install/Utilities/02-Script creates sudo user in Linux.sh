#!/bin/bash
# Script by: WriteBash.com
# Script date: 20-12-2017
# Script version: 1.0
# Script is used to create sudo users on Linux systems

# Declare a password for each user
USER_A="usera_pass"
USER_B="userb_pass"

# Function use to create users
create_user () {
    adduser $1
    echo $1:$2 | chpasswd
    echo "$1 ALL=(ALL) ALL" >> /etc/sudoers
}

# Normally, when you create a sudo user, you will disable login root for extra security
disable_root () {
    RECENT=`cat /etc/ssh/sshd_config | grep "PermitRootLogin" | head -n 1`
    sed -i 's|'"$RECENT"'|PermitRootLogin no|g' /etc/ssh/sshd_config
    service sshd restart
}

# Main function
main () {
    # The following command calls "create_user" function and passes the parameter is username and password
    create_user usera $USER_A
    create_user userb $USER_B
    disable_root
}
main

exit