#!/bin/bash
# Script by: WriteBash.com
# Script date: 20-12-2017
# Script version: 1.0
# Script use to send an email to administrator everytime an user login ssh successfully.


# Define URL to log file
define_log () {
   LOG_FILE="/var/log/secure"
   FOLDER="/opt/scripts/do-not-remove"
   NUMBER="/opt/scripts/do-not-remove/number_line_ssh.txt"
}

# Define some temp files, used to store temporary log information
define_tmp () {
   TEMP_LOG="/tmp/ssh_temp_log.txt"
   GREP="/tmp/ssh_grep_temp.txt"
}

# Declare some basic information about the server
server_info () {
   SERVER=`hostname | awk -F'.' '{print $1}'`
   DATE=`date`
}

# Check the "filenumber_line_ssh.txt" is exists or not, otherwise create a new file
check_folder () {
   if [[ -d $FOLDER ]]; then
      if [[ ! -s $NUMBER ]]; then
         touch $NUMBER
         echo 0 > $NUMBER
      fi
   else
      mkdir -p $FOLDER
      touch $NUMBER
      echo 0 > $NUMBER
   fi
}

# Function get ssh log for 1 minutes
get_log () {
   NUM=`cat $NUMBER`
   SUM=`expr "$NUM" + 1`
   tail -n +"$SUM" $LOG_FILE > $TEMP_LOG
   echo `wc -l < $LOG_FILE` > $NUMBER
}

# Function send an email to administrator
send_mail () {
   SSH_U=$1
   SSH_F=$2
   SSH_T=$3
   mailx -v -r "system@yourdomain.com" -s "SSH ALERT: [ $SERVER ] " -S smtp="192.168.1.10:25" -S smtp-auth=login -S smtp-auth-user="system@yourdomain.com" -S smtp-auth-password="yourpassword" -S ssl-verify=ignore administrator@yourdomain.com <<END_OF_MAIL
-----------------------------------------
SERVER: $(hostname)
DATE: $DATE
-----------------------------------------

USER: $SSH_U
SSH FROM: $SSH_F
TIME SSH: $SSH_T
-----------------------------------------
END_OF_MAIL
}

# Function process the temp log
process_log () {
   cat $TEMP_LOG | grep "Accepted password" > $GREP
   if [[ -s $GREP ]]; then
      while read -r line
      do
         TIME=`echo $line | awk '{print $3 "-" $2 "-" $1}'`
         USER=`echo $line | awk '{print $9}'`
         FROM=`echo $line | awk '{print $11}'`
         send_mail $USER $FROM $TIME
      done < "$GREP"
   else
      delete_tmp
      exit
   fi
}

# Function delete temp files everytime excute script
delete_tmp () {
   rm -f $TEMP_LOG
   rm -f $GREP
}

# Main function
main () {
   define_log
   define_tmp
   server_info
   check_folder
   get_log
   process_log
   delete_tmp
}
main

exit