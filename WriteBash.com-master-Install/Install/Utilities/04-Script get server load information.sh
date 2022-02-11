#!/bin/bash
# Script author: Danie Pham
# Script site: https://www.writebash.com
# Script date: 16-01-2018
# Script ver: 1.0
# Demo bash script run as a service in CentOS 6
# Script use to get load average of server every 1 second

# Function get load average
f_get_average () {
    # This command will add time to each line
    date >> $FILE

    # This command will get load average and write to FILE
    uptime | awk -F'load average: ' '{print $2}' >> $FILE

    # Echo a line spacing
    echo "" >> $FILE
}

# Main function. You can call any functions as you want to this function
f_main () {
    # Define a text file
    FILE="/tmp/writebash_demo.txt"

    # We you a loop to run function f_get_average forever
    while true
    do
        # Call function
        f_get_average

        # Sleep 1 second
        sleep 1
    done
}
f_main

exit