#!/bin/bash
# Script author: Danie Pham
# Script site: https://www.writebash.com
# Script date: 30-12-2017
# Script ver: 1.0
# Script use to delete files that have been labeled as "deleted" in /proc directory

# Function check the size of root partition /
f_check_free () {
    # Get current size
    CURRENT=`df -Th | grep -w / | awk '{print $5}' | awk -F'%' '{print $1}'`

    # If size >= 80%
    if [[ "$CURRENT" -ge 80 ]]; then
        # Call function f_free_disk
        f_free_disk
    fi
}

# Function execute free_disk
f_free_disk () {
    # Define a temp file
    FREE_DISK="/tmp/free_disk"

    # Find all files has label "deleted" in /proc directory and save pathname to temp file
    find /proc/*/fd -ls | grep  '(deleted)' > $FREE_DISK

    # The loop - read temp file and delete each file
    while read -r line
    do
            FILE=`echo $line | awk '{print $11}'`
            :>"$FILE"
    done < "$FREE_DISK"

    # Delete temp file after finish
    rm -f $FREE_DISK
}

# Main function
f_main () {
    f_check_free
}
f_main

exit