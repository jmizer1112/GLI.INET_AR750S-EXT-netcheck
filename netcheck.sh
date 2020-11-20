#!/bin/bash

#########################################################################################
##               Netcheck - Simple internet connection logging updated                 ##
##                          for use on travel router GL.INET AR750S-EXT                ##
##                                                                                     ##
##               https://github.com/jmizer1112/GLI.INET_AR750S-EXT-netcheck            ##
##               -- Jerry D Mizer                                                      ##
##               originally forked from https://github.com/TristanBrotherton/netcheck  ##
##                                       -- Tristan Brotherton                         ##
#########################################################################################

VAR_SCRIPTNAME=`basename "$0"`
VAR_SCRIPTLOC="/lib"
VAR_CONNECTED=false
VAR_LOGFILE=/mnt/sda1/netcheck.log
VAR_CHECK_TIME=5
VAR_HOST=http://www.google.com

COLOR_RED="\033[31m"
COLOR_GREEN="\033[32m"
COLOR_RESET="\033[0m"

STRING_1="LINK RECONNECTED:                               "
STRING_2="LINK DOWN:                                      "

PRINT_NL() {
  echo
}

PRINT_HR() {
  echo "-----------------------------------------------------------------------------"
}

PRINT_HELP() {
  echo "Here are your options:"
  echo
  echo "$VAR_SCRIPTNAME -h                                           Display this message"
  echo "$VAR_SCRIPTNAME -f path/my_log_file.log          Specify log file and path to use"
  echo "$VAR_SCRIPTNAME -c                Check connection ever (n) seconds. Default is 15"
  echo "$VAR_SCRIPTNAME -u            URL/Host to check, default is http://www.google.com"
  echo
}

PRINT_LOGDEST() {
  echo "Logging to:        $VAR_LOGFILE"
}

PRINT_LOGSTART() {
  echo "************ Monitoring started at: $(date "+%a %d %b %Y %H:%M:%S %Z") ************" >> $VAR_LOGFILE
  echo -e "************$COLOR_GREEN Monitoring started at: $(date "+%a %d %b %Y %H:%M:%S %Z") $COLOR_RESET************"
}

PRINT_DISCONNECTED() {
  echo "$STRING_2 $(date "+%a %d %b %Y %H:%M:%S %Z")" >> $VAR_LOGFILE
  echo -e $COLOR_RED"$STRING_2 $(date)"$COLOR_RESET
}

PRINT_RECONNECTED() {
  echo "$STRING_1 $(date "+%a %d %b %Y %H:%M:%S %Z")" >> $VAR_LOGFILE
  echo -e $COLOR_GREEN"$STRING_1 $(date "+%a %d %b %Y %H:%M:%S %Z")"$COLOR_RESET
}

PRINT_LOGGING_TERMINATED() {
  echo
  echo "************ Monitoring ended at:   $(date "+%a %d %b %Y %H:%M:%S %Z") ************" >> $VAR_LOGFILE
  echo -e "************$COLOR_RED Monitoring ended at:   $(date "+%a %d %b %Y %H:%M:%S %Z") $COLOR_RESET************"
}

NET_CHECK() {
  while true; do
    # Check for network connection
    wget -q -4 --timeout=5 -O - $VAR_HOST > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then :
      # We are currently online
      # Did we just reconnect?
      if [[ $VAR_CONNECTED = false ]]; then :
        PRINT_RECONNECTED
        VAR_DURATION=$SECONDS
        PRINT_HR | tee -a $VAR_LOGFILE
        SECONDS=0
        VAR_CONNECTED=true
      fi

    else
      # We are offline
      if [[ $VAR_CONNECTED = false ]]; then :
          # We were already disconnected
        else
          # We just disconnected
          PRINT_DISCONNECTED
          SECONDS=0
          VAR_CONNECTED=false
      fi
    fi

    sleep $VAR_CHECK_TIME

  done

}

CLEANUP() {
  if [[ $VAR_INSTALL_AS_SERVICE = false ]]; then :
    PRINT_LOGGING_TERMINATED
  fi
}

trap CLEANUP EXIT
while getopts "f:c:u:p:whelp-si" opt; do
  case $opt in
    f)
      echo "Logging to custom file: $OPTARG"
      VAR_LOGFILE=$OPTARG
      VAR_CUSTOOM_LOG=true
      ;;
    c)
      echo "Checking connection every: $OPTARG seconds"
      VAR_CHECK_TIME=$OPTARG
      ;;
    u)
      echo "CheckingAR_HOST=$OPTARG"
      ;;
    h)
      PRINT_HELP
      exit 1
      ;;
    \?)
      echo "Invalid option: -$OPTARG (try -help for clues)"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done

PRINT_HR
PRINT_LOGDEST
PRINT_LOGSTART
NET_CHECK
