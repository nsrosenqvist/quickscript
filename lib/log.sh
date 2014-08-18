#!/bin/bash

###GLOBALS_START###
LOG_DIR="/var/log"
LOG=0
###GLOBALS_END###

function time_stamp {
    echo "$(date '+%Y-%m-%d %T')"
}

function log_file {
    if [ $LOG -eq 0 ]; then
        echo "$LOG_DIR/$(script_name).log"
    else
        echo "/dev/null"
    fi
}
function log {
    echo "$(time_stamp) $1" >> "$(log_file)"
}

function log_msg {
    echo "$(time_stamp) [MSG] $1" >> "$(log_file)"
}

function log_wrn {
    if [ $# -eq 2 ]; then
        echo "$(time_stamp) [WRN] (Line: $2) $1" >> "$(log_file)"
    else
        echo "$(time_stamp) [WRN] $1" >> "$(log_file)"
    fi
}

function log_err {
    if [ $# -eq 2 ]; then
        echo "$(time_stamp) [ERR] (Line: $2) $1" 1>&2 | tee -a "$(log_file)"
    else
        echo "$(time_stamp) [ERR] $1" 1>&2 | tee -a "$(log_file)"
    fi   
}
