#!/bin/bash
# Script author: Danie Pham
# Script site: https://www.writebash.com
# Script date: 31-12-2017
# Script ver: 1.0
# Script use to install clamav on CentOS 6.x

# Function install clamav
f_install_clamav () {

    # Command install epel-release package
    yum install epel-release -y

    # Command install clamav package
    yum install clamav clamav-db clamd -y

    # Set clamav auto start after reboot
    /etc/init.d/clamd on
    chkconfig clamd on

    # Update database for clamav
    /usr/bin/freshclam

    # Start clamav
    /etc/init.d/clamd start

    # Exclude some wrong signature of clamav
    cat > /var/lib/clamav/local.ign2 <<"EOF"
PUA.Win.Trojan.EmbeddedPDF-1
PUA.Pdf.Trojan.EmbeddedJavaScript-1
PUA.Pdf.Trojan.EmbeddedJS-1
Heuristics.OLE2.ContainsMacros
EOF

    # Restart clamav
    /etc/init.d/clamd restart
}
# Main function
f_main () {

    # Call f_install_clamav function (you can use this method in other script)
    f_install_clamav
}
f_main

exit