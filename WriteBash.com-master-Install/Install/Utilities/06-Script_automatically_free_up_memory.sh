#!/bin/bash
# Script author: Danie Pham
# Script site: https://www.writebash.com
# Script date: 05-03-2019
# Script ver: 1.0
# Script automatically frees up memory in Linux server when it exceeds 80% of memory.

# Function get percentage of memory used
f_get_memory_used () {
    # Get total memory
    TOTAL_MEM=`free | grep Mem | awk '{print $2}'`

    # Get used memory
    USED_MEM=`free | grep Mem | awk '{print $3}'`

    # Calculate percentage of memory used
    PERCENT=$(awk "BEGIN {printf \"%.2f\",($USED_MEM/$TOTAL_MEM)*100}")
}

# Function automatically frees up memory
f_free_memory () {
    # Check if PERCENT >= 80%
    if [[ "${PERCENT%%.*}" -ge 80 ]]; then
        sync; echo 3 > /proc/sys/vm/drop_caches
    else
        exit
    fi
}

# Main function
f_main () {
    f_get_memory_used
    f_free_memory
}
f_main

exit