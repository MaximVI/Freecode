#!/bin/bash
#
# Script use to start SAP HANA application
# Script run as: sudo user (ec2-user)
# Script by: Danie Pham
# Script date: 13/11/2019
# Script version: 1.0
# Website: https://www.writebash.com

# Function define variables
f_define_variables () {
    # File to save HDB info
    fileHDB="/tmp/HDB.info"

    # File to save instance 01 info
    fileInstance01="/tmp/instance01.info"

    # File to save instance 02 info
    fileInstance02="/tmp/instance02.info"

    # Check if file HDB.info exist, delete it before call function f_sap_start_HDB()
    if test -f "$fileHDB"; then
        rm -f $fileHDB && touch $fileHDB
    fi

    # Check if file instance01.info exist, delete it before call function f_sap_start_instance01()
    if test -f "$fileInstance01"; then
        rm -f $fileInstance01 && touch $fileInstance01
    fi

    # Check if file instance02.info exist, delete it before call function f_sap_start_instance02()
    if test -f "$fileInstance02"; then
        rm -f $fileInstance02 && touch $fileInstance02
    fi
}

# Function start HANA Database
f_sap_start_HDB () {
    # Change to user hdbadm and execute command
    sudo su - hdbadm -c "/usr/sap/HDB/HDB00/HDB start"

    # Get info HDB
    sudo su - hdbadm -c "/usr/sap/HDB/HDB00/HDB info" > $fileHDB

    # String HDB info status
    stringStatus=$( egrep "hdbnameserver|hdbcompileserver|hdbpreprocessor|hdbdocstore|hdbdpserver|hdbindexserver|hdbxsengine|hdbdiserver|hdbwebdispatcher" -c  $fileHDB)

    # Check if HDB start successfully
    if [ $stringStatus -eq 9 ]
    then
        echo ""
        echo "### HDB Start: SUCCESS ###"
        echo ""
        sleep 3

        # Return TRUE flag
        return 0
    else
        echo ""
        echo "### HDB Start: FAILED ###"
        echo ""
        sleep 3

        # Return FALSE flag
        return 1
    fi
}

# Function start instance 01
f_sap_start_instance01 () {
    # Change to user bapadm and execute command
    # Please note user bapadm depent to your instance name, please change it match to your system
    sudo su - bapadm -c "sapcontrol -nr 01 -function Start"

    # Get instance 01 info status
    sudo su - bapadm -c "sapcontrol -nr 01 -function GetProcessList" > $fileInstance01

    # String instance 01 info status
    stringInstance01=$( egrep "Running|Running|Running" -c $fileInstance01)

    i=1

    while [[ $stringInstance01 -lt 3 ]]; do
        # Get instance 01 info status
        sudo su - bapadm -c "sapcontrol -nr 01 -function GetProcessList" > $fileInstance01

        # String instance 01 info status
        stringInstance01=$( egrep "Running|Running|Running" -c $fileInstance01)

        i=$i+1

        if [[ $i > 50 ]]; then
            break
        fi
    done

    # Check if instance 01 start successfully
    if [ $stringInstance01 -eq 3 ]
    then
        echo ""
        echo "### instance 01 Start: SUCCESS ###"
        echo ""
        sleep 3

        # Return TRUE flag
        return 0
    else
        echo ""
        echo "### instance 01 Start: FAILED ###"
        echo ""
        sleep 3

        # Return FALSE flag
        return 1
    fi
}

# Function start instance 02
f_sap_start_instance02 () {
    # Change to user bapadm and execute command
    sudo su - bapadm -c "sapcontrol -nr 02 -function Start"

    # Get instance 02 info status
    sudo su - bapadm -c "sapcontrol -nr 02 -function GetProcessList" > $fileInstance02

    # String instance 02 info status
    stringInstance02=$( egrep "Running|Running|Running|Running" -c $fileInstance02)

    i=1

    while [[ $stringInstance01 -lt 4 ]]; do
        # Get instance 01 info status
        sudo su - bapadm -c "sapcontrol -nr 02 -function GetProcessList" > $fileInstance02

        # String instance 01 info status
        stringInstance02=$( egrep "Running|Running|Running|Running" -c $fileInstance02)

        i=$i+1

        if [[ $i > 50 ]]; then
            break
        fi
    done

    # Check if instance 02 start successfully
    if [ $stringInstance02 -eq 4 ]
    then
        echo ""
        echo "### instance 02 Start: SUCCESS ###"
        echo ""
        sleep 3
    else
        echo ""
        echo "### instance 02 Start: FAILED ###"
        echo ""
        sleep 3
    fi
}

# Function main
f_main () {
    f_define_variables
    f_sap_start_HDB && sleep 15

    # Check if function f_sap_start_HDB() return TRUE flag
    if f_sap_start_HDB $1
    then
        # HDB start successfully, call f_sap_start_instance01()
        f_sap_start_instance01
    else
        # HDB start failed, exit script and print notification to terminal
        echo ""
        echo "HDB start failed, cannot start instance 01."
        echo "Exit script in 3 second."
        echo ""
        sleep 3
        exit
    fi

    # Check if function f_sap_start_instance01() return TRUE flag
    if f_sap_start_instance01 $1
    then
        # instance 01 start successfully, call f_sap_start_instance02()
        f_sap_start_instance02
    else
        # instance 01 start failed, exit script and print notification to terminal
        echo ""
        echo "instance 01 start failed, cannot start instance 02."
        echo "Exit script in 3 second."
        echo ""
        sleep 3
        exit
    fi
}
f_main

exit