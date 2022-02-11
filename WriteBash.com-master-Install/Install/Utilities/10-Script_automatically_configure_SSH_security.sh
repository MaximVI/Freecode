#!/bin/bash
#
# Script by: Danie Pham
# Script date: 04-06-2019
# Script version: 1.0
# Script use: use to configure ssh security faster
# Remmeber to edit NOTE 1 & 2 in this script

# Function configure ssh
f_config_ssh () {
	# Disable X11 Forwarding in Linux server
	sed -i 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config

	# Set MaxAuthTries to 1
	sed -i 's/#MaxAuthTries 6/MaxAuthTries 1/g' /etc/ssh/sshd_config

	# Auto disconnect after 5 minutes
	sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 300/g' /etc/ssh/sshd_config
	sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 0/g' /etc/ssh/sshd_config

	# Config hostbase authentication
	sed -i 's|#IgnoreRhosts yes|IgnoreRhosts yes|g' /etc/ssh/sshd_config
	sed -i 's/#HostbasedAuthentication no/HostbasedAuthentication no/g' /etc/ssh/sshd_config

	# Don't allow empty password
	sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config

	# Don't allow TCP Forwarding -> Prevent hacker use your server like a router or transfer something
	sed -i 's|#AllowTcpForwarding yes|AllowTcpForwarding no|g' /etc/ssh/sshd_config

	sed -i 's|#UsePrivilegeSeparation yes|UsePrivilegeSeparation yes|g' /etc/ssh/sshd_config
	sed -i 's|#StrictModes yes|StrictModes yes|g' /etc/ssh/sshd_config

	# Config banner for ssh, just optional
	sed -i 's|#Banner none|Banner /etc/ssh/ssh_banner.txt|g' /etc/ssh/sshd_config

	###########################################################
	### NOTE 1: edit youruser and your ip to the line below ###
	###########################################################
	echo "AllowUsers youruser@192.168.10.10 youruser@192.168.10.11" >> /etc/ssh/sshd_config

	##############################################
	### NOTE 2: edit your ip to the line below ###
	##############################################
	echo "sshd : 192.168.10.10 192.168.10.11" >> /etc/hosts.allow

	echo "sshd : ALL" >> /etc/hosts.deny

	# Change content of banner as you want
	cat > /etc/ssh/ssh_banner.txt <<"EOF"
*****************************************************************
	        PLEASE READ CAREFULLY BELOW !!
	        ------------------------------
    1. Do not stop IPtables service, just edit it if needed.
    2. Do not change SSH configuration if you don't know it.
    3. SSH just allow a few special user, do not change it.

*****************************************************************
	EOF

	# Restart service ssh to apply new configuration
	service sshd restart
}

# Function main
f_main () {
	f_config_ssh
}
f_main

exit