#!/bin/bash
#
# Script use to setup service Certbot Renew for Nginx web server, for OS using systemd
# Script run as: root
# Script by: Danie Pham
# Script date: 08/01/2020
# Script version: 1.0
# Website: https://www.writebash.com

# Function create Certbot Renewal timer
f_certbot_timer () {
    # Edit OnUnitActiveSec with your interval time
    # In this script, default is a day (24 hours)
    cat > /etc/systemd/system/certbot-renewal.timer <<"EOF"
[Unit]
Description=Timer for Certbot Renewal

[Timer]
OnBootSec=300
OnUnitActiveSec=1d

[Install]
WantedBy=multi-user.target
EOF
}

# Function create Certbot Renewal service
f_certbot_service () {
    # Change /usr/bin/certbot with your path
    cat > /etc/systemd/system/certbot-renewal.service <<"EOF"
[Unit]
Description=Certbot Renewal

[Service]
ExecStart=/usr/bin/certbot renew --post-hook "systemctl reload nginx"
EOF
}

# Function main
f_main () {
    # Call above functions
    f_certbot_timer
    f_certbot_service

    # Enable & start service
    systemctl enable certbot-renewal.timer
    systemctl start certbot-renewal.timer

    # Check status of service
    echo "===================================="
    echo "=   STATUS CERTBOT RENEWAL TIMER   ="
    echo "===================================="
    echo ""
    systemctl status certbot-renewal.timer
    echo ""

    echo "======================================"
    echo "=   STATUS CERTBOT RENEWAL SERVICE   ="
    echo "======================================"
    echo ""
    journalctl -u certbot-renewal.service
}
f_main

exit