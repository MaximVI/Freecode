#!/bin/bash
# Script author: Danie Pham
# Script site: https://www.writebash.com
# Script date: 17-03-2019
# Script ver: 1.0
# Script use to check nginx status and automatic restart if it is failed
# Script use in CentOS 6
# Example when nginx running: nginx (pid  2846) is running...

# Function get current nginx status
f_get_status () {
	# Get current nginx status
	F_STATUS=`/etc/init.d/nginx status`
	# Get status nginx: running...
	STATUS=`/etc/init.d/nginx status | awk '{print $5}'`
	# Get current nginx PID: 2846
	PID=`/etc/init.d/nginx status | awk '{print $3}' | awk -F')' '{print $1}'`
}

# Function send email alert to administrators
f_send_email () {
	A_STATUS=`/etc/init.d/nginx status`
	mail -s "NGINX SERVICE RESTART: [ $(hostname) ]" -r system@yourdomain.com admin1@yourdomain.com admin2@yourdomain.com <<END_OF_MAIL
---------------------------------------------
SERVER: $(hostname)
TIME: $(date)
STATUS BEFORE: $F_STATUS
STATUS AFTER: $A_STATUS
---------------------------------------------
END_OF_MAIL
}

# Function process nginx status
f_process_status () {
	# If status is not "running...", restart service immediately
	if [[ "$STATUS" == "running..." ]]; then
        exit
	else
        # Restart nginx service
        /etc/init.d/nginx restart
        f_send_email
        # Sleep for 10s (time for nginx restart) for the next command
	    sleep 10
	fi

	# If restart command above failed
	# If nginx status is "nginx dead but subsys locked"
	DEAD="nginx dead but subsys locked"
	if [[ "$F_STATUS" == "$DEAD" ]]; then
		# Kill nginx process via PID
		kill -9 $PID

		# Copy file subsys lock of nginx to another folder
		cp /var/lock/subsys/nginx /opt/scripts/do-not-remove/

		# Delete sybsys lock file of nginx
		rm -f /var/lock/subsys/nginx

		# Restart nginx service again
		/etc/init.d/nginx start
		f_send_email
	else
	    exit
	fi
}

# Function main
main () {
	f_get_status
	f_process_status
}
main

exit