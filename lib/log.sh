#!/bin/bash

###GLOBALS_START###
LOG_DIR="/var/log"
LOG=0
###GLOBALS_END###

#/
# Returns a timestamp of the date and time right now
#
# @return string The date and time right now
# @author        Niklas Rosenqvist
#/
function time_stamp() {
    echo "$(date '+%Y-%m-%d %T')"
}

#/
# The path to the log file
#
# If logging is disabled it returns /dev/null so that the users
# doesn't need to worry about using different functions. The global
# variable LOG_DIR can be set to decide where the script outputs it's log
#
# @return string The path to the log file
# @author        Niklas Rosenqvist
#/
function log_file() {
    if [ $LOG -eq 0 ]; then
        echo "$LOG_DIR/$(basename "$0").log"
    else
        echo "/dev/null"
    fi
}

#/
# Write the string provided to the log
#
# @param string $1 The log message
# @return void
# @author Niklas Rosenqvist
#/
function log() {
    echo "$(time_stamp) $1" >> "$(log_file)"
}

#/
# Write the string provided to the log with a [MSG] tag
#
# @param string $1 The log message
# @return void
# @author Niklas Rosenqvist
#/
function log_msg() {
    echo "$(time_stamp) [MSG] $1" >> "$(log_file)"
}

#/
# Write the string provided to the log with a [WRN] tag
#
# The user also has the option to pass the $LINENO as the second argument
#
# @param string $1 The log message
# @param string $2 Optionally the line number of the call
# @return          void
# @author          Niklas Rosenqvist
#/
function log_wrn() {
    if [ $# -eq 2 ]; then
        echo "$(time_stamp) [WRN] (Line: $2) $1" >> "$(log_file)"
    else
        echo "$(time_stamp) [WRN] $1" >> "$(log_file)"
    fi
}

#/
# Write the string provided to the log and stderr with a [ERR] tag
#
# The user also has the option to pass the $LINENO as the second argument
#
# @param string $1 The log message
# @param string $2 Optionally the line number of the call
# @return          void
# @author          Niklas Rosenqvist
#/
function log_err() {
    if [ $# -eq 2 ]; then
        echo "$(time_stamp) [ERR] (Line: $2) $1" 1>&2 | tee -a "$(log_file)"
    else
        echo "$(time_stamp) [ERR] $1" 1>&2 | tee -a "$(log_file)"
    fi   
}
