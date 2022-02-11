PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/user/.local/bin:/home/user/bin
#!/bin/bash
# Script use to check iptables running?
# If it not running, restart service iptables.

# Function get iptables status
f_iptables_status () {
	STATUS=`service iptables status | grep Active: | awk '{print $2}'`

	# If iptables status not equal "active"
	if [[ "$STATUS" != "active" ]]; then
		# Call function restart service iptables
		f_restart_iptables
	fi
}

# Function restart service iptables
f_restart_iptables () {
	FILE="/etc/sysconfig/iptables"
	
	# Check if iptables file not exist
	if [[ -f "$FILE" ]]; then
		service iptables restart
	# If iptables file not exist, copy from /opt/scripts/config/iptables to start service
	else
		cp /opt/scripts/config/iptables /etc/sysconfig/iptables
		service iptables restart
	fi
}

# Function main
f_main () {
	f_iptables_status
}
f_main

exit