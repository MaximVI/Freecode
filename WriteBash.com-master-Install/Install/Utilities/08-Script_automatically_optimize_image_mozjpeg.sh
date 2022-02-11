#!/bin/bash
# Script author: Danie Pham
# Script site: https://www.writebash.com
# Script date: 19-03-2019
# Script ver: 1.0
# Script automatically optimize images with tool MozJPEG.

# Function optimize images
f_optimize () {
    # Create folder 'image' to save optimized images
    mkdir image

    # List all .jpg file in current folder
    ls | grep jpg > list.txt

    # Read file list.txt and optimize each image
    while read -r line
    do
        /usr/bin/mozjpeg -optimize -quality 80 "$line" > image/"$line"
    done < list.txt

    # Remove file list.txt after finish optimize
    rm -f list.txt

}

# Main function
f_main () {
    f_optimize
}
f_main

# Exit script
exit